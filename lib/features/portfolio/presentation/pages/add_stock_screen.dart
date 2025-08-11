import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/alpha_vantage_service.dart';
import '../../../../core/services/portfolio_service.dart';
import '../../../../core/config/api_config.dart';

class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _stockNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _buyDateController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _sellDateController = TextEditingController();
  final TextEditingController _sellQuantityController = TextEditingController();

  final AlphaVantageService _alphaVantageService = AlphaVantageService();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasAlphaVantageKey = false;
  String _selectedSymbol = '';
  String _selectedName = '';
  String _selectedAction = 'Buy'; // 'Buy' or 'Sell'

  // Validation error states
  Map<String, bool> _fieldErrors = {
    'stockName': false,
    'quantity': false,
    'buyPrice': false,
    'buyDate': false,
    'sellPrice': false,
    'sellDate': false,
    'sellQuantity': false,
  };

  Map<String, String> _errorMessages = {
    'stockName': 'Please select a stock',
    'quantity': 'Please enter quantity',
    'buyPrice': 'Please enter buy price',
    'buyDate': 'Please select buy date',
    'sellPrice': 'Please enter sell price',
    'sellDate': 'Please select sell date',
    'sellQuantity': 'Please enter sell quantity',
  };

  @override
  void initState() {
    super.initState();
    _checkAlphaVantageKey();
    _setupControllers();
  }

  void _checkAlphaVantageKey() async {
    final hasKey = await ApiConfig.hasAlphaVantageKey();
    setState(() {
      _hasAlphaVantageKey = hasKey;
    });
  }

  void _setupControllers() {
    _stockNameController.addListener(() {
      _clearFieldError('stockName');
      if (_stockNameController.text.length > 2) {
        _searchStocks(_stockNameController.text);
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });

    _quantityController.addListener(() => _clearFieldError('quantity'));
    _buyPriceController.addListener(() => _clearFieldError('buyPrice'));
    _buyDateController.addListener(() => _clearFieldError('buyDate'));
    _sellPriceController.addListener(() => _clearFieldError('sellPrice'));
    _sellDateController.addListener(() => _clearFieldError('sellDate'));
    _sellQuantityController.addListener(() => _clearFieldError('sellQuantity'));
  }

  void _clearFieldError(String field) {
    if (_fieldErrors[field] == true) {
      setState(() {
        _fieldErrors[field] = false;
      });
    }
  }

  void _searchStocks(String query) async {
    if (!_hasAlphaVantageKey || query.length < 3) return;

    setState(() {
      _isSearching = true;
    });

    try {
      // Use the Alpha Vantage service to search
      final results = await _alphaVantageService.searchSymbols(query);
      print('Search results: $results'); // Debug print

      setState(() {
        _searchResults = results.take(10).toList(); // Limit to 10 results
        _isSearching = false;
      });
    } catch (e) {
      print('Search error: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectStock(Map<String, dynamic> stock) {
    final symbol = stock['1. symbol']?.toString().replaceAll('.BSE', '') ?? '';
    final name = stock['2. name']?.toString() ?? '';

    setState(() {
      _selectedSymbol = symbol;
      _selectedName = name;
      _stockNameController.text = '$symbol - $name';
      _searchResults = [];
    });
  }

  bool _validateForm() {
    bool isValid = true;

    // Reset all errors
    _fieldErrors.updateAll((key, value) => false);

    // Check stock selection
    if (_selectedSymbol.isEmpty) {
      _fieldErrors['stockName'] = true;
      isValid = false;
    }

    if (_selectedAction == 'Buy') {
      // Buy validation
      if (_quantityController.text.trim().isEmpty ||
          double.tryParse(_quantityController.text) == null ||
          double.parse(_quantityController.text) <= 0) {
        _fieldErrors['quantity'] = true;
        isValid = false;
      }

      if (_buyPriceController.text.trim().isEmpty ||
          double.tryParse(_buyPriceController.text) == null ||
          double.parse(_buyPriceController.text) <= 0) {
        _fieldErrors['buyPrice'] = true;
        isValid = false;
      }

      if (_buyDateController.text.trim().isEmpty) {
        _fieldErrors['buyDate'] = true;
        isValid = false;
      }
    } else {
      // Sell validation
      if (_sellQuantityController.text.trim().isEmpty ||
          double.tryParse(_sellQuantityController.text) == null ||
          double.parse(_sellQuantityController.text) <= 0) {
        _fieldErrors['sellQuantity'] = true;
        isValid = false;
      }

      if (_sellPriceController.text.trim().isEmpty ||
          double.tryParse(_sellPriceController.text) == null ||
          double.parse(_sellPriceController.text) <= 0) {
        _fieldErrors['sellPrice'] = true;
        isValid = false;
      }

      if (_sellDateController.text.trim().isEmpty) {
        _fieldErrors['sellDate'] = true;
        isValid = false;
      }
    }

    setState(() {});
    return isValid;
  }

  @override
  void dispose() {
    _stockNameController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    _buyDateController.dispose();
    _sellPriceController.dispose();
    _sellDateController.dispose();
    _sellQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosBackground,
      appBar: AppBar(
        title: Text('${_selectedAction} Stock'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.iosText,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasAlphaVantageKey) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alpha Vantage API key is required for stock search. Please configure it in Settings.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Action Selection (Buy/Sell)
            Text(
              'Action *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.iosText,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAction = 'Buy';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedAction == 'Buy' ? Colors.green : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAction == 'Buy' ? Colors.green : AppColors.iosSeparator,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: _selectedAction == 'Buy' ? Colors.white : Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Buy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedAction == 'Buy' ? Colors.white : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAction = 'Sell';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedAction == 'Sell' ? Colors.red : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAction == 'Sell' ? Colors.red : AppColors.iosSeparator,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.remove_circle,
                            color: _selectedAction == 'Sell' ? Colors.white : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Sell',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _selectedAction == 'Sell' ? Colors.white : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Stock Name with Autocomplete
            _buildStockSearchField(),

            SizedBox(height: 16),

            // Fields based on action
            if (_selectedAction == 'Buy') ...[
              // Buy fields
              _buildTextField(
                controller: _quantityController,
                label: 'Quantity *',
                hint: 'Number of shares to buy',
                keyboardType: TextInputType.number,
                enabled: true,
                hasError: _fieldErrors['quantity'] ?? false,
                errorMessage: _errorMessages['quantity']!,
              ),

              SizedBox(height: 16),

              _buildTextField(
                controller: _buyPriceController,
                label: 'Buy Price *',
                hint: '₹0.00',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: true,
                hasError: _fieldErrors['buyPrice'] ?? false,
                errorMessage: _errorMessages['buyPrice']!,
              ),

              SizedBox(height: 16),

              _buildDateField(
                controller: _buyDateController,
                label: 'Buy Date *',
                enabled: true,
                hasError: _fieldErrors['buyDate'] ?? false,
                errorMessage: _errorMessages['buyDate']!,
              ),
            ] else ...[
              // Sell fields
              _buildTextField(
                controller: _sellQuantityController,
                label: 'Sell Quantity *',
                hint: 'Number of shares to sell',
                keyboardType: TextInputType.number,
                enabled: true,
                hasError: _fieldErrors['sellQuantity'] ?? false,
                errorMessage: _errorMessages['sellQuantity']!,
              ),

              SizedBox(height: 16),

              _buildTextField(
                controller: _sellPriceController,
                label: 'Sell Price *',
                hint: '₹0.00',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: true,
                hasError: _fieldErrors['sellPrice'] ?? false,
                errorMessage: _errorMessages['sellPrice']!,
              ),

              SizedBox(height: 16),

              _buildDateField(
                controller: _sellDateController,
                label: 'Sell Date *',
                enabled: true,
                hasError: _fieldErrors['sellDate'] ?? false,
                errorMessage: _errorMessages['sellDate']!,
              ),
            ],

            SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.iosGray.withOpacity(0.2),
                        foregroundColor: AppColors.iosText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedAction == 'Buy' ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '${_selectedAction} Stock',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Name *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _stockNameController,
            enabled: _hasAlphaVantageKey,
            decoration: InputDecoration(
              hintText: _hasAlphaVantageKey ? 'Search for stocks...' : 'Alpha Vantage key required',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _isSearching
                  ? Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : null,
              filled: true,
              fillColor: _hasAlphaVantageKey ? Colors.white : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (_fieldErrors['stockName'] ?? false) ? Colors.red : AppColors.iosSeparator,
                  width: (_fieldErrors['stockName'] ?? false) ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (_fieldErrors['stockName'] ?? false) ? Colors.red : AppColors.iosSeparator,
                  width: (_fieldErrors['stockName'] ?? false) ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (_fieldErrors['stockName'] ?? false) ? Colors.red : AppColors.iosBlue,
                  width: 2,
                ),
              ),
            ),
          ),
        ),

        // Search Results
        if (_searchResults.isNotEmpty) ...[
          SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.iosSeparator),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final stock = _searchResults[index];
                final symbol = stock['1. symbol']?.toString().replaceAll('.BSE', '') ?? '';
                final name = stock['2. name']?.toString() ?? '';

                return ListTile(
                  title: Text(symbol, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => _selectStock(stock),
                  trailing: Icon(Icons.add_circle_outline, color: AppColors.iosBlue),
                );
              },
            ),
          ),
        ],

        if (_fieldErrors['stockName'] ?? false) ...[
          SizedBox(height: 4),
          Text(
            _errorMessages['stockName']!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    required bool enabled,
    required bool hasError,
    required String errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.iosSeparator,
                  width: hasError ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.iosSeparator,
                  width: hasError ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : AppColors.iosBlue,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.iosSeparator.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    required bool hasError,
    required String errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.iosText,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? () => _selectDate(controller) : null,
          child: AbsorbPointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: 'Select date',
                  suffixIcon: Icon(
                    Icons.calendar_today,
                    color: enabled ? (hasError ? Colors.red : AppColors.iosBlue) : AppColors.iosGray,
                  ),
                  filled: true,
                  fillColor: enabled ? Colors.white : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : AppColors.iosSeparator,
                      width: hasError ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : AppColors.iosSeparator,
                      width: hasError ? 2 : 1,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.iosSeparator.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.iosBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.iosText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void _submitForm() async {
    if (!_validateForm()) {
      return;
    }

    try {
      final portfolioService = PortfolioService();

      if (_selectedAction == 'Buy') {
        await portfolioService.addManualHolding(
          symbol: _selectedSymbol,
          name: _selectedName.isNotEmpty ? _selectedName : _selectedSymbol,
          quantity: double.parse(_quantityController.text),
          avgPrice: double.parse(_buyPriceController.text),
        );

        Get.snackbar(
          'Success',
          'Stock purchased successfully!',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        // Handle sell logic here - you can implement this based on your requirements
        Get.snackbar(
          'Success',
          'Stock sold successfully!',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to ${_selectedAction.toLowerCase()} stock: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
