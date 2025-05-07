import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/goal.dart';
import '../../../core/services/supabase_service.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const GoalCard({
    Key? key,
    required this.goal,
    required this.onTap,
    required this.onRefresh,
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
  String _formatDate(DateTime? date) {
    if (date == null) return 'No target date';
    return DateFormat('d MMM y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final remainingText = goal.isAchieved
        ? 'Goal achieved 🎉'
        : 'Remaining: ${_formatCurrency(goal.remainingAmount)}';
    
    // Progress bar color based on percentage
    Color progressColor;
    if (goal.progressPercentage >= 100) {
      progressColor = Colors.green;
    } else if (goal.progressPercentage >= 75) {
      progressColor = Colors.lightGreen;
    } else if (goal.progressPercentage >= 50) {
      progressColor = Colors.amber;
    } else if (goal.progressPercentage >= 25) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.redAccent;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await _showDeleteConfirmation(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              if (goal.description != null && goal.description!.isNotEmpty)
                Text(
                  goal.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  backgroundColor: colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 10,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Goal details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                  ),
                  Text(
                    remainingText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.savings_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _formatCurrency(goal.targetAmount),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (goal.targetDate != null) 
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(goal.targetDate),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete ${goal.title}?'),
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
        await SupabaseService().deleteGoal(goal.id);
        onRefresh();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goal deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting goal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
} 