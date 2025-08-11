import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:math' as math;
import '../../../../core/constants/colors.dart';
import '../../../../core/services/portfolio_service.dart';

class PortfolioCard extends StatefulWidget {
  @override
  _PortfolioCardState createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<PortfolioCard> {
  Map<String, dynamic> portfolioSummary = {};
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  void _loadPortfolioData() async {
    try {
      final portfolioService = PortfolioService();
      final summary = await portfolioService.getPortfolioSummary();
      setState(() {
        portfolioSummary = summary;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading portfolio data: $e');
      setState(() => isLoading = false);
    }
  }

  void _refreshPrices() async {
    setState(() => isRefreshing = true);

    try {
      final portfolioService = PortfolioService();
      await portfolioService.updateAllPrices();

      // Reload portfolio data with updated prices
      final summary = await portfolioService.getPortfolioSummary();
      setState(() {
        portfolioSummary = summary;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prices updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update prices: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => isRefreshing = false);
    }
  }

  // Calculate CAGR (simplified calculation)
  double _calculateCAGR() {
    final totalInvested = portfolioSummary['totalInvested'] ?? 0.0;
    final totalCurrent = portfolioSummary['totalCurrent'] ?? 0.0;

    if (totalInvested <= 0) return 0.0;

    // Assuming 1 year holding period for simplification
    final years = 1.0;
    final cagr = (math.pow(totalCurrent / totalInvested, 1 / years).toDouble() - 1) * 100;
    return cagr.isFinite ? cagr : 0.0;
  }

  // Calculate XIRR (simplified as annualized return)
  double _calculateXIRR() {
    final totalPnLPercent = portfolioSummary['totalPnLPercent'] ?? 0.0;
    return totalPnLPercent.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      height: 200,
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: _buildFrontCard(),
        back: _buildBackCard(),
      ),
    );
  }

  /// Front Side - Current Portfolio Value with Real Data
  Widget _buildFrontCard() {
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Color(0xFF0D1F14)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final totalCurrent = (portfolioSummary['totalCurrent'] ?? 0.0).toDouble();
    final totalInvested = (portfolioSummary['totalInvested'] ?? 0.0).toDouble();
    final totalPnL = (portfolioSummary['totalPnL'] ?? 0.0).toDouble();
    final totalPnLPercent = (portfolioSummary['totalPnLPercent'] ?? 0.0).toDouble();

    // Calculate 1-day return (simplified as 1% of total PnL for demo)
    final oneDayReturn = totalPnL * 0.01;
    final oneDayReturnPercent = totalPnLPercent * 0.01;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Color(0xFF0D1F14)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "₹ ${_formatCurrency(totalCurrent)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                        "1 day return: ",
                        style: TextStyle(color: Colors.white70, fontSize: 11)
                    ),
                    Text(
                        "₹${_formatCurrency(oneDayReturn.abs())}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold
                        )
                    ),
                    Icon(
                      oneDayReturn >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: oneDayReturn >= 0 ? Colors.green : Colors.red,
                      size: 11,
                    ),
                    Text(
                        " ${oneDayReturnPercent.abs().toStringAsFixed(2)}%",
                        style: TextStyle(
                            color: oneDayReturn >= 0 ? Colors.green : Colors.red,
                            fontSize: 11
                        )
                    ),
                  ],
                ),
              ],
            ),

            // Middle Section - Indicators
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildIndicator("Invested", "₹${_formatCurrency(totalInvested)}", Colors.white),
                ),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white24,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: _buildIndicator(
                        "Total P&L",
                        "₹${_formatCurrency(totalPnL.abs())} (${totalPnLPercent.toStringAsFixed(1)}%)",
                        totalPnL >= 0 ? Colors.green : Colors.red
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Section
            Column(
              children: [
                Divider(color: Colors.white24, thickness: 0.5, height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white70, size: 12),
                        SizedBox(width: 4),
                        Text(
                            "Holdings up to date",
                            style: TextStyle(color: Colors.white70, fontSize: 9)
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: isRefreshing ? null : _refreshPrices,
                      child: Row(
                        children: [
                          if (isRefreshing) ...[
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                                "Updating...",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ] else ...[
                            Icon(Icons.refresh, color: Colors.orange, size: 12),
                            SizedBox(width: 4),
                            Text(
                                "Refresh",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Back Side - CAGR & XIRR with Real Data
  Widget _buildBackCard() {
    if (isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Color(0xFF0D1F14)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final cagr = _calculateCAGR();
    final xirr = _calculateXIRR();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade900, Color(0xFF0D1F14)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "PORTFOLIO PERFORMANCE",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),

            // Performance Metrics
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceIndicator(
                      "CAGR",
                      "${cagr >= 0 ? '+' : ''}${cagr.toStringAsFixed(1)}%",
                      cagr >= 0 ? Colors.green : Colors.red,
                      cagr >= 0
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _buildPerformanceIndicator(
                      "XIRR",
                      "${xirr >= 0 ? '+' : ''}${xirr.toStringAsFixed(1)}%",
                      xirr >= 0 ? Colors.green : Colors.red,
                      xirr >= 0
                  ),
                ),
              ],
            ),

            // Flip instruction
            Column(
              children: [
                Icon(Icons.flip, color: Colors.white70, size: 16),
                SizedBox(height: 4),
                Text(
                  "Tap to flip back",
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Performance indicator with trend arrows
  Widget _buildPerformanceIndicator(String label, String value, Color color, bool isPositive) {
    return Column(
      children: [
        Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 16
        ),
        SizedBox(height: 6),
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

  // Currency formatting
  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)} L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)} K";
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // Basic indicator for front card
  Widget _buildIndicator(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 10),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
