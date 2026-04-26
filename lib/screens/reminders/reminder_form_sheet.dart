import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class ReminderFormSheet extends StatefulWidget {
  final Reminder? reminder;
  const ReminderFormSheet({super.key, this.reminder});

  @override
  State<ReminderFormSheet> createState() => _ReminderFormSheetState();
}

class _ReminderFormSheetState extends State<ReminderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _noteCtrl;
  late TextEditingController _emojiCtrl;

  ReminderCategory _category = ReminderCategory.general;
  Color _color = const Color(0xFF4A9EFF);
  bool _isPinned = false;

  static const _colorOptions = [
    Color(0xFF4A9EFF),  // blue
    Color(0xFFA855F7),  // purple
    Color(0xFF22C55E),  // green
    Color(0xFFEF4444),  // red
    Color(0xFFF59E0B),  // amber
    Color(0xFF06B6D4),  // cyan
    Color(0xFFFFD700),  // gold
    Color(0xFFF97316),  // orange
  ];

  static const _emojiOptions = [
    '📌', '💧', '🔥', '⚔', '📖', '💪', '🧘', '🌅',
    '🎯', '💡', '⚡', '🏆', '📊', '🎮', '🌿', '✨',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _noteCtrl = TextEditingController(text: r?.note ?? '');
    _emojiCtrl = TextEditingController(text: r?.emoji ?? '📌');
    if (r != null) {
      _category = r.category;
      _color = r.color;
      _isPinned = r.isPinned;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _emojiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reminder != null;

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
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) => Column(
            children: [
              Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(children: [
                const Icon(Icons.push_pin_outlined,
                    color: AppColors.manaColor, size: 16),
                const SizedBox(width: 8),
                SystemLabel(
                    isEdit ? '[ EDIT REMINDER ]' : '[ NEW REMINDER ]',
                    color: AppColors.manaColor),
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
                        // Emoji picker + title row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Emoji selector
                            GestureDetector(
                              onTap: () => _showEmojiPicker(context),
                              child: Container(
                                width: 52, height: 52,
                                decoration: BoxDecoration(
                                  color: _color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _color.withAlpha(100)),
                                ),
                                child: Center(
                                  child: Text(_emojiCtrl.text,
                                      style: const TextStyle(fontSize: 24)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _titleCtrl,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontSize: 15),
                                decoration: const InputDecoration(
                                    hintText: 'What to remember?',
                                    isDense: true,
                                    labelText: 'TITLE'),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Note
                        _label('NOTE (optional)'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _noteCtrl,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Any details, context, or motivation...',
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Category
                        _label('CATEGORY'),
                        const SizedBox(height: 8),
                        _CategorySelector(
                            selected: _category,
                            onChanged: (c) => setState(() => _category = c)),
                        const SizedBox(height: 18),

                        // Color
                        _label('COLOR'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10, runSpacing: 10,
                          children: _colorOptions.map((c) {
                            final active = c.value == _color.value;
                            return GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: active
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 2.5),
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                              color: c.withAlpha(100),
                                              blurRadius: 8,
                                              spreadRadius: 1)
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 18),

                        // Pin toggle
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(children: [
                            const Icon(Icons.push_pin_outlined,
                                color: AppColors.manaColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pin to top',
                                      style: AppTextStyles.body.copyWith(
                                          color: AppColors.textPrimary,
                                          fontSize: 13)),
                                  Text('Always show at the top of reminders',
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPinned,
                              onChanged: (v) => setState(() => _isPinned = v),
                              activeColor: AppColors.manaColor,
                            ),
                          ]),
                        ),
                        const SizedBox(height: 28),

                        SystemButton(
                          label: isEdit
                              ? 'UPDATE REMINDER'
                              : 'SAVE REMINDER',
                          onTap: _submit,
                          color: AppColors.manaColor,
                          width: double.infinity,
                          icon: Icons.push_pin_outlined,
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

  Widget _label(String t) => Text(t,
      style: AppTextStyles.caption
          .copyWith(color: AppColors.textMuted, letterSpacing: 1));

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SystemLabel('[ CHOOSE EMOJI ]'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _emojiOptions.map((e) => GestureDetector(
                    onTap: () {
                      setState(() => _emojiCtrl.text = e);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                          child:
                              Text(e, style: const TextStyle(fontSize: 22))),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ReminderProvider>();

    if (widget.reminder == null) {
      provider.addReminder(Reminder(
        title: _titleCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        category: _category,
        emoji: _emojiCtrl.text,
        isPinned: _isPinned,
        color: _color,
      ));
    } else {
      provider.updateReminder(widget.reminder!.copyWith(
        title: _titleCtrl.text.trim(),
        note: _noteCtrl.text.trim(),
        category: _category,
        emoji: _emojiCtrl.text,
        isPinned: _isPinned,
        color: _color,
      ));
    }
    Navigator.pop(context);
  }
}

class _CategorySelector extends StatelessWidget {
  final ReminderCategory selected;
  final ValueChanged<ReminderCategory> onChanged;
  const _CategorySelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: ReminderCategory.values.map((c) {
        final active = c == selected;
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: active ? AppColors.manaColor.withAlpha(30) : AppColors.bgCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: active ? AppColors.manaColor : AppColors.border,
                  width: active ? 1.5 : 1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(c.icon,
                  size: 13,
                  color: active ? AppColors.manaColor : AppColors.textMuted),
              const SizedBox(width: 5),
              Text(c.label,
                  style: TextStyle(
                      fontSize: 11,
                      color: active ? AppColors.manaColor : AppColors.textMuted,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
