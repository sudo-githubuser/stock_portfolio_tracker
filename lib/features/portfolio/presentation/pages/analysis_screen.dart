import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio Analysis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.iosText,
            ),
          ),

          SizedBox(height: 20),

          // Chart container
          Container(
            height: 250,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio Performance (30 Days)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.iosText,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateSpots(),
                          isCurved: true,
                          color: AppColors.iosBlue,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.iosBlue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Analysis cards - FIXED: Using proper layout
          SizedBox(
            height: 300, // Fixed height for grid
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              physics: NeverScrollableScrollPhysics(), // Disable grid scrolling
              children: [
                _buildAnalysisCard(
                  title: 'Diversification',
                  value: '85%',
                  subtitle: 'Well diversified',
                  color: Colors.green,
                ),
                _buildAnalysisCard(
                  title: 'Risk Level',
                  value: 'Medium',
                  subtitle: 'Balanced portfolio',
                  color: Colors.orange,
                ),
                _buildAnalysisCard(
                  title: 'Best Performer',
                  value: 'AAPL',
                  subtitle: '+12.5% this month',
                  color: AppColors.iosBlue,
                ),
                _buildAnalysisCard(
                  title: 'Total Return',
                  value: '8.9%',
                  subtitle: 'Last 12 months',
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < 30; i++) {
      spots.add(FlSpot(i.toDouble(), 100 + (i * 2) + (i % 5) * 10));
    }
    return spots;
  }

  Widget _buildAnalysisCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12), // Reduced padding
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13, // Reduced font size
                    color: AppColors.iosSecondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18, // Reduced font size
              fontWeight: FontWeight.w700,
              color: AppColors.iosText,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11, // Reduced font size
              color: AppColors.iosSecondaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
