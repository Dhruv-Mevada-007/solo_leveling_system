import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/quest.dart';
import '../../theme/app_theme.dart';
import '../common/common_widgets.dart';

class QuestCard extends StatefulWidget {
  final Quest quest;
  final VoidCallback? onComplete;
  final VoidCallback? onFail;
  final VoidCallback? onTap;
  final bool showActions;

  const QuestCard({
    super.key,
    required this.quest,
    this.onComplete,
    this.onFail,
    this.onTap,
    this.showActions = true,
  });

  @override
  State<QuestCard> createState() => _QuestCardState();
}

class _QuestCardState extends State<QuestCard> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.quest;
    final isLocked = q.unlockLevel != null;
    final isPenalty = q.status == QuestStatus.penalty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isLocked ? AppColors.bgSecondary : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pressed
                  ? q.rarityColor.withAlpha(100)
                  : AppColors.border,
            ),
          ),
          child: Stack(
            children: [
              // Left rarity accent bar
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: isPenalty ? AppColors.danger : q.rarityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Opacity(
                  opacity: isLocked ? 0.45 : 1.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              isLocked ? '🔒 ??? Locked Quest' : q.title,
                              style: AppTextStyles.heading2.copyWith(fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _XpBadge(quest: q, isPenalty: isPenalty),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Description
                      Text(
                        isLocked
                            ? 'Reach Level ${q.unlockLevel} to unlock this quest.'
                            : q.description,
                        style: AppTextStyles.body.copyWith(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Footer
                      Row(
                        children: [
                          // Deadline
                          if (!isLocked) _DeadlineChip(deadline: q.deadline, isOverdue: q.isOverdue),
                          if (isLocked)
                            _DeadlineChip(
                              customLabel: 'Unlock at Lv. ${q.unlockLevel}',
                              isOverdue: false,
                              color: AppColors.textMuted,
                            ),
                          const Spacer(),
                          // Tags
                          Wrap(
                            spacing: 4,
                            children: q.tags.take(2).map((t) => TagChip(
                              label: t,
                              color: isPenalty ? AppColors.danger : q.rarityColor,
                            )).toList(),
                          ),
                        ],
                      ),
                      // Action buttons
                      if (widget.showActions && !isLocked && q.status == QuestStatus.active) ...[
                        const SizedBox(height: 10),
                        const SystemDivider(),
                        Row(
                          children: [
                            Expanded(
                              child: SystemButton(
                                label: 'COMPLETE',
                                onTap: widget.onComplete ?? () {},
                                color: AppColors.success,
                                icon: Icons.check_rounded,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SystemButton(
                              label: 'FAIL',
                              onTap: widget.onFail ?? () {},
                              color: AppColors.danger,
                              isOutlined: true,
                              icon: Icons.close_rounded,
                            ),
                          ],
                        ),
                      ],
                      if (widget.showActions && !isLocked && q.status == QuestStatus.penalty) ...[
                        const SizedBox(height: 10),
                        const SystemDivider(),
                        SystemButton(
                          label: 'COMPLETE PENALTY',
                          onTap: widget.onComplete ?? () {},
                          color: AppColors.danger,
                          icon: Icons.warning_amber_rounded,
                          width: double.infinity,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}

class _XpBadge extends StatelessWidget {
  final Quest quest;
  final bool isPenalty;

  const _XpBadge({required this.quest, required this.isPenalty});

  @override
  Widget build(BuildContext context) {
    final color = isPenalty ? AppColors.danger : quest.rarityColor;
    final label = isPenalty
        ? '-${quest.penaltyXp ?? 0} XP'
        : '+${quest.xpReward} XP';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  final DateTime? deadline;
  final String? customLabel;
  final bool isOverdue;
  final Color? color;

  const _DeadlineChip({
    this.deadline,
    this.customLabel,
    required this.isOverdue,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isOverdue ? AppColors.danger : AppColors.textMuted);
    final label = customLabel ?? _formatDeadline();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.caption.copyWith(color: c)),
      ],
    );
  }

  String _formatDeadline() {
    if (deadline == null) return '';
    final now = DateTime.now();
    final diff = deadline!.difference(now);
    if (isOverdue) {
      final hours = diff.inHours.abs();
      return 'OVERDUE ${hours}h ago';
    }
    if (diff.inHours < 1) return '${diff.inMinutes}m left';
    if (diff.inHours < 24) return '${diff.inHours}h left';
    if (diff.inDays == 1) return 'Tomorrow';
    return DateFormat('MMM d').format(deadline!);
  }
}

// ── Compact card for task management tab ──────────────────────
class CompactQuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CompactQuestCard({
    super.key,
    required this.quest,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final q = quest;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: _statusColor(q.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(q.title, style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        q.rarityLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: q.rarityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${q.xpReward} XP',
                        style: AppTextStyles.caption.copyWith(color: AppColors.xpColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _statusLabel(q.status),
                        style: AppTextStyles.caption.copyWith(
                          color: _statusColor(q.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(QuestStatus s) {
    switch (s) {
      case QuestStatus.active: return AppColors.systemBlue;
      case QuestStatus.completed: return AppColors.success;
      case QuestStatus.failed: return AppColors.danger;
      case QuestStatus.locked: return AppColors.textMuted;
      case QuestStatus.penalty: return AppColors.warning;
    }
  }

  String _statusLabel(QuestStatus s) {
    switch (s) {
      case QuestStatus.active: return 'ACTIVE';
      case QuestStatus.completed: return 'COMPLETED';
      case QuestStatus.failed: return 'FAILED';
      case QuestStatus.locked: return 'LOCKED';
      case QuestStatus.penalty: return 'PENALTY';
    }
  }
}
