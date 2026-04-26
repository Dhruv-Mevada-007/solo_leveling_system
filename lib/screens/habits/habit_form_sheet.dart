import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/habit.dart';
import '../../models/quest.dart';
import '../../providers/habit_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class HabitFormSheet extends StatefulWidget {
  final Habit? habit;
  const HabitFormSheet({super.key, this.habit});

  @override
  State<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<HabitFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _xpCtrl;
  late TextEditingController _tagCtrl;
  late TextEditingController _nDaysCtrl;

  QuestRarity _rarity = QuestRarity.common;
  List<String> _tags = [];

  // Repeat config state
  RepeatFrequency _frequency = RepeatFrequency.daily;
  List<int> _weekdays = [1, 2, 3, 4, 5, 6, 7];
  int _everyNDays = 2;
  bool _forever = true;
  DateTime? _endDate;

  static const _dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _titleCtrl = TextEditingController(text: h?.title ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _xpCtrl = TextEditingController(text: h?.xpReward.toString() ?? '50');
    _tagCtrl = TextEditingController();
    _nDaysCtrl = TextEditingController(
        text: h?.repeatConfig.everyNDays?.toString() ?? '2');

    if (h != null) {
      _rarity = h.rarity;
      _tags = List.from(h.tags);
      _frequency = h.repeatConfig.frequency;
      _weekdays = List.from(h.repeatConfig.weekdays);
      _everyNDays = h.repeatConfig.everyNDays ?? 2;
      _forever = h.repeatConfig.endDate == null;
      _endDate = h.repeatConfig.endDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _xpCtrl.dispose();
    _tagCtrl.dispose();
    _nDaysCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habit != null;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
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
                margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                const Icon(Icons.repeat_rounded,
                    color: AppColors.agilityColor, size: 16),
                const SizedBox(width: 8),
                SystemLabel(
                    isEdit ? '[ EDIT HABIT ]' : '[ NEW HABIT ]',
                    color: AppColors.agilityColor),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close,
                      color: AppColors.textMuted, size: 20),
                ),
              ]),
            ),
            const Divider(color: AppColors.border, height: 1),
            Expanded(
              child: ListView(
                controller: controller,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _field('Habit Title', _titleCtrl,
                              hint: 'e.g. Drink 2L Water', required: true),
                          const SizedBox(height: 14),
                          _field('Description', _descCtrl,
                              hint: 'Why this habit matters...', maxLines: 2),
                          const SizedBox(height: 14),
                          _field('XP Reward per completion', _xpCtrl,
                              hint: '50',
                              keyboardType: TextInputType.number,
                              required: true),
                          const SizedBox(height: 14),

                          // Rarity
                          _label('Rarity'),
                          const SizedBox(height: 8),
                          _RarityRow(
                              selected: _rarity,
                              onChanged: (r) => setState(() => _rarity = r)),
                          const SizedBox(height: 18),

                          // ── REPEAT SECTION ───────────────────
                          _label('REPEAT FREQUENCY'),
                          const SizedBox(height: 10),
                          _FrequencySelector(
                            selected: _frequency,
                            onChanged: (f) => setState(() => _frequency = f),
                          ),
                          const SizedBox(height: 14),

                          // Weekly day picker
                          if (_frequency == RepeatFrequency.weekly) ...[
                            _label('REPEAT ON DAYS'),
                            const SizedBox(height: 8),
                            _WeekdayPicker(
                              selected: _weekdays,
                              onChanged: (days) =>
                                  setState(() => _weekdays = days),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Custom N days
                          if (_frequency == RepeatFrequency.custom) ...[
                            _label('REPEAT EVERY N DAYS'),
                            const SizedBox(height: 8),
                            Row(children: [
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: _nDaysCtrl,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary),
                                  decoration: const InputDecoration(
                                      isDense: true, hintText: '2'),
                                  onChanged: (v) =>
                                      _everyNDays = int.tryParse(v) ?? 2,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text('days',
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.textMuted)),
                            ]),
                            const SizedBox(height: 14),
                          ],

                          // ── UNTIL WHEN ───────────────────────
                          _label('REPEAT UNTIL'),
                          const SizedBox(height: 8),
                          _UntilSelector(
                            forever: _forever,
                            endDate: _endDate,
                            onForeverChanged: (v) =>
                                setState(() => _forever = v),
                            onDatePicked: (d) => setState(() {
                              _endDate = d;
                              _forever = false;
                            }),
                          ),
                          const SizedBox(height: 18),

                          // Tags
                          _label('Tags'),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: _tagCtrl,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 14),
                                decoration: const InputDecoration(
                                    hintText: 'Add tag (press +)',
                                    isDense: true),
                                onSubmitted: (_) => _addTag(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _addTag,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.agilityColor.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.agilityColor),
                                ),
                                child: const Icon(Icons.add,
                                    color: AppColors.agilityColor, size: 18),
                              ),
                            ),
                          ]),
                          if (_tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6, runSpacing: 6,
                              children: _tags
                                  .map((t) => TagChip(
                                        label: t,
                                        color: AppColors.agilityColor,
                                        onRemove: () => setState(
                                            () => _tags.remove(t)),
                                      ))
                                  .toList(),
                            ),
                          ],

                          const SizedBox(height: 28),
                          SystemButton(
                            label: isEdit ? 'UPDATE HABIT' : 'CREATE HABIT',
                            onTap: _submit,
                            color: AppColors.agilityColor,
                            width: double.infinity,
                            icon: Icons.repeat_rounded,
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ), // Container
    ), // Padding
    ); // PopScope
  }

  Widget _label(String t) => Text(t,
      style: AppTextStyles.caption
          .copyWith(color: AppColors.textMuted, letterSpacing: 1));

  Widget _field(String label, TextEditingController ctrl,
      {String? hint,
      int maxLines = 1,
      TextInputType? keyboardType,
      bool required = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint, isDense: true),
        validator: required
            ? (v) => (v == null || v.isEmpty) ? 'Required' : null
            : null,
      ),
    ]);
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim().toUpperCase();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagCtrl.clear();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<HabitProvider>();
    final xp = int.tryParse(_xpCtrl.text) ?? 50;
    final repeatConfig = RepeatConfig(
      frequency: _frequency,
      weekdays: _weekdays,
      everyNDays:
          _frequency == RepeatFrequency.custom ? _everyNDays : null,
      endDate: _forever ? null : _endDate,
    );

    if (widget.habit == null) {
      provider.addHabit(Habit(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        xpReward: xp,
        rarity: _rarity,
        tags: _tags,
        repeatConfig: repeatConfig,
      ));
    } else {
      provider.updateHabit(widget.habit!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        xpReward: xp,
        rarity: _rarity,
        tags: _tags,
        repeatConfig: repeatConfig,
      ));
    }
    Navigator.pop(context);
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _RarityRow extends StatelessWidget {
  final QuestRarity selected;
  final ValueChanged<QuestRarity> onChanged;
  const _RarityRow({required this.selected, required this.onChanged});

  Color _c(QuestRarity r) {
    switch (r) {
      case QuestRarity.legendary: return AppColors.rarityLegendary;
      case QuestRarity.epic:      return AppColors.rarityEpic;
      case QuestRarity.rare:      return AppColors.rarityRare;
      case QuestRarity.common:    return AppColors.rarityCommon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: QuestRarity.values.map((r) {
        final active = r == selected;
        final color = _c(r);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: active ? color.withAlpha(40) : AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: active ? color : AppColors.border,
                    width: active ? 1.5 : 1),
              ),
              child: Text(
                r.name[0].toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: active ? color : AppColors.textMuted,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  final RepeatFrequency selected;
  final ValueChanged<RepeatFrequency> onChanged;
  const _FrequencySelector({required this.selected, required this.onChanged});

  static const _labels = {
    RepeatFrequency.daily:   ('Every Day', Icons.sunny),
    RepeatFrequency.weekly:  ('Weekly',    Icons.calendar_view_week),
    RepeatFrequency.monthly: ('Monthly',   Icons.calendar_month),
    RepeatFrequency.custom:  ('Custom',    Icons.tune),
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: RepeatFrequency.values.map((f) {
        final active = f == selected;
        final (label, icon) = _labels[f]!;
        return GestureDetector(
          onTap: () => onChanged(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.agilityColor.withAlpha(30)
                  : AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: active ? AppColors.agilityColor : AppColors.border,
                  width: active ? 1.5 : 1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 14,
                  color: active
                      ? AppColors.agilityColor
                      : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: active
                          ? AppColors.agilityColor
                          : AppColors.textMuted,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;
  const _WeekdayPicker({required this.selected, required this.onChanged});

  static const _days = ['', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final day = i + 1;
        final active = selected.contains(day);
        return Expanded(
          child: GestureDetector(
            onTap: () {
              final next = List<int>.from(selected);
              if (active && next.length > 1) {
                next.remove(day);
              } else if (!active) {
                next.add(day);
                next.sort();
              }
              onChanged(next);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.only(right: 5),
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppColors.agilityColor
                    : AppColors.bgCard,
                border: Border.all(
                    color: active
                        ? AppColors.agilityColor
                        : AppColors.border),
              ),
              child: Center(
                child: Text(_days[day],
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? Colors.white
                            : AppColors.textMuted)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _UntilSelector extends StatelessWidget {
  final bool forever;
  final DateTime? endDate;
  final ValueChanged<bool> onForeverChanged;
  final ValueChanged<DateTime> onDatePicked;

  const _UntilSelector({
    required this.forever,
    required this.endDate,
    required this.onForeverChanged,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Toggle row
      Row(children: [
        _ToggleChip(
          label: '∞ Forever',
          active: forever,
          color: AppColors.agilityColor,
          onTap: () => onForeverChanged(true),
        ),
        const SizedBox(width: 8),
        _ToggleChip(
          label: '📅 Set End Date',
          active: !forever,
          color: AppColors.warning,
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
              builder: (ctx, child) => Theme(
                data: ThemeData.dark().copyWith(
                    colorScheme:
                        const ColorScheme.dark(primary: AppColors.agilityColor)),
                child: child!,
              ),
            );
            if (d != null) onDatePicked(d);
          },
        ),
      ]),
      if (!forever && endDate != null) ...[
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          borderColor: AppColors.warning.withAlpha(80),
          child: Row(children: [
            const Icon(Icons.event, color: AppColors.warning, size: 15),
            const SizedBox(width: 8),
            Text('Ends ${DateFormat('EEE, MMM d, yyyy').format(endDate!)}',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.warning, fontSize: 13)),
          ]),
        ),
      ],
    ]);
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label,
      required this.active,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? color.withAlpha(30) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? color : AppColors.border,
              width: active ? 1.5 : 1),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: active ? color : AppColors.textMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
