import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'reminder_form_sheet.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, provider, _) {
        final pinned = provider.pinnedReminders;
        final rest = provider.unpinnedReminders;

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: provider.reminders.isEmpty
                      ? _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            if (pinned.isNotEmpty) ...[
                              const SectionHeader(
                                title: 'PINNED',
                                subtitle: 'Always on top',
                              ),
                              ...pinned.asMap().entries.map((e) =>
                                  _ReminderCard(
                                    reminder: e.value,
                                    onEdit: () => _edit(context, e.value),
                                    onDelete: () =>
                                        _delete(context, provider, e.value.id),
                                    onTogglePin: () =>
                                        provider.togglePin(e.value.id),
                                  ).animate(delay: (e.key * 40).ms)
                                      .fadeIn(duration: 250.ms)
                                      .slideY(begin: 0.04)),
                              const SizedBox(height: 12),
                            ],
                            if (rest.isNotEmpty) ...[
                              SectionHeader(
                                title: 'REMINDERS',
                                subtitle: '${rest.length} note${rest.length != 1 ? 's' : ''}',
                              ),
                              ...rest.asMap().entries.map((e) =>
                                  _ReminderCard(
                                    reminder: e.value,
                                    onEdit: () => _edit(context, e.value),
                                    onDelete: () =>
                                        _delete(context, provider, e.value.id),
                                    onTogglePin: () =>
                                        provider.togglePin(e.value.id),
                                  ).animate(delay: (e.key * 40).ms)
                                      .fadeIn(duration: 250.ms)
                                      .slideY(begin: 0.04)),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: _ReminderFab(),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SystemLabel('[ REMINDER BOARD ]'),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Reminders', style: AppTextStyles.heading1),
              const Spacer(),
              Consumer<ReminderProvider>(
                builder: (_, p, __) => Text(
                  '${p.reminders.length} note${p.reminders.length != 1 ? 's' : ''}',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Passive notes — no deadlines, no actions. Just things to remember.',
            style: AppTextStyles.body.copyWith(fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  void _edit(BuildContext context, Reminder reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReminderFormSheet(reminder: reminder),
    );
  }

  Future<void> _delete(
      BuildContext context, ReminderProvider provider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border)),
        title: Text('Delete Reminder?',
            style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        content: Text('This cannot be undone.', style: AppTextStyles.body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed == true) provider.deleteReminder(id);
  }
}

// ── Reminder Card ─────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;

  const _ReminderCard({
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final color = reminder.color;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: reminder.isPinned
                  ? color.withAlpha(120)
                  : AppColors.border),
        ),
        child: Stack(
          children: [
            // Left color accent
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji
                      Text(reminder.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            if (reminder.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                reminder.note,
                                style: AppTextStyles.body
                                    .copyWith(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Actions
                      Column(
                        children: [
                          GestureDetector(
                            onTap: onTogglePin,
                            child: Icon(
                              reminder.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              size: 18,
                              color: reminder.isPinned
                                  ? color
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: onDelete,
                            child: const Icon(Icons.delete_outline,
                                size: 18, color: AppColors.danger),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Footer
                  Row(children: [
                    Icon(reminder.categoryIcon,
                        size: 12, color: color.withAlpha(180)),
                    const SizedBox(width: 4),
                    Text(reminder.categoryLabel,
                        style: TextStyle(
                            fontSize: 10,
                            color: color.withAlpha(200),
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    if (reminder.isPinned) ...[
                      const Icon(Icons.push_pin,
                          size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text('Pinned',
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 10)),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const ReminderFormSheet(),
      ),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.manaColor.withAlpha(40),
          border: Border.all(color: AppColors.manaColor, width: 1),
          boxShadow: [
            BoxShadow(
                color: AppColors.manaColor.withAlpha(50),
                blurRadius: 14,
                spreadRadius: 1),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.manaColor, size: 26),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.push_pin_outlined,
              color: AppColors.textMuted, size: 44),
          const SizedBox(height: 12),
          Text('No reminders yet',
              style: AppTextStyles.heading2.copyWith(fontSize: 16)),
          const SizedBox(height: 4),
          Text('Add things you never want to forget',
              style: AppTextStyles.body),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
