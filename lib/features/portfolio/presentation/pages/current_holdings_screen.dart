import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/portfolio_service.dart';
import '../../../../core/models/holding_model.dart';
import '../../../../core/services/alpha_vantage_service.dart';
import 'add_stock_screen.dart';

class CurrentHoldingsScreen extends StatefulWidget {
  @override
  _CurrentHoldingsScreenState createState() => _CurrentHoldingsScreenState();
}

class _CurrentHoldingsScreenState extends State<CurrentHoldingsScreen> with TickerProviderStateMixin {
  TabController? _tabController;
  List<HoldingModel> _allHoldings = [];
  List<HoldingModel> _dhanHoldings = [];
  List<HoldingModel> _mtfHoldings = [];
  List<HoldingModel> _manualHoldings = [];

  bool _isFetchingDhan = false;
  bool _isUpdatingPrices = false;
  String _sortBy = 'name';
  bool _isAscending = true;

  Map<String, bool> _expandedStocks = {};
  Set<String> _collapsedSections = {};

  int _totalStocksToUpdate = 0;
  int _stocksUpdated = 0;
  String _currentlyUpdatingStock = '';
  String _estimatedTimeRemaining = '';

  late AnimationController _waveAnimationController;
  late Animation<double> _waveAnimation;
  late AnimationController _arrowAnimationController;
  late Animation<Offset> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupAnimations();
    _loadHoldings();
  }

  void _setupAnimations() {
    _waveAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveAnimationController,
      curve: Curves.easeInOut,
    ));

    _arrowAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _arrowAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset(0, -0.3),
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadHoldings() async {
    try {
      final portfolioService = PortfolioService();
      final holdings = await portfolioService.getAllHoldings();

      setState(() {
        _allHoldings = holdings;
        _dhanHoldings = holdings.where((h) => h.source == 'dhan').toList();
        _mtfHoldings = holdings.where((h) => h.source == 'dhan' && h.isMTF == true).toList();
        _manualHoldings = holdings.where((h) => h.source == 'manual').toList();
      });

      _sortHoldings();
      print('Loaded ${holdings.length} holdings');
      print('MTF holdings: ${_mtfHoldings.length}');
      for (var holding in _mtfHoldings) {
        print('MTF Stock: ${holding.symbol} - isMTF: ${holding.isMTF}');
      }
    } catch (e) {
      print('Error loading holdings: $e');
      Get.snackbar(
        'Error',
        'Failed to load holdings: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _sortHoldings() {
    final comparator = (HoldingModel a, HoldingModel b) {
      int result = 0;
      switch (_sortBy) {
        case 'name':
          result = a.symbol.compareTo(b.symbol);
          break;
        case 'invested':
          result = a.investedAmount.compareTo(b.investedAmount);
          break;
        case 'pnl':
          result = a.pnl.compareTo(b.pnl);
          break;
      }
      return _isAscending ? result : -result;
    };

    setState(() {
      _allHoldings.sort(comparator);
      _dhanHoldings.sort(comparator);
      _mtfHoldings.sort(comparator);
      _manualHoldings.sort(comparator);
    });
  }

  String _formatEstimatedTime(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    } else if (totalSeconds < 3600) {
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '${minutes}m ${seconds}s';
    } else {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }

  Future<void> _fetchDhanHoldings() async {
    setState(() {
      _isFetchingDhan = true;
    });

    try {
      final portfolioService = PortfolioService();
      await portfolioService.syncDhanHoldings();
      await _loadHoldings();

      setState(() {
        _isFetchingDhan = false;
      });

      Get.snackbar(
        'Success',
        'Holdings synced from Dhan! Now updating prices...',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 2),
      );

      _updateAllPricesInBackground();

    } catch (e) {
      setState(() {
        _isFetchingDhan = false;
      });

      Get.snackbar(
        'Error',
        'Failed to fetch Dhan holdings: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> _updateAllPricesInBackground() async {
    final stocksWithPrices = _allHoldings.where((h) => h.symbol.isNotEmpty).toList();

    if (stocksWithPrices.isEmpty) return;

    setState(() {
      _isUpdatingPrices = true;
      _totalStocksToUpdate = stocksWithPrices.length;
      _stocksUpdated = 0;
      _currentlyUpdatingStock = '';
    });

    try {
      final alphaVantageService = AlphaVantageService();
      final portfolioService = PortfolioService();

      for (int i = 0; i < stocksWithPrices.length; i++) {
        final holding = stocksWithPrices[i];
        final remainingStocks = stocksWithPrices.length - i;
        final estimatedSeconds = remainingStocks * 12;

        setState(() {
          _currentlyUpdatingStock = holding.symbol;
          _stocksUpdated = i;
          _estimatedTimeRemaining = _formatEstimatedTime(estimatedSeconds);
        });

        try {
          print('Fetching price for ${holding.symbol}...');
          final stockQuote = await alphaVantageService.fetchStockQuote(holding.symbol);
          print('Received price ${stockQuote.currentPrice} for ${holding.symbol}');

          final updatedHolding = holding.copyWith(
            currentPrice: stockQuote.currentPrice,
            updatedAt: DateTime.now(),
          );

          if (holding.id != null) {
            await portfolioService.updateHoldingPrice(holding.id!, stockQuote.currentPrice);
          }

          setState(() {
            final allIndex = _allHoldings.indexWhere((h) => h.id == holding.id);
            if (allIndex != -1) {
              _allHoldings[allIndex] = updatedHolding;
            }

            if (updatedHolding.source == 'dhan') {
              final dhanIndex = _dhanHoldings.indexWhere((h) => h.id == holding.id);
              if (dhanIndex != -1) {
                _dhanHoldings[dhanIndex] = updatedHolding;
              }

              if (updatedHolding.isMTF == true) {
                final mtfIndex = _mtfHoldings.indexWhere((h) => h.id == holding.id);
                if (mtfIndex != -1) {
                  _mtfHoldings[mtfIndex] = updatedHolding;
                }
              }
            } else {
              final manualIndex = _manualHoldings.indexWhere((h) => h.id == holding.id);
              if (manualIndex != -1) {
                _manualHoldings[manualIndex] = updatedHolding;
              }
            }
          });

          if (i < stocksWithPrices.length - 1) {
            await Future.delayed(Duration(seconds: 12));
          }

        } catch (e) {
          print('Failed to update price for ${holding.symbol}: $e');
        }
      }

    } catch (e) {
      print('Error in price update process: $e');
    } finally {
      setState(() {
        _isUpdatingPrices = false;
        _stocksUpdated = _totalStocksToUpdate;
        _currentlyUpdatingStock = '';
        _estimatedTimeRemaining = '';
      });

      _sortHoldings();
    }
  }

  Future<void> _updateAllPrices() async {
    await _updateAllPricesInBackground();
  }

  Future<void> _onRefresh() async {
    await _updateAllPrices();
  }

  void _showActionOptions() async {
    final hasDhanCredentials = await ApiConfig.hasDhanCredentials();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: 20),

              Text(
                'Portfolio Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.iosText,
                ),
              ),

              SizedBox(height: 24),

              _buildActionTile(
                icon: Icons.add_circle_outline,
                title: 'Add Stock',
                subtitle: 'Manually add a stock to your portfolio',
                color: AppColors.iosBlue,
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Get.to(() => AddStockScreen(),
                      transition: Transition.cupertino);
                  if (result == true) {
                    _loadHoldings();
                  }
                },
              ),

              _buildActionTile(
                icon: Icons.cloud_download,
                title: 'Fetch Holdings',
                subtitle: hasDhanCredentials
                    ? 'Sync your latest holdings from Dhan'
                    : 'Setup Dhan API keys first',
                color: hasDhanCredentials ? AppColors.secondary : AppColors.iosGray,
                onTap: hasDhanCredentials && !_isFetchingDhan ? () {
                  Navigator.pop(context);
                  _fetchDhanHoldings();
                } : () {
                  Navigator.pop(context);
                  Get.snackbar(
                    'Setup Required',
                    'Please setup your Dhan API keys from Side Menu > API Keys',
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    colorText: Colors.orange,
                  );
                },
                isLoading: _isFetchingDhan,
              ),

              _buildActionTile(
                icon: Icons.refresh,
                title: 'Refresh Prices',
                subtitle: 'Update current market prices',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  _updateAllPrices();
                },
                isLoading: _isUpdatingPrices,
              ),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onTap,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    ),
                  )
                      : Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iosText,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.iosSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _waveAnimationController.dispose();
    _arrowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: _showActionOptions,
        backgroundColor: AppColors.iosBlue,
        elevation: 4,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.iosBlue,
        child: Column(
          children: [
            if (_isFetchingDhan) ...[
              Container(
                padding: EdgeInsets.all(20),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.1),
                        Colors.purple.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3 + (_waveAnimation.value * 0.4)),
                                  Colors.purple.withOpacity(0.3 + (_waveAnimation.value * 0.4)),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3 * _waveAnimation.value),
                                  blurRadius: 20 * _waveAnimation.value,
                                  spreadRadius: 5 * _waveAnimation.value,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.cloud_download,
                              color: Colors.white,
                              size: 30,
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Syncing with Dhan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue[700],
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Fetching your latest holdings...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),

                      SizedBox(height: 16),

                      AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withOpacity(0.3),
                                  Colors.blue,
                                  Colors.blue.withOpacity(0.3),
                                ],
                                stops: [
                                  0.0,
                                  _waveAnimation.value,
                                  1.0,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_isUpdatingPrices) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.red.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SlideTransition(
                            position: _arrowAnimation,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Updating Market Prices',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                if (_currentlyUpdatingStock.isNotEmpty) ...[
                                  SizedBox(height: 4),
                                  Text(
                                    'Now: $_currentlyUpdatingStock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${_stocksUpdated + 1} of $_totalStocksToUpdate',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_estimatedTimeRemaining.isNotEmpty) ...[
                                      SizedBox(width: 8),
                                      Icon(Icons.schedule, size: 12, color: Colors.orange[600]),
                                      SizedBox(width: 4),
                                      Text(
                                        _estimatedTimeRemaining,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 12),

                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: AnimatedBuilder(
                          animation: _waveAnimation,
                          builder: (context, child) {
                            final progress = _totalStocksToUpdate > 0
                                ? (_stocksUpdated + 1) / _totalStocksToUpdate
                                : 0.0;

                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.orange, Colors.red],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.iosGray,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [AppColors.iosBlue, AppColors.iosBlue.withOpacity(0.8)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.iosBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: [
                  Container(height: 50, child: Center(child: Text('All (${_allHoldings.length})'))),
                  Container(height: 50, child: Center(child: Text('Dhan (${_dhanHoldings.length})'))),
                  Container(height: 50, child: Center(child: Text('MTF (${_mtfHoldings.length})'))),
                  Container(height: 50, child: Center(child: Text('Manual (${_manualHoldings.length})'))),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('Sort by:', style: TextStyle(fontSize: 14, color: AppColors.iosGray)),
                  SizedBox(width: 8),
                  _buildSortButton('Name', 'name'),
                  SizedBox(width: 8),
                  _buildSortButton('Invested', 'invested'),
                  SizedBox(width: 8),
                  _buildSortButton('P&L', 'pnl'),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: AppColors.iosBlue,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _isAscending = !_isAscending);
                      _sortHoldings();
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHoldingsList(_allHoldings, showSections: true),
                  _buildHoldingsList(_dhanHoldings),
                  _buildHoldingsList(_mtfHoldings, showMTF: true),
                  _buildHoldingsList(_manualHoldings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(String title, String sortBy) {
    final isSelected = _sortBy == sortBy;
    return GestureDetector(
      onTap: () {
        setState(() => _sortBy = sortBy);
        _sortHoldings();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.iosBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.iosBlue : AppColors.iosSeparator),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.iosBlue.withOpacity(0.2), blurRadius: 4, offset: Offset(0, 2))] : null,
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.iosText, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHoldingsList(List<HoldingModel> holdings, {bool showSections = false, bool showMTF = false}) {
    if (holdings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
              child: Icon(Icons.pie_chart_outline, size: 50, color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text('No holdings found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Tap the + button to add stocks', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    if (showSections) {
      return _buildSectionedList(holdings);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: holdings.length,
      itemBuilder: (context, index) => _buildStockItem(holdings[index], showMTF: showMTF),
    );
  }

  Widget _buildSectionedList(List<HoldingModel> holdings) {
    Map<String, List<HoldingModel>> sections = {
      'Dhan Holdings': holdings.where((h) => h.source == 'dhan').toList(),
      'Manual Holdings': holdings.where((h) => h.source == 'manual').toList(),
    };

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sections.keys.length,
      itemBuilder: (context, index) {
        String sectionTitle = sections.keys.elementAt(index);
        List<HoldingModel> sectionHoldings = sections[sectionTitle]!;

        if (sectionHoldings.isEmpty) return SizedBox.shrink();

        bool isCollapsed = _collapsedSections.contains(sectionTitle);

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isCollapsed) {
                    _collapsedSections.remove(sectionTitle);
                  } else {
                    _collapsedSections.add(sectionTitle);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.iosBlue.withOpacity(0.1), AppColors.iosBlue.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.iosBlue, borderRadius: BorderRadius.circular(10)),
                      child: Icon(sectionTitle.contains('Dhan') ? Icons.cloud : Icons.person, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sectionTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.iosText)),
                          Text('${sectionHoldings.length} stocks', style: TextStyle(fontSize: 12, color: AppColors.iosSecondaryText)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.iosBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(isCollapsed ? Icons.expand_more : Icons.expand_less, color: AppColors.iosBlue),
                    ),
                  ],
                ),
              ),
            ),
            if (!isCollapsed) ...[
              SizedBox(height: 8),
              ...sectionHoldings.map((holding) => _buildStockItem(holding)).toList(),
            ],
            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildStockItem(HoldingModel holding, {bool showMTF = false}) {
    bool isExpanded = _expandedStocks[holding.symbol] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.iosBlue, AppColors.iosBlue.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  holding.symbol.length >= 2 ? holding.symbol.substring(0, 2) : holding.symbol,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(holding.symbol, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.iosText)),
                if (showMTF || holding.isMTF == true) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('MTF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
              ],
            ),
            subtitle: Text('${holding.formattedQuantity} shares', style: TextStyle(fontSize: 14, color: AppColors.iosSecondaryText)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(holding.formattedCurrentPrice, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.iosText)),
                Text(holding.formattedPnLPercent, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: holding.pnlColor)),
              ],
            ),
            onTap: () {
              setState(() => _expandedStocks[holding.symbol] = !isExpanded);
            },
          ),
          if (isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Stock Name', holding.name),
                  _buildDetailRow('Days Held', holding.formattedHoldingPeriod),
                  _buildDetailRow('Bought At', holding.formattedAvgPrice),
                  _buildDetailRow('Current Price', holding.formattedCurrentPrice),
                  _buildDetailRow('Invested Amount', holding.formattedInvestedAmount),
                  _buildDetailRow('Current Value', holding.formattedCurrentValue),
                  _buildDetailRow('P&L', '${holding.formattedPnL} (${holding.formattedPnLPercent})', color: holding.pnlColor),
                  if (holding.isMTF) _buildDetailRow('Funding Type', 'Margin Trading Facility (MTF)', color: Colors.orange),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: AppColors.iosSecondaryText)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color ?? AppColors.iosText)),
        ],
      ),
    );
  }
}
