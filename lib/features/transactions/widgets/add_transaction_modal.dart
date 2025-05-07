import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class AddTransactionModal extends StatefulWidget {
  final String goalId;
  final VoidCallback onTransactionAdded;

  const AddTransactionModal({
    Key? key,
    required this.goalId,
    required this.onTransactionAdded,
  }) : super(key: key);

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _transactionDate = DateTime.now();
  bool _isLoading = false;
  final _supabaseService = SupabaseService();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Format for amount input display
  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    
    // Remove non-digits
    final onlyDigits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (onlyDigits.isEmpty) return '';
    
    // Convert to double
    final amount = double.parse(onlyDigits);
    
    // Format as currency
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(amount);
  }

  // Parse formatted currency back to double
  double _parseCurrency(String value) {
    if (value.isEmpty) return 0;
    
    // Remove non-digits
    final onlyDigits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (onlyDigits.isEmpty) return 0;
    
    // Convert to double
    return double.parse(onlyDigits);
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && mounted) {
      setState(() {
        _transactionDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _transactionDate.hour,
          _transactionDate.minute,
        );
      });
    }
  }

  // Show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_transactionDate),
    );
    
    if (picked != null && mounted) {
      setState(() {
        _transactionDate = DateTime(
          _transactionDate.year,
          _transactionDate.month,
          _transactionDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  // Create transaction
  Future<void> _createTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final transactionData = {
        'id': const Uuid().v4(),
        'amount': _parseCurrency(_amountController.text),
        'note': _noteController.text.trim(),
        'date': _transactionDate.toIso8601String(),
        'goal_id': widget.goalId,
        'user_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.createTransaction(transactionData);
      
      if (mounted) {
        widget.onTransactionAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Transaction',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Amount field
              CustomTextField(
                controller: _amountController,
                hintText: 'Amount',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (_parseCurrency(value) <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
                onChanged: (value) {
                  final formatted = _formatCurrency(value);
                  if (formatted != value) {
                    _amountController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Note field
              CustomTextField(
                controller: _noteController,
                hintText: 'Note (optional)',
                prefixIcon: Icons.note,
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // Date picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  child: Text(
                    DateFormat('d MMMM y').format(_transactionDate),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Time picker
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  child: Text(
                    DateFormat('HH:mm').format(_transactionDate),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Add button
              if (!isKeyboardVisible)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isLoading ? null : _createTransaction,
                    text: 'Add Transaction',
                    isLoading: _isLoading,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 