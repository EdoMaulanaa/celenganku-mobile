import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/goal.dart';
import '../../../core/models/transaction.dart' as app_transaction;
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../transactions/widgets/add_transaction_modal.dart';
import '../../transactions/widgets/transaction_item.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;
  
  const GoalDetailScreen({
    Key? key,
    required this.goalId,
  }) : super(key: key);

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  late Future<Goal> _goalFuture;
  late Future<List<app_transaction.Transaction>> _transactionsFuture;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _goalFuture = _fetchGoal();
      _transactionsFuture = _fetchTransactions();
    });
  }

  Future<Goal> _fetchGoal() async {
    final goalData = await _supabaseService.getGoal(widget.goalId);
    return Goal.fromMap(goalData);
  }

  Future<List<app_transaction.Transaction>> _fetchTransactions() async {
    final transactionsData = await _supabaseService.getTransactions(widget.goalId);
    return transactionsData.map((data) => app_transaction.Transaction.fromMap(data)).toList();
  }

  void _showAddTransactionModal(Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionModal(
        goalId: goal.id,
        onTransactionAdded: _loadData,
      ),
    );
  }

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
    return DateFormat('d MMMM y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
      ),
      body: FutureBuilder<Goal>(
        future: _goalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }
          
          final goal = snapshot.data!;
          
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
          
          return Column(
            children: [
              // Goal details
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    
                    if (goal.description != null && goal.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        goal.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Amount and progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Amount',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _formatCurrency(goal.currentAmount),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Target Amount',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              _formatCurrency(goal.targetAmount),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: goal.progressPercentage / 100,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 12,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
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
                        if (goal.targetDate != null)
                          Text(
                            'Target date: ${_formatDate(goal.targetDate)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Add transaction button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: () => _showAddTransactionModal(goal),
                        text: 'Add Transaction',
                        icon: Icons.add,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transactions title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.history),
                    const SizedBox(width: 8),
                    Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              
              // Transactions list
              Expanded(
                child: FutureBuilder<List<app_transaction.Transaction>>(
                  future: _transactionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading transactions: ${snapshot.error}',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      );
                    }
                    
                    final transactions = snapshot.data ?? [];
                    
                    if (transactions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first transaction to start saving',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionItem(
                          transaction: transaction,
                          onDeleted: _loadData,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 