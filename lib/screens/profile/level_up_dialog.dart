import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({super.key, required this.newLevel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.systemBlue, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.systemBlue.withAlpha(50),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.systemBlue.withAlpha(30),
                border: Border.all(color: AppColors.systemBlue, width: 2),
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: AppColors.systemBlue, size: 40),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 1000.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),

            const SizedBox(height: 20),

            Text(
              '[ SYSTEM NOTIFICATION ]',
              style: AppTextStyles.systemLabel,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              'LEVEL UP!',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.systemBlue,
                fontSize: 32,
                letterSpacing: 4,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(delay: 400.ms, duration: 300.ms),

            const SizedBox(height: 8),

            Text(
              'You have reached Level $newLevel',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 4),
            Text(
              'Your stats have been upgraded.',
              style: AppTextStyles.caption,
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),

            SystemButton(
              label: 'CONTINUE',
              onTap: () => Navigator.pop(context),
              color: AppColors.systemBlue,
              width: double.infinity,
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
