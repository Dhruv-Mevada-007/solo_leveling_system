import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quest.dart';
import '../../models/hunter.dart';
import '../../providers/quest_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/quest/quest_card.dart';
import '../../widgets/quest/quest_form_sheet.dart';
import '../profile/level_up_dialog.dart';
import 'quest_detail_screen.dart';

class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<QuestProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.systemBlue),
          );
        }

        final hunter = provider.hunter;
        final activeQuests = provider.activeQuests;
        final penaltyQuests = provider.penaltyQuests;

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hunter header
              SliverToBoxAdapter(
                child: _HunterHeader(hunter: hunter),
              ),

              // Penalty quests (urgent)
              if (penaltyQuests.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.danger, size: 14),
                            const SizedBox(width: 6),
                            SystemLabel('[ PENALTY QUESTS ]',
                                color: AppColors.danger),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...penaltyQuests.map((q) => QuestCard(
                          quest: q,
                          onComplete: () => _completeQuest(context, provider, q.id),
                        )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

              // Active quests
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SectionHeader(
                    title: 'ACTIVE QUESTS',
                    subtitle: '${activeQuests.length} quest${activeQuests.length != 1 ? 's' : ''} remaining',
                  ),
                ),
              ),

              if (activeQuests.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppColors.success, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'All quests complete!',
                          style: AppTextStyles.heading2.copyWith(color: AppColors.success),
                        ),
                        const SizedBox(height: 6),
                        Text('Add new quests to continue your journey',
                            style: AppTextStyles.body),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final q = activeQuests[i];
                        return QuestCard(
                          key: ValueKey(q.id),
                          quest: q,
                          onComplete: () => _completeQuest(context, provider, q.id),
                          onFail: () => _failQuest(context, provider, q.id),
                          onTap: () => _showQuestDetail(context, q),
                        );
                      },
                      childCount: activeQuests.length,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: _AddQuestFab(),
        );
      },
    );
  }

  Future<void> _completeQuest(BuildContext context, QuestProvider provider, String id) async {
    final result = await provider.completeQuest(id);
    if (!context.mounted) return;

    if (result.didLevelUp) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(newLevel: result.newLevel),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: AppColors.systemBlue, size: 16),
              const SizedBox(width: 8),
              Text('Quest Complete! XP earned.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.success, width: 1),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _failQuest(BuildContext context, QuestProvider provider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _FailConfirmDialog(),
    );
    if (confirmed == true) {
      await provider.failQuest(id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quest failed. Penalty task spawned.',
              style: AppTextStyles.body.copyWith(color: AppColors.danger)),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.danger, width: 1),
          ),
        ),
      );
    }
  }

  void _showQuestDetail(BuildContext context, Quest quest) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestDetailScreen(quest: quest)),
    );
  }
}

class _AddQuestFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const QuestFormSheet(),
        );
      },
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.systemBlueDim,
          border: Border.all(color: AppColors.systemBlue, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.systemBlue.withAlpha(60),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .custom(
          duration: 2000.ms,
          builder: (_, v, child) => Transform.scale(scale: 1 + v * 0.03, child: child),
        );
  }
}

class _FailConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgSecondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.danger, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text('Mark as Failed?', style: AppTextStyles.heading2.copyWith(color: AppColors.danger)),
            const SizedBox(height: 8),
            Text(
              'This will mark the quest as failed and may spawn a penalty task. The system does not forgive weakness.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger.withAlpha(40),
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    child: const Text('CONFIRM FAIL'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HunterHeader extends StatelessWidget {
  final Hunter hunter;

  const _HunterHeader({required this.hunter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SystemLabel('[ DAILY QUEST BOARD ]'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.systemBlueGlow,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.systemBlue.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.systemBlue, shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text('SYSTEM ONLINE', style: AppTextStyles.caption.copyWith(
                          color: AppColors.systemBlue, fontSize: 10,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Active Missions', style: AppTextStyles.heading1),
                  const SizedBox(width: 12),
                  RankBadge(rank: hunter.rankLabel, color: _rankColor(hunter.rank)),
                ],
              ),
              const SizedBox(height: 12),
              // XP bar
              XpProgressBar(
                progress: hunter.xpProgress,
                currentXp: hunter.currentXp,
                maxXp: hunter.xpToNextLevel,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Lv. ${hunter.level} Hunter',
                      style: AppTextStyles.caption.copyWith(color: AppColors.systemBlue)),
                  const SizedBox(width: 12),
                  if (hunter.streakDays > 0) ...[
                    const Icon(Icons.local_fire_department, color: AppColors.warning, size: 12),
                    const SizedBox(width: 3),
                    Text('${hunter.streakDays}d streak',
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Color _rankColor(HunterRank rank) {
    switch (rank) {
      case HunterRank.s: return AppColors.rankS;
      case HunterRank.a: return AppColors.rankA;
      case HunterRank.b: return AppColors.rankB;
      case HunterRank.c: return AppColors.rankC;
      case HunterRank.d: return AppColors.rankD;
      case HunterRank.e: return AppColors.rankE;
    }
  }
}
