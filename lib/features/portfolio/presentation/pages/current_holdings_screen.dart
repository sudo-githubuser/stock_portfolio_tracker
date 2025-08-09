import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/portfolio_service.dart';
import 'add_stock_screen.dart';

class CurrentHoldingsScreen extends StatefulWidget {
  @override
  _CurrentHoldingsScreenState createState() => _CurrentHoldingsScreenState();
}

class _CurrentHoldingsScreenState extends State<CurrentHoldingsScreen> {
  bool _isFetching = false;
  List<dynamic> holdings = [];

  @override
  void initState() {
    super.initState();
    _loadHoldings();
  }

  void _loadHoldings() async {
    final portfolioService = PortfolioService();
    final holdingsList = await portfolioService.getAllHoldings();
    setState(() {
      holdings = holdingsList;
    });
  }

  void _fetchDhanHoldings() async {
    setState(() => _isFetching = true);

    try {
      final portfolioService = PortfolioService();
      await portfolioService.syncDhanHoldings();

      // Reload holdings
      _loadHoldings();

      Get.snackbar(
        'Success',
        'Successfully fetched and updated your holdings from Dhan!',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch Dhan holdings: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      setState(() => _isFetching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buttons section
          FutureBuilder<bool>(
            future: ApiConfig.hasDhanCredentials(),
            builder: (context, snapshot) {
              final hasDhanCredentials = snapshot.data ?? false;

              if (hasDhanCredentials) {
                // Show Dhan fetch option with message
                return Column(
                  children: [
                    // Info message
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You have provided your Dhan access token and client ID, click to fetch your Dhan holdings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    // Buttons row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => AddStockScreen(),
                                    transition: Transition.cupertino);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.iosBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Add Stock',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isFetching ? null : _fetchDhanHoldings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isFetching
                                  ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_download, size: 18),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Fetch Holdings',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Show regular buttons with message to setup API keys
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => AddStockScreen(),
                                    transition: Transition.cupertino);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.iosBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, size: 18),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Add Stock',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Get.snackbar(
                                  'Setup Required',
                                  'Please setup your Dhan API keys from Side Menu > API Keys',
                                  backgroundColor: Colors.orange.withOpacity(0.1),
                                  colorText: Colors.orange,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.iosGray,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_download, size: 18),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Fetch Holdings',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'To fetch holdings from Dhan, please setup your API keys from Side Menu > API Keys',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),

          SizedBox(height: 20),

          Text(
            'Current Holdings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.iosText,
            ),
          ),

          SizedBox(height: 12),

          // Holdings list
          Expanded(
            child: holdings.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No holdings found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Add stocks manually or fetch from Dhan',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: holdings.length,
              itemBuilder: (context, index) {
                final holding = holdings[index];
                return _buildStockItem(holding);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(dynamic holding) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.iosBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              holding.symbol.substring(0, 2),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosBlue,
              ),
            ),
          ),
        ),
        title: Text(
          holding.symbol,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        subtitle: Text(
          '${holding.quantity} shares',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.iosSecondaryText,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${holding.currentPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosText,
              ),
            ),
            Text(
              '${holding.pnl >= 0 ? '+' : ''}${holding.pnlPercent.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: holding.pnl >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to stock details
        },
      ),
    );
  }
}
