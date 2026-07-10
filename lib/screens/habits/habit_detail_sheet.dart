import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/habit.dart';
import '../../models/quest.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'habit_form_sheet.dart';

class HabitDetailSheet extends StatefulWidget {
  final Habit habit;
  const HabitDetailSheet({super.key, required this.habit});

  @override
  State<HabitDetailSheet> createState() => _HabitDetailSheetState();
}

class _HabitDetailSheetState extends State<HabitDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Build a Set of completed date strings for O(1) lookup
  late final Set<String> _completedDays;

  // Build scheduled days for the past N days
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _completedDays = widget.habit.completionHistory
        .map((d) => _dayKey(d))
        .toSet();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _wasScheduled(DateTime day) =>
      widget.habit.repeatConfig.isDueToday(day);

  bool _wasCompleted(DateTime day) => _completedDays.contains(_dayKey(day));

  bool _wasMissed(DateTime day) {
    if (!_wasScheduled(day)) return false;
    if (day.isAfter(_today)) return false;
    // Created before this day
    final created = DateTime(widget.habit.createdAt.year,
        widget.habit.createdAt.month, widget.habit.createdAt.day);
    if (day.isBefore(created)) return false;
    if (day == _today && !_wasCompleted(day)) return false; // today still pending
    return !_wasCompleted(day);
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.habit;

    return PopScope(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            SystemLabel('[ HABIT DETAIL ]',
                                color: AppColors.agilityColor),
                          ]),
                          const SizedBox(height: 4),
                          Text(h.title,
                              style: AppTextStyles.heading1
                                  .copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(h.description,
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Edit button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => HabitFormSheet(habit: h),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          color: AppColors.textMuted, size: 20),
                    ),
                  ],
                ),
              ),

              // Rarity + repeat info strip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  TagChip(label: h.rarityLabel, color: h.rarityColor),
                  const SizedBox(width: 6),
                  TagChip(
                      label: h.repeatConfig.frequencyLabel,
                      color: AppColors.agilityColor),
                  if (h.hasPenalty) ...[
                    const SizedBox(width: 6),
                    const TagChip(label: '⚠ PENALTY', color: AppColors.danger),
                  ],
                  const Spacer(),
                  Text('+${h.xpReward} XP / day',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.xpColor)),
                ]),
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.agilityColor,
                labelColor: AppColors.agilityColor,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'OVERVIEW', height: 36),
                  Tab(text: 'HISTORY', height: 36),
                ],
              ),
              const Divider(color: AppColors.border, height: 1),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OverviewTab(habit: h, completedDays: _completedDays,
                        today: _today, wasMissed: _wasMissed, wasScheduled: _wasScheduled),
                    _HistoryTab(habit: h, completedDays: _completedDays,
                        today: _today, wasScheduled: _wasScheduled,
                        wasCompleted: _wasCompleted, wasMissed: _wasMissed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final Habit habit;
  final Set<String> completedDays;
  final DateTime today;
  final bool Function(DateTime) wasMissed;
  final bool Function(DateTime) wasScheduled;

  const _OverviewTab({
    required this.habit,
    required this.completedDays,
    required this.today,
    required this.wasMissed,
    required this.wasScheduled,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // Stat cards row
        Row(children: [
          _StatCard(
              label: 'Current\nStreak',
              value: '${habit.currentStreak}',
              unit: 'days',
              icon: Icons.local_fire_department,
              color: AppColors.warning),
          const SizedBox(width: 8),
          _StatCard(
              label: 'Best\nStreak',
              value: '${habit.longestStreak}',
              unit: 'days',
              icon: Icons.emoji_events_outlined,
              color: AppColors.rankS),
          const SizedBox(width: 8),
          _StatCard(
              label: 'Total\nDone',
              value: '${habit.totalCompletions}',
              unit: 'times',
              icon: Icons.check_circle_outline,
              color: AppColors.agilityColor),
        ]).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 12),

        Row(children: [
          _StatCard(
              label: 'Days\nMissed',
              value: '${habit.totalMissedDays}',
              unit: 'days',
              icon: Icons.cancel_outlined,
              color: AppColors.danger),
          const SizedBox(width: 8),
          _StatCard(
              label: 'Win\nRate',
              value: _winRate(),
              unit: '',
              icon: Icons.percent,
              color: AppColors.intelligenceColor),
          const SizedBox(width: 8),
          _StatCard(
              label: 'Last\nDone',
              value: _lastDoneLabel(),
              unit: '',
              icon: Icons.history,
              color: AppColors.textSecondary),
        ]).animate(delay: 50.ms).fadeIn(duration: 300.ms),

        const SizedBox(height: 16),

        // Last 12 weeks heatmap
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'ACTIVITY — LAST 12 WEEKS',
                subtitle: 'green = done  ·  red = missed  ·  gray = not scheduled',
              ),
              _HeatmapGrid(
                today: today,
                weeks: 12,
                wasCompleted: (d) => completedDays.contains(
                    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'),
                wasMissed: wasMissed,
                wasScheduled: wasScheduled,
              ),
              const SizedBox(height: 8),
              // Legend
              Row(children: [
                _LegendDot(color: AppColors.agilityColor, label: 'Completed'),
                const SizedBox(width: 12),
                _LegendDot(color: AppColors.danger, label: 'Missed'),
                const SizedBox(width: 12),
                _LegendDot(color: AppColors.border, label: 'Not scheduled'),
              ]),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04),

        const SizedBox(height: 12),

        // Last 30 days bar chart
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'LAST 30 DAYS'),
              _BarChart(
                today: today,
                days: 30,
                wasCompleted: (d) => completedDays.contains(
                    '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}'),
                wasMissed: wasMissed,
                wasScheduled: wasScheduled,
              ),
            ],
          ),
        ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04),

        if (habit.repeatConfig.endDate != null) ...[
          const SizedBox(height: 12),
          GlassContainer(
            borderColor: AppColors.warning.withAlpha(80),
            child: Row(children: [
              const Icon(Icons.event, color: AppColors.warning, size: 16),
              const SizedBox(width: 10),
              Text(
                'Ends ${DateFormat('EEE, MMM d, yyyy').format(habit.repeatConfig.endDate!)}',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.warning, fontSize: 13),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  String _winRate() {
    final total = habit.totalCompletions + habit.totalMissedDays;
    if (total == 0) return '-';
    return '${((habit.totalCompletions / total) * 100).round()}%';
  }

  String _lastDoneLabel() {
    if (habit.lastCompletedDate == null) return 'Never';
    final diff = DateTime.now().difference(habit.lastCompletedDate!);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

// ── History Tab ───────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final Habit habit;
  final Set<String> completedDays;
  final DateTime today;
  final bool Function(DateTime) wasScheduled;
  final bool Function(DateTime) wasCompleted;
  final bool Function(DateTime) wasMissed;

  const _HistoryTab({
    required this.habit,
    required this.completedDays,
    required this.today,
    required this.wasScheduled,
    required this.wasCompleted,
    required this.wasMissed,
  });

  @override
  Widget build(BuildContext context) {
    // Build day entries for the past 60 days, only scheduled days
    final entries = <_DayEntry>[];
    for (int i = 0; i < 60; i++) {
      final day = today.subtract(Duration(days: i));
      final created = DateTime(habit.createdAt.year, habit.createdAt.month,
          habit.createdAt.day);
      if (day.isBefore(created)) break;
      if (!wasScheduled(day)) continue;

      final done = wasCompleted(day);
      final missed = wasMissed(day);
      final pending = day == today && !done;

      entries.add(_DayEntry(
        date: day,
        done: done,
        missed: missed,
        pending: pending,
      ));
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.history, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          Text('No history yet', style: AppTextStyles.body),
          Text('Complete this habit to see your log',
              style: AppTextStyles.caption),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: entries.length,
      itemBuilder: (_, i) {
        final e = entries[i];
        final color = e.pending
            ? AppColors.textMuted
            : e.done
                ? AppColors.agilityColor
                : AppColors.danger;
        final icon = e.pending
            ? Icons.radio_button_unchecked
            : e.done
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded;
        final label = e.pending
            ? 'Pending'
            : e.done
                ? 'Completed'
                : 'Missed';

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withAlpha(e.pending ? 0 : 12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: color.withAlpha(e.pending ? 30 : 60)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                i == 0
                    ? 'Today — ${DateFormat('MMM d, yyyy').format(e.date)}'
                    : i == 1
                        ? 'Yesterday — ${DateFormat('MMM d, yyyy').format(e.date)}'
                        : DateFormat('EEEE, MMM d, yyyy').format(e.date),
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: color,
                  fontWeight:
                      e.pending ? FontWeight.w400 : FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: color.withAlpha(70)),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ).animate(delay: (i * 20).ms).fadeIn(duration: 200.ms).slideX(begin: -0.02);
      },
    );
  }
}

// ── Heatmap Grid ──────────────────────────────────────────────
class _HeatmapGrid extends StatelessWidget {
  final DateTime today;
  final int weeks;
  final bool Function(DateTime) wasCompleted;
  final bool Function(DateTime) wasMissed;
  final bool Function(DateTime) wasScheduled;

  const _HeatmapGrid({
    required this.today,
    required this.weeks,
    required this.wasCompleted,
    required this.wasMissed,
    required this.wasScheduled,
  });

  @override
  Widget build(BuildContext context) {
    // Build grid: columns = weeks, rows = Mon-Sun
    // Start from the Monday of (weeks) weeks ago
    final startOfThisWeek =
        today.subtract(Duration(days: today.weekday - 1));
    final gridStart =
        startOfThisWeek.subtract(Duration(days: (weeks - 1) * 7));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Column(
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map((d) => SizedBox(
                    height: 14,
                    width: 12,
                    child: Text(d,
                        style: AppTextStyles.caption.copyWith(fontSize: 8)),
                  ))
              .toList(),
        ),
        const SizedBox(width: 4),
        // Week columns
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(weeks, (weekIdx) {
              return Expanded(
                child: Column(
                  children: List.generate(7, (dayIdx) {
                    final day = gridStart
                        .add(Duration(days: weekIdx * 7 + dayIdx));
                    if (day.isAfter(today)) {
                      return const SizedBox(height: 14);
                    }

                    Color cellColor;
                    if (wasCompleted(day)) {
                      cellColor = AppColors.agilityColor;
                    } else if (wasMissed(day)) {
                      cellColor = AppColors.danger;
                    } else {
                      // not scheduled or future
                      cellColor = AppColors.bgElevated;
                    }

                    return Container(
                      height: 12,
                      width: double.infinity,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Bar Chart (last N days) ───────────────────────────────────
class _BarChart extends StatelessWidget {
  final DateTime today;
  final int days;
  final bool Function(DateTime) wasCompleted;
  final bool Function(DateTime) wasMissed;
  final bool Function(DateTime) wasScheduled;

  const _BarChart({
    required this.today,
    required this.days,
    required this.wasCompleted,
    required this.wasMissed,
    required this.wasScheduled,
  });

  @override
  Widget build(BuildContext context) {
    // Build list oldest → newest
    final data = List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      return _BarData(
        day: day,
        done: wasCompleted(day),
        missed: wasMissed(day),
        scheduled: wasScheduled(day),
        isToday: day == today,
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((d) {
              Color color;
              double heightFactor;
              if (!d.scheduled) {
                color = AppColors.bgElevated;
                heightFactor = 0.2;
              } else if (d.done) {
                color = AppColors.agilityColor;
                heightFactor = 1.0;
              } else if (d.missed) {
                color = AppColors.danger;
                heightFactor = 0.5;
              } else {
                // today, pending
                color = AppColors.textMuted;
                heightFactor = 0.3;
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: 60 * heightFactor,
                  decoration: BoxDecoration(
                    color: d.isToday
                        ? color
                        : color.withAlpha(d.done ? 200 : 150),
                    borderRadius: BorderRadius.circular(3),
                    border: d.isToday
                        ? Border.all(color: Colors.white24, width: 1)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        // X axis — show every 5th label
        Row(
          children: data.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            final showLabel = i == 0 || (days - 1 - i) % 7 == 0 || i == days - 1;
            return Expanded(
              child: showLabel
                  ? Text(
                      DateFormat('d').format(d.day),
                      style:
                          AppTextStyles.caption.copyWith(fontSize: 8),
                      textAlign: TextAlign.center,
                    )
                  : const SizedBox.shrink(),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // Summary row
        Row(children: [
          _MiniStat(
            color: AppColors.agilityColor,
            label: '${data.where((d) => d.done).length} done',
          ),
          const SizedBox(width: 12),
          _MiniStat(
            color: AppColors.danger,
            label: '${data.where((d) => d.missed).length} missed',
          ),
          const SizedBox(width: 12),
          _MiniStat(
            color: AppColors.textMuted,
            label:
                '${data.where((d) => !d.scheduled).length} not scheduled',
          ),
        ]),
      ],
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color)),
            if (unit.isNotEmpty)
              Text(unit,
                  style: AppTextStyles.caption.copyWith(fontSize: 9)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.caption.copyWith(fontSize: 9),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final Color color;
  final String label;
  const _MiniStat({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 4),
      Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
    ]);
  }
}

// ── Data classes ──────────────────────────────────────────────
class _DayEntry {
  final DateTime date;
  final bool done;
  final bool missed;
  final bool pending;
  const _DayEntry(
      {required this.date,
      required this.done,
      required this.missed,
      required this.pending});
}

class _BarData {
  final DateTime day;
  final bool done;
  final bool missed;
  final bool scheduled;
  final bool isToday;
  const _BarData({
    required this.day,
    required this.done,
    required this.missed,
    required this.scheduled,
    required this.isToday,
  });
}
