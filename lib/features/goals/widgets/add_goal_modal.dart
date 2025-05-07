import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class AddGoalModal extends StatefulWidget {
  final VoidCallback onGoalAdded;

  const AddGoalModal({Key? key, required this.onGoalAdded}) : super(key: key);

  @override
  State<AddGoalModal> createState() => _AddGoalModalState();
}

class _AddGoalModalState extends State<AddGoalModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _targetDate;
  bool _isLoading = false;
  final _supabaseService = SupabaseService();

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();
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
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
    );
    
    if (picked != null && mounted) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  // Create goal
  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final goalData = {
        'id': const Uuid().v4(),
        'title': _titleController.text.trim(),
        'target_amount': _parseCurrency(_targetAmountController.text),
        'current_amount': 0.0,
        'description': _descriptionController.text.trim(),
        'target_date': _targetDate?.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
      };

      await _supabaseService.createGoal(goalData);
      
      if (mounted) {
        widget.onGoalAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create goal: $e'),
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
                    'Add New Goal',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Title field
              CustomTextField(
                controller: _titleController,
                hintText: 'Goal Title',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Target amount field
              CustomTextField(
                controller: _targetAmountController,
                hintText: 'Target Amount',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target amount';
                  }
                  if (_parseCurrency(value) <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
                onChanged: (value) {
                  final formatted = _formatCurrency(value);
                  if (formatted != value) {
                    _targetAmountController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Description (optional)',
                prefixIcon: Icons.description,
                maxLines: 3,
              ),
              
              const SizedBox(height: 16),
              
              // Target date field
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Target Date (optional)',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                  ),
                  child: Text(
                    _targetDate == null
                        ? 'Select a target date'
                        : DateFormat('d MMMM y').format(_targetDate!),
                    style: _targetDate == null
                        ? TextStyle(color: Colors.grey[600])
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Create button
              if (!isKeyboardVisible)
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isLoading ? null : _createGoal,
                    text: 'Create Goal',
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