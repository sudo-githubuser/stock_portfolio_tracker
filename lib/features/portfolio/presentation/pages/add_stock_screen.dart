import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/colors.dart';

class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _stockNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _buyDateController = TextEditingController();
  final TextEditingController _sellDateController = TextEditingController();

  String _selectedAction = 'Buy'; // Default to Buy
  double _grossPnL = 0.0;

  @override
  void initState() {
    super.initState();
    _setupControllers();
  }

  void _setupControllers() {
    if (_selectedAction == 'Buy') {
      _sellPriceController.clear();
      _sellDateController.clear();
    }
    // Calculate PnL when values change
    _quantityController.addListener(_calculatePnL);
    _buyPriceController.addListener(_calculatePnL);
    _sellPriceController.addListener(_calculatePnL);
  }

  void _calculatePnL() {
    if (_selectedAction == 'Sell' &&
        _quantityController.text.isNotEmpty &&
        _buyPriceController.text.isNotEmpty &&
        _sellPriceController.text.isNotEmpty) {

      double quantity = double.tryParse(_quantityController.text) ?? 0;
      double buyPrice = double.tryParse(_buyPriceController.text) ?? 0;
      double sellPrice = double.tryParse(_sellPriceController.text) ?? 0;

      setState(() {
        _grossPnL = (sellPrice - buyPrice) * quantity;
      });
    }
  }

  @override
  void dispose() {
    _stockNameController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _buyDateController.dispose();
    _sellDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.iosBackground,
      appBar: AppBar(
        title: Text('Add Stock'),
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
            // Stock Name
            _buildTextField(
              controller: _stockNameController,
              label: 'Stock Name',
              hint: 'e.g., AAPL',
              enabled: true,
            ),

            SizedBox(height: 16),

            // Quantity
            _buildTextField(
              controller: _quantityController,
              label: 'Quantity',
              hint: 'Number of shares',
              keyboardType: TextInputType.number,
              enabled: true,
            ),

            SizedBox(height: 16),

            // Action Selection
            _buildActionSelector(),

            SizedBox(height: 16),

            // Buy Price
            _buildTextField(
              controller: _buyPriceController,
              label: 'Buy Price',
              hint: '₹0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: _selectedAction == 'Buy' || _selectedAction == 'Sell',
            ),

            SizedBox(height: 16),

            // Sell Price
            _buildTextField(
              controller: _sellPriceController,
              label: 'Sell Price',
              hint: '₹0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: _selectedAction == 'Sell',
            ),

            SizedBox(height: 16),

            // Buy Date
            _buildDateField(
              controller: _buyDateController,
              label: 'Buy Date',
              enabled: _selectedAction == 'Buy' || _selectedAction == 'Sell',
            ),

            SizedBox(height: 16),

            // Sell Date
            _buildDateField(
              controller: _sellDateController,
              label: 'Sell Date',
              enabled: _selectedAction == 'Sell',
            ),

            SizedBox(height: 16),

            // Gross PnL (Auto-calculated for Sell)
            if (_selectedAction == 'Sell') ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _grossPnL >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _grossPnL >= 0 ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Gross P&L',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.iosText,
                      ),
                    ),
                    Text(
                      '₹${_grossPnL.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _grossPnL >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
            ],

            SizedBox(height: 24),

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
                        backgroundColor: AppColors.iosBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    required bool enabled,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.iosSeparator),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.iosSeparator),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.iosBlue, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.iosSeparator.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action',
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
                    _sellPriceController.clear();
                    _sellDateController.clear();
                    _grossPnL = 0.0;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedAction == 'Buy' ? AppColors.iosGreen : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAction == 'Buy' ? AppColors.iosGreen : AppColors.iosSeparator,
                    ),
                  ),
                  child: Text(
                    'Buy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedAction == 'Buy' ? Colors.white : AppColors.iosText,
                    ),
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
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedAction == 'Sell' ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedAction == 'Sell' ? Colors.red : AppColors.iosSeparator,
                    ),
                  ),
                  child: Text(
                    'Sell',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedAction == 'Sell' ? Colors.white : AppColors.iosText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
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
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: 'Select date',
                suffixIcon: Icon(Icons.calendar_today,
                    color: enabled ? AppColors.iosBlue : AppColors.iosGray),
                filled: true,
                fillColor: enabled ? Colors.white : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.iosSeparator),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.iosSeparator),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.iosSeparator.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        ),
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

  void _submitForm() {
    // Add validation and submission logic here
    if (_stockNameController.text.isEmpty || _quantityController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all required fields',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    // Success feedback
    Get.snackbar(
      'Success',
      'Stock ${_selectedAction == 'Buy' ? 'purchased' : 'sold'} successfully!',
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );

    // Go back to previous screen
    Get.back();
  }
}
