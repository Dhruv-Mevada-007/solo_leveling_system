import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/habit.dart';
import '../../models/quest.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../profile/level_up_dialog.dart';
import 'habit_form_sheet.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, provider),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodayTab(context, provider),
                      _buildAllHabitsTab(context, provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _HabitFab(),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, HabitProvider provider) {
    final done = provider.completedToday.length;
    final total = provider.activeHabits.length;
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SystemLabel('[ HABIT SYSTEM ]'),
              const Spacer(),
              Text(
                DateFormat('EEE, MMM d').format(DateTime.now()),
                style: AppTextStyles.caption.copyWith(color: AppColors.systemBlue),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Daily Habits', style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TODAY\'S PROGRESS',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.agilityColor)),
                        Text('$done / $total',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.agilityColor)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          alignment: Alignment.centerLeft,
                          widthFactor: progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.agilityColor, Color(0xFF86EFAC)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Completion ring
              _ProgressRing(done: done, total: total),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTabBar() {
    return Container(
      decoration:
          const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.agilityColor,
        labelColor: AppColors.agilityColor,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'TODAY', height: 38),
          Tab(text: 'ALL HABITS', height: 38),
        ],
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context, HabitProvider provider) {
    final pending = provider.pendingToday;
    final done = provider.completedToday;

    if (provider.activeHabits.isEmpty) {
      return _EmptyState(
        icon: Icons.repeat_rounded,
        title: 'No habits yet',
        subtitle: 'Add your first habit to start building streaks',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const BouncingScrollPhysics(),
      children: [
        if (pending.isNotEmpty) ...[
          SectionHeader(title: 'PENDING', subtitle: '${pending.length} to complete'),
          ...pending.asMap().entries.map((e) => _HabitCard(
                habit: e.value,
                onComplete: () => _completeHabit(context, provider, e.value.id),
                onEdit: () => _editHabit(context, e.value),
                onDelete: () => _deleteHabit(context, provider, e.value.id),
              ).animate(delay: (e.key * 50).ms).fadeIn(duration: 250.ms).slideY(begin: 0.04)),
        ],
        if (done.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionHeader(
              title: 'COMPLETED TODAY',
              subtitle: '${done.length} done ✓'),
          ...done.asMap().entries.map((e) => _HabitCard(
                habit: e.value,
                isCompleted: true,
                onEdit: () => _editHabit(context, e.value),
                onDelete: () => _deleteHabit(context, provider, e.value.id),
              ).animate(delay: (e.key * 40).ms).fadeIn(duration: 200.ms)),
        ],
      ],
    );
  }

  Widget _buildAllHabitsTab(BuildContext context, HabitProvider provider) {
    final active = provider.allHabits;
    final archived = provider.archivedHabits;

    if (active.isEmpty && archived.isEmpty) {
      return _EmptyState(
        icon: Icons.auto_awesome,
        title: 'No habits created',
        subtitle: 'Tap + to build your first repeating habit',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const BouncingScrollPhysics(),
      children: [
        if (active.isNotEmpty) ...[
          SectionHeader(title: 'ACTIVE HABITS', subtitle: '${active.length} habits'),
          ...active.asMap().entries.map((e) => _HabitManageCard(
                habit: e.value,
                onEdit: () => _editHabit(context, e.value),
                onDelete: () => _deleteHabit(context, provider, e.value.id),
                onArchive: () => provider.archiveHabit(e.value.id),
              ).animate(delay: (e.key * 40).ms).fadeIn(duration: 200.ms).slideX(begin: -0.02)),
        ],
        if (archived.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionHeader(title: 'ARCHIVED', subtitle: 'Completed or expired'),
          ...archived.map((h) => _HabitManageCard(
                habit: h,
                isArchived: true,
                onDelete: () => _deleteHabit(context, provider, h.id),
              )),
        ],
      ],
    );
  }

  Future<void> _completeHabit(
      BuildContext context, HabitProvider provider, String id) async {
    final result = await provider.completeHabit(id);
    if (!context.mounted) return;
    if (result.didLevelUp) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LevelUpDialog(newLevel: result.newLevel),
      );
    } else {
      final habit = provider.habits.firstWhere((h) => h.id == id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.repeat_rounded, color: AppColors.agilityColor, size: 16),
          const SizedBox(width: 8),
          Text('Habit done! +${habit.xpReward} XP',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          if (habit.currentStreak > 1)
            Text('🔥 ${habit.currentStreak}d',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning)),
        ]),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.agilityColor, width: 1),
        ),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _editHabit(BuildContext context, Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitFormSheet(habit: habit),
    );
  }

  Future<void> _deleteHabit(
      BuildContext context, HabitProvider provider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.border)),
        title: Text('Delete Habit?',
            style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        content: Text('This will remove all streak and history data.',
            style: AppTextStyles.body),
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
    if (confirmed == true) provider.deleteHabit(id);
  }
}

// ── Habit Card (today view) ───────────────────────────────────
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _HabitCard({
    required this.habit,
    this.isCompleted = false,
    this.onComplete,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppColors.agilityColor : habit.rarityColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.agilityColor.withAlpha(10)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isCompleted
                ? AppColors.agilityColor.withAlpha(80)
                : AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion checkbox
                GestureDetector(
                  onTap: isCompleted ? null : onComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.agilityColor : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.agilityColor
                            : habit.rarityColor,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title,
                          style: AppTextStyles.body.copyWith(
                            color: isCompleted
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(children: [
                        Text(habit.repeatConfig.frequencyLabel,
                            style: AppTextStyles.caption),
                        const SizedBox(width: 8),
                        Text('+${habit.xpReward} XP',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.xpColor)),
                      ]),
                    ],
                  ),
                ),
                // Streak badge
                if (habit.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.warning.withAlpha(80)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.warning, size: 12),
                      const SizedBox(width: 3),
                      Text('${habit.currentStreak}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                const SizedBox(width: 6),
                // Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                  color: AppColors.bgCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_outlined, size: 16, color: AppColors.systemBlue),
                          SizedBox(width: 8),
                          Text('Edit', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                        ])),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                        ])),
                  ],
                ),
              ],
            ),
          ),
          // Tags + rarity strip
          Container(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(children: [
              TagChip(label: habit.rarityLabel, color: habit.rarityColor),
              const SizedBox(width: 6),
              ...habit.tags
                  .take(2)
                  .map((t) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: TagChip(label: t, color: AppColors.textMuted),
                      )),
              if (habit.hasPenalty) ...[
                TagChip(
                  label: '⚠ PENALTY',
                  color: AppColors.danger,
                ),
                const SizedBox(width: 6),
              ],
              const Spacer(),
              if (habit.repeatConfig.endDate != null)
                Text(
                  'Until ${DateFormat('MMM d').format(habit.repeatConfig.endDate!)}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                )
              else
                Text('∞ Forever',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted)),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Habit manage card (all habits tab) ───────────────────────
class _HabitManageCard extends StatelessWidget {
  final Habit habit;
  final bool isArchived;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const _HabitManageCard({
    required this.habit,
    this.isArchived = false,
    this.onEdit,
    this.onDelete,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 3, height: 44,
          decoration: BoxDecoration(
            color: isArchived ? AppColors.textMuted : habit.rarityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(habit.title,
                style: AppTextStyles.body.copyWith(
                  color: isArchived ? AppColors.textMuted : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Text(habit.repeatConfig.frequencyLabel,
                  style: AppTextStyles.caption),
              const SizedBox(width: 8),
              if (habit.currentStreak > 0) ...[
                const Icon(Icons.local_fire_department,
                    color: AppColors.warning, size: 11),
                const SizedBox(width: 2),
                Text('${habit.currentStreak}d streak',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning)),
                const SizedBox(width: 8),
              ],
              Text('${habit.totalCompletions}x done',
                  style: AppTextStyles.caption),
            ]),
          ]),
        ),
        if (!isArchived) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.textMuted),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.archive_outlined, size: 17, color: AppColors.textMuted),
            onPressed: onArchive,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
        ],
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.danger),
          onPressed: onDelete,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }
}

// ── Progress ring ─────────────────────────────────────────────
class _ProgressRing extends StatelessWidget {
  final int done;
  final int total;

  const _ProgressRing({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? done / total : 0.0;
    return SizedBox(
      width: 52, height: 52,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
          value: pct,
          strokeWidth: 4,
          backgroundColor: AppColors.border,
          valueColor:
              const AlwaysStoppedAnimation(AppColors.agilityColor),
        ),
        Text(
          total > 0 ? '${(pct * 100).round()}%' : '-',
          style: const TextStyle(
              fontSize: 11,
              color: AppColors.agilityColor,
              fontWeight: FontWeight.w600),
        ),
      ]),
    );
  }
}

class _HabitFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const HabitFormSheet(),
      ),
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.agilityColor.withAlpha(40),
          border: Border.all(color: AppColors.agilityColor, width: 1),
          boxShadow: [
            BoxShadow(
                color: AppColors.agilityColor.withAlpha(50),
                blurRadius: 14,
                spreadRadius: 1),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.agilityColor, size: 26),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppColors.textMuted, size: 44),
        const SizedBox(height: 12),
        Text(title, style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.body, textAlign: TextAlign.center),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }
}
