import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../../../core/constants/colors.dart';

class PortfolioCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate card height based on screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.28; // 28% of screen height

    return Container(
      margin: EdgeInsets.all(16),
      height: cardHeight.clamp(200.0, 250.0), // Min 200, Max 250
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: _buildFrontCard(),
        back: _buildBackCard(),
      ),
    );
  }

  /// Front Side - Current Portfolio Value
  Widget _buildFrontCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Color(0xFF0D1F14)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "CURRENT PORTFOLIO VALUE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              FittedBox(
                child: Text(
                  "₹ 2.73 L",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 6),
              Wrap(
                children: [
                  Text(
                      "1 day return: ",
                      style: TextStyle(color: Colors.white70, fontSize: 13)
                  ),
                  Text(
                      "₹2,001.6",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  Icon(Icons.arrow_upward, color: Colors.green, size: 12),
                  Text(
                      " 0.7%",
                      style: TextStyle(color: Colors.green, fontSize: 13)
                  ),
                ],
              ),
            ],
          ),

          // Middle Section
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildIndicator("Invested", "₹2.31 L", Colors.white),
                  ),
                  Container(width: 1, height: 20, color: Colors.white24),
                  Expanded(
                    child: _buildIndicator("Total P&L", "₹41.8 K (18.1%)", Colors.green),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Divider(color: Colors.white24, thickness: 0.5),
              SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white70, size: 14),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "Holdings up to date",
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Refresh functionality
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, color: Colors.orange, size: 14),
                        SizedBox(width: 4),
                        Text(
                            "Refresh",
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Back Side - CAGR & XIRR
  Widget _buildBackCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Color(0xFF0D1F14)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "PORTFOLIO PERFORMANCE",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          Row(
            children: [
              Expanded(
                child: _buildPerformanceIndicator("CAGR", "12.5%", Colors.green),
              ),
              Container(width: 1, height: 60, color: Colors.white24),
              Expanded(
                child: _buildPerformanceIndicator("XIRR", "14.2%", Colors.green),
              ),
            ],
          ),

          Column(
            children: [
              Center(
                child: Icon(Icons.flip, color: Colors.white70, size: 20),
              ),
              SizedBox(height: 4),
              Center(
                child: Text(
                  "Tap to flip back",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Reusable Indicator Widget for Front Card
  Widget _buildIndicator(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Performance Indicator Widget for Back Card
  Widget _buildPerformanceIndicator(String label, String value, Color color) {
    return Column(
      children: [
        Icon(Icons.trending_up, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}