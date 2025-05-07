import 'package:flutter/material.dart';
import '../../../core/models/onboarding_item.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder until we have real images
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getIconForImage(item.imagePath),
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Helper method to show different icons for different onboarding pages
  IconData _getIconForImage(String imagePath) {
    if (imagePath.contains('goals')) {
      return Icons.flag_outlined;
    } else if (imagePath.contains('transactions')) {
      return Icons.savings_outlined;
    } else if (imagePath.contains('progress')) {
      return Icons.bar_chart_outlined;
    }
    return Icons.info_outline;
  }
} 