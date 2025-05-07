import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/models/onboarding_item.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Define onboarding items
  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Atur Tujuan Tabungan',
      description: 'Buat berbagai tujuan tabungan dengan target nominal dan waktu yang Anda inginkan.',
      imagePath: 'assets/images/onboarding_goals.png',
    ),
    OnboardingItem(
      title: 'Catat Setiap Transaksi',
      description: 'Catat setiap rupiah yang Anda tabung dan lihat perkembangannya secara real-time.',
      imagePath: 'assets/images/onboarding_transactions.png',
    ),
    OnboardingItem(
      title: 'Visualisasi Progres',
      description: 'Pantau perkembangan tabungan Anda dengan visualisasi yang menarik dan mudah dipahami.',
      imagePath: 'assets/images/onboarding_progress.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _completeOnboarding() async {
    // Use the provider to set onboarding as completed
    await ref.read(completeOnboardingProvider)();
    
    // Navigate to login screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Lewati'),
                ),
              ),
            ),
            
            // Onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPage(item: _onboardingItems[index]);
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (hidden on first page)
                  _currentPage > 0
                      ? TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Kembali'),
                        )
                      : const SizedBox(width: 80),
                  
                  // Next/Done button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingItems.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage < _onboardingItems.length - 1
                          ? 'Lanjut'
                          : 'Mulai',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 