import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';

class PortfolioScreen extends StatefulWidget {
  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  List<Map<String, dynamic>> portfolio = [];
  bool isLoading = false;
  String dhanClientId = 'YOUR_DHAN_CLIENT_ID';
  String dhanAccessToken = 'YOUR_DHAN_ACCESS_TOKEN';
  String alphaVantageKey = 'YOUR_ALPHA_VANTAGE_API_KEY';
  String _symbol = '';
  double _quantity = 0;

  @override
  void initState() {
    super.initState();
    loadPortfolio();
  }

  // Your existing methods here (loadPortfolio, savePortfolio, etc.)
  Future<void> loadPortfolio() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('portfolio');
    if (savedData != null) {
      setState(() {
        portfolio = List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    }
  }

  // ... (include all your existing methods here)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.portfolioTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Action buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : fetchDhanHoldings,
                  icon: isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.download),
                  label: Text(AppStrings.fetchHoldings),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),

            // Portfolio list
            Expanded(
              child: portfolio.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Your portfolio is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    Text(
                      'Add stocks or fetch holdings to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: portfolio.length,
                itemBuilder: (context, index) {
                  var stock = portfolio[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          stock['symbol'].toString().substring(0, 1),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        '${stock['symbol']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${stock['quantity']} shares'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${stock['price']?.toStringAsFixed(2) ?? 'Loading...'}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (stock['price'] != null)
                                Text(
                                  '\$${(stock['price'] * stock['quantity']).toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.show_chart, color: AppColors.primary),
                            onPressed: () => _showChart(stock['symbol']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Add stock form
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Symbol (e.g., AAPL)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      onChanged: (val) => _symbol = val.toUpperCase(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _quantity = double.tryParse(val) ?? 0,
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (_symbol.isNotEmpty && _quantity > 0) {
                        addManualStock(_symbol, _quantity);
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChart(String symbol) {
    // Add your chart showing logic here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$symbol Performance'),
        content: Container(
          height: 200,
          child: Center(child: Text('Chart will be implemented here')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Add your existing methods (fetchDhanHoldings, addManualStock, etc.) here
  Future<void> fetchDhanHoldings() async {
    setState(() => isLoading = true);
    // Your existing fetchDhanHoldings implementation
    setState(() => isLoading = false);
  }

  void addManualStock(String symbol, double quantity) async {
    // Your existing addManualStock implementation
  }
}
