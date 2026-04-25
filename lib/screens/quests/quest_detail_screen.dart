import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/quest.dart';
import '../../providers/quest_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/quest/quest_form_sheet.dart';
import '../profile/level_up_dialog.dart';

class QuestDetailScreen extends StatelessWidget {
  final Quest quest;

  const QuestDetailScreen({super.key, required this.quest});

  @override
  Widget build(BuildContext context) {
    final isPenalty = quest.status == QuestStatus.penalty;
    final accentColor = isPenalty ? AppColors.danger : quest.rarityColor;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.bgDeep,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: SystemLabel(isPenalty ? '[ PENALTY QUEST ]' : '[ ${quest.rarityLabel} QUEST ]',
                color: accentColor),
            actions: [
              if (quest.status == QuestStatus.active || quest.status == QuestStatus.penalty)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => QuestFormSheet(quest: quest),
                    );
                  },
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Title block
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: accentColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: accentColor.withAlpha(70)),
                                ),
                                child: Text(
                                  quest.rarityLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _StatusBadge(status: quest.status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(quest.title, style: AppTextStyles.heading1.copyWith(fontSize: 22)),
                          const SizedBox(height: 8),
                          Text(quest.description, style: AppTextStyles.body.copyWith(height: 1.7)),
                        ],
                      ),
                    ),
                    // Left accent bar overlay
                    Positioned(
                      left: 0, top: 0, bottom: 0,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 14),

                // Details card
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SystemLabel('[ QUEST DETAILS ]'),
                      const SizedBox(height: 14),
                      _DetailRow(
                        icon: Icons.star_outline_rounded,
                        label: 'XP Reward',
                        value: '+${quest.xpReward} XP',
                        valueColor: AppColors.xpColor,
                      ),
                      _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Deadline',
                        value: DateFormat('EEE, MMM d — HH:mm').format(quest.deadline),
                        valueColor: quest.isOverdue ? AppColors.danger : AppColors.textPrimary,
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Created',
                        value: DateFormat('MMM d, yyyy').format(quest.createdAt),
                        valueColor: AppColors.textSecondary,
                      ),
                      if (quest.completedAt != null)
                        _DetailRow(
                          icon: Icons.check_circle_outline,
                          label: 'Completed',
                          value: DateFormat('MMM d, yyyy — HH:mm').format(quest.completedAt!),
                          valueColor: AppColors.success,
                        ),
                      if (quest.unlockLevel != null)
                        _DetailRow(
                          icon: Icons.lock_outline_rounded,
                          label: 'Unlock Level',
                          value: 'Level ${quest.unlockLevel}',
                          valueColor: AppColors.textMuted,
                        ),
                    ],
                  ),
                ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

                const SizedBox(height: 14),

                // Tags
                if (quest.tags.isNotEmpty) ...[
                  GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SystemLabel('[ TAGS ]'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: quest.tags.map((t) => TagChip(
                            label: t,
                            color: accentColor,
                          )).toList(),
                        ),
                      ],
                    ),
                  ).animate(delay: 120.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 14),
                ],

                // Penalty info
                if (quest.hasPenalty || quest.penaltyDescription != null)
                  GlassContainer(
                    borderColor: AppColors.danger.withAlpha(80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.danger, size: 14),
                            const SizedBox(width: 6),
                            SystemLabel('[ PENALTY ]', color: AppColors.danger),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (quest.penaltyDescription != null)
                          _DetailRow(
                            icon: Icons.assignment_late_outlined,
                            label: 'Penalty Task',
                            value: quest.penaltyDescription!,
                            valueColor: AppColors.danger,
                          ),
                        if (quest.penaltyXp != null)
                          _DetailRow(
                            icon: Icons.remove_circle_outline,
                            label: 'XP Deduction',
                            value: '-${quest.penaltyXp} XP',
                            valueColor: AppColors.danger,
                          ),
                      ],
                    ),
                  ).animate(delay: 160.ms).fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // Action buttons
                if (quest.status == QuestStatus.active || quest.status == QuestStatus.penalty)
                  Consumer<QuestProvider>(
                    builder: (context, provider, _) => Column(
                      children: [
                        SystemButton(
                          label: 'MARK AS COMPLETE',
                          onTap: () => _complete(context, provider),
                          color: AppColors.success,
                          width: double.infinity,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                        if (quest.status == QuestStatus.active) ...[
                          const SizedBox(height: 10),
                          SystemButton(
                            label: 'MARK AS FAILED',
                            onTap: () => _fail(context, provider),
                            color: AppColors.danger,
                            isOutlined: true,
                            width: double.infinity,
                            icon: Icons.cancel_outlined,
                          ),
                        ],
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

                if (quest.status == QuestStatus.completed)
                  GlassContainer(
                    borderColor: AppColors.success.withAlpha(80),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text('Quest Completed', style: AppTextStyles.body.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

                if (quest.status == QuestStatus.failed)
                  GlassContainer(
                    borderColor: AppColors.danger.withAlpha(80),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: 8),
                        Text('Quest Failed', style: AppTextStyles.body.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w500,
                        )),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _complete(BuildContext context, QuestProvider provider) async {
    final result = await provider.completeQuest(quest.id);
    if (!context.mounted) return;
    if (result.didLevelUp) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(newLevel: result.newLevel),
      );
    }
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _fail(BuildContext context, QuestProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Mark as Failed?', style: AppTextStyles.heading2.copyWith(color: AppColors.danger)),
        content: Text('A penalty task may be spawned.', style: AppTextStyles.body),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.danger),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.failQuest(quest.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final QuestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      QuestStatus.active => ('ACTIVE', AppColors.systemBlue),
      QuestStatus.completed => ('COMPLETED', AppColors.success),
      QuestStatus.failed => ('FAILED', AppColors.danger),
      QuestStatus.locked => ('LOCKED', AppColors.textMuted),
      QuestStatus.penalty => ('PENALTY', AppColors.warning),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
