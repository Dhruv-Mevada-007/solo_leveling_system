import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // System icon
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.systemBlue, width: 1.5),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.systemBlue,
                size: 48,
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .scale(duration: 600.ms, curve: Curves.easeOut),

            const SizedBox(height: 24),

            Text(
              '[ SYSTEM ]',
              style: AppTextStyles.systemLabel.copyWith(letterSpacing: 6),
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            Text(
              'Personal System',
              style: AppTextStyles.heading1.copyWith(fontSize: 28),
            ).animate(delay: 800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

            Text(
              'Builder',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 28,
                color: AppColors.systemBlue,
              ),
            ).animate(delay: 900.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 40),

            // Loading bar
            SizedBox(
              width: 200,
              child: Column(
                children: [
                  Text(
                    'Initializing System...',
                    style: AppTextStyles.caption.copyWith(color: AppColors.systemBlue),
                  ).animate(delay: 1000.ms).fadeIn(),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.systemBlue),
                    borderRadius: BorderRadius.circular(2),
                  ).animate(delay: 1200.ms).fadeIn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
