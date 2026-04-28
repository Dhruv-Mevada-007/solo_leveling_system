import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/quest.dart';
import '../../providers/quest_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/quest/quest_card.dart';
import '../../widgets/quest/quest_form_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Active', 'No Deadline', 'Completed', 'Failed', 'Locked'];

  String _searchQuery = '';
  String? _filterRarity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuestProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bgDeep,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildQuestList(provider.allQuestsForManagement, provider),
                      _buildQuestList(provider.activeQuests, provider),
                      _buildNoDeadlineList(provider.noDeadlineQuests, provider),
                      _buildQuestList(provider.completedQuests, provider),
                      _buildQuestList(provider.failedQuests, provider),
                      _buildQuestList(provider.lockedQuests, provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const QuestFormSheet(),
            ),
            backgroundColor: AppColors.systemBlueDim,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SystemLabel('[ TASK MANAGEMENT ]'),
              const SizedBox(height: 4),
              Text('Quest Archive', style: AppTextStyles.heading1),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.systemBlue),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search quests...',
          prefixIcon: const Icon(Icons.search, size: 18),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.systemBlue,
        indicatorWeight: 2,
        labelColor: AppColors.systemBlue,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(
          fontSize: 11,
          letterSpacing: 1,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11, letterSpacing: 1),
        tabs: _tabs.map((t) => Tab(text: t, height: 38)).toList(),
      ),
    );
  }

  Widget _buildQuestList(List<Quest> quests, QuestProvider provider) {
    final filtered = quests.where((q) {
      final matchSearch = _searchQuery.isEmpty ||
          q.title.toLowerCase().contains(_searchQuery) ||
          q.description.toLowerCase().contains(_searchQuery) ||
          q.tags.any((t) => t.toLowerCase().contains(_searchQuery));
      final matchRarity = _filterRarity == null || q.rarityLabel == _filterRarity;
      return matchSearch && matchRarity;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('No quests found', style: AppTextStyles.body),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final q = filtered[i];
        return CompactQuestCard(
          key: ValueKey(q.id),
          quest: q,
          onTap: () => _editQuest(context, q),
          onDelete: () => _deleteQuest(context, provider, q.id),
        ).animate(delay: (i * 30).ms).fadeIn(duration: 200.ms).slideX(begin: -0.02);
      },
    );
  }

  void _editQuest(BuildContext context, Quest quest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuestFormSheet(quest: quest),
    );
  }

  Widget _buildNoDeadlineList(List<Quest> quests, QuestProvider provider) {
    final filtered = quests.where((q) {
      return _searchQuery.isEmpty ||
          q.title.toLowerCase().contains(_searchQuery) ||
          q.description.toLowerCase().contains(_searchQuery) ||
          q.tags.any((t) => t.toLowerCase().contains(_searchQuery));
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.all_inclusive_rounded,
                size: 40, color: AppColors.agilityColor),
            const SizedBox(height: 12),
            Text('No open-ended quests yet',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.agilityColor)),
            const SizedBox(height: 4),
            Text('Create a quest with "No Deadline" to see it here',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            children: [
              const Icon(Icons.all_inclusive_rounded,
                  size: 14, color: AppColors.agilityColor),
              const SizedBox(width: 6),
              Text(
                '${filtered.length} open-ended quest${filtered.length != 1 ? 's' : ''}  •  complete at your own pace',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.agilityColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
            physics: const BouncingScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final q = filtered[i];
              return CompactQuestCard(
                key: ValueKey(q.id),
                quest: q,
                onTap: () => _editQuest(context, q),
                onDelete: () => _deleteQuest(context, provider, q.id),
              ).animate(delay: (i * 30).ms).fadeIn(duration: 200.ms).slideX(begin: -0.02);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _deleteQuest(BuildContext context, QuestProvider provider, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text('Delete Quest?', style: AppTextStyles.heading2.copyWith(fontSize: 16)),
        content: Text('This cannot be undone.', style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) provider.deleteQuest(id);
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SystemLabel('[ FILTER BY RARITY ]'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                null,
                ...QuestRarity.values.map((r) => r.name.toUpperCase()),
              ].map((rarity) {
                final isSelected = _filterRarity == rarity;
                return GestureDetector(
                  onTap: () {
                    setState(() => _filterRarity = rarity);
                    Navigator.pop(context);
                  },
                  child: Chip(
                    label: Text(rarity ?? 'All'),
                    backgroundColor: isSelected ? AppColors.systemBlueDim : AppColors.bgCard,
                    side: BorderSide(
                      color: isSelected ? AppColors.systemBlue : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.systemBlue : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
