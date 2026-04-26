import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/quest.dart';
import '../../providers/quest_provider.dart';
import '../../theme/app_theme.dart';
import '../common/common_widgets.dart';

class QuestFormSheet extends StatefulWidget {
  final Quest? quest;
  const QuestFormSheet({super.key, this.quest});

  @override
  State<QuestFormSheet> createState() => _QuestFormSheetState();
}

class _QuestFormSheetState extends State<QuestFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _xpCtrl;
  late TextEditingController _tagCtrl;
  late TextEditingController _penaltyDescCtrl;
  late TextEditingController _penaltyXpCtrl;
  late TextEditingController _unlockCtrl;

  QuestRarity _rarity = QuestRarity.common;
  DateTime _deadline = DateTime.now().add(const Duration(days: 1));
  List<String> _tags = [];
  bool _hasPenalty = false;
  int? _unlockLevel;

  @override
  void initState() {
    super.initState();
    final q = widget.quest;
    _titleCtrl       = TextEditingController(text: q?.title ?? '');
    _descCtrl        = TextEditingController(text: q?.description ?? '');
    _xpCtrl          = TextEditingController(text: q?.xpReward.toString() ?? '100');
    _tagCtrl         = TextEditingController();
    _penaltyDescCtrl = TextEditingController(text: q?.penaltyDescription ?? '');
    _penaltyXpCtrl   = TextEditingController(text: q?.penaltyXp?.toString() ?? '');
    _unlockCtrl      = TextEditingController(text: q?.unlockLevel?.toString() ?? '');
    if (q != null) {
      _rarity      = q.rarity;
      _deadline    = q.deadline;
      _tags        = List.from(q.tags);
      _hasPenalty  = q.hasPenalty;
      _unlockLevel = q.unlockLevel;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _xpCtrl.dispose();
    _tagCtrl.dispose();
    _penaltyDescCtrl.dispose();
    _penaltyXpCtrl.dispose();
    _unlockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.quest != null;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        // Always clear focus so keyboard fully releases on back
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
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(children: [
                  SystemLabel(isEdit ? '[ EDIT QUEST ]' : '[ NEW QUEST ]'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close,
                        color: AppColors.textMuted, size: 20),
                  ),
                ]),
              ),
              const Divider(color: AppColors.border, height: 1),
              // Form body
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
                          _field('Quest Title', _titleCtrl,
                              hint: 'e.g. Morning Workout', required: true),
                          const SizedBox(height: 14),
                          _field('Description', _descCtrl,
                              hint: 'Describe what needs to be done...',
                              maxLines: 3),
                          const SizedBox(height: 14),
                          _field('XP Reward', _xpCtrl,
                              hint: '100',
                              keyboardType: TextInputType.number,
                              required: true),
                          const SizedBox(height: 14),

                          _label('Rarity'),
                          const SizedBox(height: 8),
                          _RaritySelector(
                            selected: _rarity,
                            onChanged: (r) => setState(() => _rarity = r),
                          ),
                          const SizedBox(height: 14),

                          _label('Deadline'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDeadline,
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              child: Row(children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 16, color: AppColors.textMuted),
                                const SizedBox(width: 10),
                                Text(_formatDate(_deadline),
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.textPrimary)),
                                const Spacer(),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.textMuted, size: 18),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 14),

                          _label('Tags'),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                              child: TextField(
                                controller: _tagCtrl,
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14),
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
                                  color: AppColors.systemBlueDim,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 18),
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
                                        color: _rarityColor(_rarity),
                                        onRemove: () =>
                                            setState(() => _tags.remove(t)),
                                      ))
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // Penalty
                          GlassContainer(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.danger, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Enable Penalty Task',
                                        style: AppTextStyles.body.copyWith(
                                            color: AppColors.textPrimary,
                                            fontSize: 13)),
                                    Text('Spawn a penalty if failed',
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _hasPenalty,
                                onChanged: (v) =>
                                    setState(() => _hasPenalty = v),
                                activeColor: AppColors.danger,
                              ),
                            ]),
                          ),

                          if (_hasPenalty) ...[
                            const SizedBox(height: 10),
                            _field('Penalty Task Description', _penaltyDescCtrl,
                                hint: 'e.g. 100 pushups'),
                            const SizedBox(height: 10),
                            _field('XP Deduction on Fail', _penaltyXpCtrl,
                                hint: '50',
                                keyboardType: TextInputType.number),
                          ],
                          const SizedBox(height: 14),

                          _field('Unlock at Level (optional)', _unlockCtrl,
                              hint: 'Leave empty = always available',
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  _unlockLevel = int.tryParse(v)),

                          const SizedBox(height: 28),
                          SystemButton(
                            label: isEdit ? 'UPDATE QUEST' : 'CREATE QUEST',
                            onTap: _submit,
                            color: AppColors.systemBlue,
                            width: double.infinity,
                            icon: isEdit
                                ? Icons.save_outlined
                                : Icons.add_circle_outline,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ), // Padding
    ); // PopScope
  }

  Widget _label(String text) => Text(text,
      style: AppTextStyles.caption
          .copyWith(color: AppColors.textMuted, letterSpacing: 1));

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
    ValueChanged<String>? onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint, isDense: true),
            validator: required
                ? (v) => (v == null || v.isEmpty) ? 'Required' : null
                : null,
          ),
        ],
      );

  Color _rarityColor(QuestRarity r) {
    switch (r) {
      case QuestRarity.legendary: return AppColors.rarityLegendary;
      case QuestRarity.epic:      return AppColors.rarityEpic;
      case QuestRarity.rare:      return AppColors.rarityRare;
      case QuestRarity.common:    return AppColors.rarityCommon;
    }
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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme:
                const ColorScheme.dark(primary: AppColors.systemBlue)),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
            colorScheme:
                const ColorScheme.dark(primary: AppColors.systemBlue)),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() {
      _deadline = DateTime(
          date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDate(DateTime d) {
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday-1]}, ${months[d.month-1]} ${d.day}'
        ' — ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider  = context.read<QuestProvider>();
    final xp        = int.tryParse(_xpCtrl.text) ?? 100;
    final penaltyXp = int.tryParse(_penaltyXpCtrl.text);
    final unlock    = int.tryParse(_unlockCtrl.text);

    if (widget.quest == null) {
      provider.addQuest(Quest(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        xpReward: xp,
        deadline: _deadline,
        rarity: _rarity,
        tags: _tags,
        hasPenalty: _hasPenalty,
        penaltyDescription:
            _hasPenalty ? _penaltyDescCtrl.text.trim() : null,
        penaltyXp: _hasPenalty ? penaltyXp : null,
        unlockLevel: unlock,
      ));
    } else {
      provider.updateQuest(widget.quest!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        xpReward: xp,
        deadline: _deadline,
        rarity: _rarity,
        tags: _tags,
        hasPenalty: _hasPenalty,
        penaltyDescription:
            _hasPenalty ? _penaltyDescCtrl.text.trim() : null,
        penaltyXp: _hasPenalty ? penaltyXp : null,
        unlockLevel: unlock,
      ));
    }
    Navigator.pop(context);
  }
}

class _RaritySelector extends StatelessWidget {
  final QuestRarity selected;
  final ValueChanged<QuestRarity> onChanged;
  const _RaritySelector({required this.selected, required this.onChanged});

  Color _color(QuestRarity r) {
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
        final color  = _color(r);
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
