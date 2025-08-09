import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/portfolio_service.dart';
import '../widgets/portfolio_card.dart';

class HoldingsSummaryScreen extends StatefulWidget {
  @override
  _HoldingsSummaryScreenState createState() => _HoldingsSummaryScreenState();
}

class _HoldingsSummaryScreenState extends State<HoldingsSummaryScreen> {
  List<dynamic> holdings = [];
  Map<String, dynamic> portfolioSummary = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  void _loadPortfolioData() async {
    setState(() => isLoading = true);

    try {
      final portfolioService = PortfolioService();
      final holdingsList = await portfolioService.getAllHoldings();
      final summary = await portfolioService.getPortfolioSummary();

      setState(() {
        holdings = holdingsList;
        portfolioSummary = summary;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading portfolio data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Card - This will show real data now
          PortfolioCard(),

          if (isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
          // Holdings breakdown
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Holdings Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iosText,
                    ),
                  ),

                  SizedBox(height: 12),

                  if (holdings.isEmpty)
                    Container(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey[400]),
                            SizedBox(height: 16),
                            Text(
                              'No holdings to display',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                  // Holdings list
                    ...holdings.map((holding) => _buildHoldingItem(holding)).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(dynamic holding) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iosBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                holding.symbol.substring(0, 2),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.iosBlue,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                Text(
                  '${holding.quantity} shares',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.iosSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${holding.currentValue.toStringAsFixed(0)}',
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
        ],
      ),
    );
  }
}
