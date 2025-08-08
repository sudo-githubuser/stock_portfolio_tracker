import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import 'add_stock_screen.dart';
import 'dhan_login_screen.dart';

class CurrentHoldingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Two buttons side by side - FIXED OVERFLOW
          Row(
            children: [
              Expanded(
                flex: 1,
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
                      mainAxisSize: MainAxisSize.min, // FIXED: Prevents overflow
                      children: [
                        Icon(Icons.add, size: 18),
                        SizedBox(width: 6),
                        Flexible( // FIXED: Allows text to shrink if needed
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
                flex: 1,
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => DhanLoginScreen(),
                          transition: Transition.cupertino);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // FIXED: Prevents overflow
                      children: [
                        Icon(Icons.cloud_download, size: 18),
                        SizedBox(width: 6),
                        Flexible( // FIXED: Allows text to shrink if needed
                          child: Text(
                            'Fetch Holdings',
                            style: TextStyle(
                              fontSize: 12, // Made smaller to fit
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
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildStockItem(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(int index) {
    final stocks = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN'];
    final stock = stocks[index % stocks.length];

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
              stock.substring(0, 2),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosBlue,
              ),
            ),
          ),
        ),
        title: Text(
          stock,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        subtitle: Text(
          '${(index + 1) * 5} shares',
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
              '₹${(150 + index * 25).toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosText,
              ),
            ),
            Text(
              '+${(1.5 + index * 0.5).toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green,
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
