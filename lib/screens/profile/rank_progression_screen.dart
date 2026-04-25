import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/hunter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class RankProgressionScreen extends StatelessWidget {
  final HunterRank currentRank;
  final int currentLevel;

  const RankProgressionScreen({
    super.key,
    required this.currentRank,
    required this.currentLevel,
  });

  static const _rankData = [
    _RankInfo('E', 'Novice Hunter', 'Lv. 1–9', AppColors.rankE, 'The beginning of your journey. Every master was once a beginner.'),
    _RankInfo('D', 'Awakened Hunter', 'Lv. 10–24', AppColors.rankD, 'You have awakened your potential. The path forward grows steeper.'),
    _RankInfo('C', 'Seasoned Hunter', 'Lv. 25–39', AppColors.rankC, 'Veterans who have proven themselves in the field of self-improvement.'),
    _RankInfo('B', 'Elite Hunter', 'Lv. 40–59', AppColors.rankB, 'The elite. Discipline has become second nature to you.'),
    _RankInfo('A', 'Master Hunter', 'Lv. 60–79', AppColors.rankA, 'You stand among the few who have truly mastered themselves.'),
    _RankInfo('S', 'Shadow Monarch', 'Lv. 80+', AppColors.rankS, 'The pinnacle of human achievement. You have surpassed all limits.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const SystemLabel('[ RANK PROGRESSION ]'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Text('Hunter Ranks', style: AppTextStyles.heading1),
          const SizedBox(height: 4),
          Text('Your current rank: ${currentRank.name.toUpperCase()}',
              style: AppTextStyles.body.copyWith(color: AppColors.systemBlue)),
          const SizedBox(height: 20),
          ..._rankData.asMap().entries.map((entry) {
            final i = entry.key;
            final rank = entry.value;
            final isCurrent = rank.label == currentRank.name.toUpperCase();
            final isPast = _rankIndex(currentRank) > i;

            return _RankCard(
              rank: rank,
              isCurrent: isCurrent,
              isPast: isPast,
              currentLevel: currentLevel,
              index: i,
            );
          }),
        ],
      ),
    );
  }

  int _rankIndex(HunterRank r) => HunterRank.values.indexOf(r);
}

class _RankCard extends StatelessWidget {
  final _RankInfo rank;
  final bool isCurrent;
  final bool isPast;
  final int currentLevel;
  final int index;

  const _RankCard({
    required this.rank,
    required this.isCurrent,
    required this.isPast,
    required this.currentLevel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = isPast ? 0.6 : (isCurrent ? 1.0 : 0.35);

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? rank.color.withAlpha(20)
              : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? rank.color : AppColors.border,
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank.color.withAlpha(25),
                border: Border.all(color: rank.color, width: 1.5),
              ),
              child: Center(
                child: Text(
                  rank.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: rank.color,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(rank.name, style: AppTextStyles.heading2.copyWith(
                        fontSize: 15, color: rank.color,
                      )),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: rank.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: rank.color.withAlpha(80)),
                          ),
                          child: Text('CURRENT', style: TextStyle(
                            fontSize: 9, color: rank.color, fontWeight: FontWeight.w600,
                          )),
                        ),
                      ],
                      if (isPast) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.check_circle_rounded, size: 14, color: rank.color),
                      ],
                    ],
                  ),
                  Text(rank.levelRange, style: AppTextStyles.caption),
                  const SizedBox(height: 4),
                  Text(rank.description, style: AppTextStyles.body.copyWith(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 300.ms).slideX(begin: -0.05);
  }
}

class _RankInfo {
  final String label;
  final String name;
  final String levelRange;
  final Color color;
  final String description;

  const _RankInfo(this.label, this.name, this.levelRange, this.color, this.description);
}
