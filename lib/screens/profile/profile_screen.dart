import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/hunter.dart';
import '../../providers/quest_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import 'rank_progression_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _titleCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _titleCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestProvider>(
      builder: (context, provider, _) {
        final hunter = provider.hunter;
        _nameCtrl.text = hunter.name;
        _titleCtrl.text = hunter.title ?? '';

        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SafeArea(
                bottom: false,
                child: _buildProfileHero(context, hunter, provider),
              )),
              SliverToBoxAdapter(child: _buildStatsCard(hunter)),
              SliverToBoxAdapter(child: _buildXpChart(hunter)),
              SliverToBoxAdapter(child: _buildProgressStats(provider)),
              SliverToBoxAdapter(child: _buildAchievements(hunter)),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHero(BuildContext context, Hunter hunter, QuestProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgDeep,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Top action row
          Row(
            children: [
              const SystemLabel('[ HUNTER PROFILE ]'),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => RankProgressionScreen(
                    currentRank: hunter.rank,
                    currentLevel: hunter.level,
                  ),
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _rankColor(hunter.rank).withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _rankColor(hunter.rank).withAlpha(60)),
                  ),
                  child: Text('Ranks ›', style: TextStyle(
                    fontSize: 11, color: _rankColor(hunter.rank), fontWeight: FontWeight.w500,
                  )),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                )),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.settings_outlined, size: 16, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              GestureDetector(
                onTap: () => _pickImage(context, provider),
                child: Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bgCard,
                        border: Border.all(
                          color: _rankColor(hunter.rank),
                          width: 2,
                        ),
                      ),
                      child: hunter.profileImagePath != null
                          ? ClipOval(child: Image.file(
                              File(hunter.profileImagePath!),
                              fit: BoxFit.cover,
                            ))
                          : Center(
                              child: Text(
                                hunter.name.isNotEmpty ? hunter.name[0].toUpperCase() : 'H',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: _rankColor(hunter.rank),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.systemBlueDim,
                          border: Border.all(color: AppColors.bgDeep, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (_isEditingName)
                          Expanded(
                            child: TextField(
                              controller: _nameCtrl,
                              autofocus: true,
                              style: AppTextStyles.heading2,
                              decoration: const InputDecoration(isDense: true),
                              onSubmitted: (v) => _saveName(provider, v),
                            ),
                          )
                        else
                          Expanded(
                            child: Text(hunter.name, style: AppTextStyles.heading1.copyWith(fontSize: 20)),
                          ),
                        IconButton(
                          icon: Icon(
                            _isEditingName ? Icons.check : Icons.edit_outlined,
                            size: 18,
                            color: AppColors.systemBlue,
                          ),
                          onPressed: () {
                            if (_isEditingName) {
                              _saveName(provider, _nameCtrl.text);
                            } else {
                              setState(() => _isEditingName = true);
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    if (hunter.title != null && hunter.title!.isNotEmpty)
                      Text(
                        hunter.title!,
                        style: AppTextStyles.caption.copyWith(
                          color: _rankColor(hunter.rank),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RankBadge(rank: hunter.rankLabel, color: _rankColor(hunter.rank), fontSize: 11),
                        const SizedBox(width: 8),
                        Text('Lv. ${hunter.level}', style: AppTextStyles.caption.copyWith(
                          color: AppColors.systemBlue,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          XpProgressBar(
            progress: hunter.xpProgress,
            currentXp: hunter.currentXp,
            maxXp: hunter.xpToNextLevel,
          ),
          const SizedBox(height: 8),
          // Quick stats row
          Row(
            children: [
              _QuickStat(label: 'Streak', value: '${hunter.streakDays}d', icon: Icons.local_fire_department, color: AppColors.warning),
              const SizedBox(width: 8),
              _QuickStat(label: 'Quests', value: hunter.totalQuestsCompleted.toString(), icon: Icons.check_circle_outline, color: AppColors.success),
              const SizedBox(width: 8),
              _QuickStat(label: 'Achievements', value: hunter.achievements.length.toString(), icon: Icons.emoji_events_outlined, color: AppColors.rankS),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatsCard(Hunter hunter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'HUNTER STATS'),
            StatBar(label: 'Strength', value: hunter.stats.strength, color: AppColors.strengthColor, icon: Icons.fitness_center),
            StatBar(label: 'Agility', value: hunter.stats.agility, color: AppColors.agilityColor, icon: Icons.directions_run),
            StatBar(label: 'Intelligence', value: hunter.stats.intelligence, color: AppColors.intelligenceColor, icon: Icons.psychology),
            StatBar(label: 'Endurance', value: hunter.stats.endurance, color: AppColors.healthColor, icon: Icons.shield_outlined),
            StatBar(label: 'Perception', value: hunter.stats.perception, color: AppColors.manaColor, icon: Icons.visibility_outlined),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildXpChart(Hunter hunter) {
    final now = DateTime.now();
    // Last 7 days
    final spots = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final key = DateTime(day.year, day.month, day.day);
      final xp = hunter.xpHistory[key] ?? 0;
      return FlSpot(i.toDouble(), xp.toDouble());
    });

    final dayLabels = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      return days[day.weekday - 1];
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'XP GAINED — LAST 7 DAYS'),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 200,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border,
                      strokeWidth: 0.5,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final idx = val.toInt();
                          if (idx < 0 || idx >= dayLabels.length) return const SizedBox();
                          return Text(dayLabels[idx], style: AppTextStyles.caption.copyWith(fontSize: 10));
                        },
                        interval: 1,
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.systemBlue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.systemBlue,
                          strokeWidth: 1,
                          strokeColor: AppColors.bgDeep,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.systemBlue.withAlpha(60),
                            AppColors.systemBlue.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildProgressStats(QuestProvider provider) {
    final hunter = provider.hunter;
    final total = provider.allQuestsForManagement.length;
    final completed = hunter.totalQuestsCompleted;
    final failed = provider.failedQuests.length;
    final penalties = hunter.totalPenaltiesFaced;
    final penaltiesCompleted = hunter.totalPenaltiesCompleted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'MISSION REPORT'),
            Row(
              children: [
                Expanded(child: _StatBox(label: 'Total Quests', value: total.toString(), color: AppColors.systemBlue)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(label: 'Completed', value: completed.toString(), color: AppColors.success)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(label: 'Failed', value: failed.toString(), color: AppColors.danger)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _StatBox(label: 'Penalties', value: penalties.toString(), color: AppColors.warning)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(label: 'Pen. Done', value: penaltiesCompleted.toString(), color: AppColors.manaColor)),
                const SizedBox(width: 8),
                Expanded(child: _StatBox(
                  label: 'Win Rate',
                  value: (completed + failed) > 0
                      ? '${((completed / (completed + failed)) * 100).round()}%'
                      : '-',
                  color: AppColors.rankS,
                )),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildAchievements(Hunter hunter) {
    if (hunter.achievements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'ACHIEVEMENTS'),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 32),
                      const SizedBox(height: 8),
                      Text('No achievements yet', style: AppTextStyles.body),
                      Text('Complete quests to unlock achievements',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'ACHIEVEMENTS',
              subtitle: '${hunter.achievements.length} unlocked',
            ),
            ...hunter.achievements.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.rankS.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.rankS.withAlpha(60)),
                    ),
                    child: Center(
                      child: Text(a.icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title, style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        )),
                        Text(a.description, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Text('+${a.xpBonus} XP', style: AppTextStyles.caption.copyWith(
                    color: AppColors.xpColor,
                  )),
                ],
              ),
            )),
          ],
        ),
      ),
    ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
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

  void _saveName(QuestProvider provider, String name) {
    if (name.trim().isNotEmpty) {
      provider.updateHunterName(name.trim());
    }
    setState(() => _isEditingName = false);
  }

  Future<void> _pickImage(BuildContext context, QuestProvider provider) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      provider.updateProfileImage(picked.path);
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
          )),
          const SizedBox(height: 3),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
