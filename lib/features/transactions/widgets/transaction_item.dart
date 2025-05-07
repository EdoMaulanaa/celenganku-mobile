import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/supabase_service.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDeleted;

  const TransactionItem({
    Key? key,
    required this.transaction,
    required this.onDeleted,
  }) : super(key: key);

  // Format currency
  String _formatCurrency(double amount) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount);
  }

  // Format date
  String _formatDate(DateTime date) {
    return DateFormat('d MMM y, HH:mm').format(date);
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This will also reduce the goal\'s current amount.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await SupabaseService().deleteTransaction(
          transaction.id,
          transaction.goalId,
          transaction.amount,
        );
        onDeleted();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.savings_outlined,
            color: Colors.green,
          ),
        ),
        title: Text(
          _formatCurrency(transaction.amount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(transaction.date)),
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Text(
                transaction.note!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteTransaction(context),
        ),
      ),
    );
  }
} 