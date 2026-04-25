import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quest_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const SystemLabel('[ SYSTEM SETTINGS ]'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          Text('Settings', style: AppTextStyles.heading1),
          const SizedBox(height: 20),

          // Profile section
          const SystemLabel('[ PROFILE ]'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Hunter Name',
            subtitle: 'Change your hunter name',
            onTap: () => _editName(context),
          ),
          _SettingsTile(
            icon: Icons.title_rounded,
            title: 'Edit Hunter Title',
            subtitle: 'Set a custom title',
            onTap: () => _editTitle(context),
          ),

          const SizedBox(height: 20),
          const SystemLabel('[ DATA ]'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Reset All Data',
            subtitle: 'Clear all quests and reset profile',
            titleColor: AppColors.danger,
            onTap: () => _resetData(context),
          ),

          const SizedBox(height: 20),
          const SystemLabel('[ ABOUT ]'),
          const SizedBox(height: 10),
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solo Leveling System', style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 4),
                Text('Version 1.0.0', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Text(
                  'A personal system builder inspired by Solo Leveling. '
                  'Build your own quests, earn XP, climb the ranks, '
                  'and become the strongest version of yourself.',
                  style: AppTextStyles.body.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editName(BuildContext context) {
    final ctrl = TextEditingController(
      text: context.read<QuestProvider>().hunter.name,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const SystemLabel('[ EDIT NAME ]'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Hunter name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<QuestProvider>().updateHunterName(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTitle(BuildContext context) {
    final ctrl = TextEditingController(
      text: context.read<QuestProvider>().hunter.title ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const SystemLabel('[ EDIT TITLE ]'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Shadow Monarch',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<QuestProvider>().updateHunterTitle(
                ctrl.text.trim().isEmpty ? null : ctrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetData(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.danger),
        ),
        title: Text('Reset All Data?',
            style: AppTextStyles.heading2.copyWith(color: AppColors.danger)),
        content: Text(
          'This will permanently delete all your quests, XP, and progress. '
          'This action cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<QuestProvider>().init();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: titleColor ?? AppColors.systemBlue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body.copyWith(
                    color: titleColor ?? AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
