import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../widgets/portfolio_card.dart';

class HoldingsSummaryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Card - ADDED AS REQUESTED
          PortfolioCard(),

          // Rest of the existing content
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

                // Holdings list
                ...List.generate(5, (index) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: _buildHoldingItem(
                    symbol: 'AAPL',
                    name: 'Apple Inc.',
                    quantity: '10',
                    value: '₹15,000',
                    change: '+2.34%',
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingItem({
    required String symbol,
    required String name,
    required String quantity,
    required String value,
    required String change,
  }) {
    return Container(
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
                symbol.substring(0, 2),
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
                  symbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                Text(
                  '$quantity shares',
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
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.iosText,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
