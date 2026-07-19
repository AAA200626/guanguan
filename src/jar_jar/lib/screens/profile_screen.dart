import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/saving_method.dart';
import '../providers/saving_provider.dart';

/// 头像路径 provider
final avatarPathProvider = StateProvider<String?>((ref) => null);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(loadFromDatabase);
    final activePlan = ref.watch(activePlanProvider);
    final records = ref.watch(checkInRecordsProvider);
    final userName = ref.watch(userNameProvider);
    final avatarPath = ref.watch(avatarPathProvider);
    final allSavings = records.fold(0.0, (s, r) => s + r.amount);
    final today = DateTime.now();
    final checkedDays = records.length;
    final currentStreak = _streak(records, today);
    final badges = _badges(records, activePlan, currentStreak, allSavings);
    final earnedCount = badges.where((b) => b.earned).length;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── 头像 + 昵称 ──
          GestureDetector(
            onTap: () => _pickAvatar(context, ref),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryUltraLight,
              backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
              child: avatarPath == null
                  ? Text(userName.isNotEmpty ? userName[0] : '我',
                      style: const TextStyle(fontSize: 32, color: AppColors.primary))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _editName(context, ref),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(userName, style: AppTypography.h3),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 14, color: AppColors.textLight),
            ]),
          ),
          if (activePlan != null)
            Text('${activePlan.methodName} · 打卡$checkedDays次',
                style: AppTypography.caption),

          const SizedBox(height: 16),

          // ── 统计 4 格 ──
          Row(children: [
            _StatCard(icon: Icons.savings_rounded, color: AppColors.primary, value: '¥${allSavings.round()}', label: '已存'),
            _StatCard(icon: Icons.calendar_today_rounded, color: AppColors.accent, value: '$checkedDays天', label: '打卡'),
            _StatCard(icon: Icons.local_fire_department_rounded, color: const Color(0xFFFF8C42), value: '$currentStreak天', label: '连续'),
            _StatCard(icon: Icons.emoji_events_rounded, color: AppColors.accent, value: '$earnedCount个', label: '徽章'),
          ]),

          const SizedBox(height: 16),

          // ── 记录 ──
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('📝 最近记录', style: AppTypography.h3),
                const SizedBox(height: 8),
                if (records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: Text('还没有打卡记录', style: AppTypography.caption)),
                  )
                else
                  ...records.take(5).map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('${r.date.month}/${r.date.day}', style: AppTypography.body),
                          const Spacer(),
                          Text('+¥${r.amount.round()}',
                              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ]),
                      )),
              ]),
            ),
          ),

          const SizedBox(height: 12),

          // ── 成就徽章（可折叠） ──
          _CollapsibleBadges(badges: badges),

        ]),
      ),
      ),
    );
  }

  void _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400);
    if (file != null) {
      ref.read(avatarPathProvider.notifier).state = file.path;
    }
  }

  void _editName(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: ref.read(userNameProvider));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('✏️ 修改昵称'),
        content: TextField(
          controller: ctrl, autofocus: true, maxLength: 12,
          decoration: InputDecoration(
            hintText: '输入你的昵称', filled: true, fillColor: AppColors.backgroundGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final n = ctrl.text.trim();
              if (n.isNotEmpty) ref.read(userNameProvider.notifier).state = n;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  int _streak(List<SavingRecord> records, DateTime today) {
    if (records.isEmpty) return 0;
    final dates = records.map((r) => r.date).toSet().toList()..sort((a, b) => b.compareTo(a));
    int s = 0;
    var d = today;
    for (final date in dates) {
      if (date.year == d.year && date.month == d.month && date.day == d.day) {
        s++;
        d = d.subtract(const Duration(days: 1));
      } else if (date.isBefore(d)) {
        break;
      }
    }
    return s;
  }

  List<_Badge> _badges(List<SavingRecord> records, UserPlan? plan, int streak, double total) {
    final totalCount = records.length;
    final weekTotal = records.where((r) => r.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).fold(0.0, (s, r) => s + r.amount);
    return [
      // 入门
      _Badge('🪙', '初次打卡', totalCount >= 1),
      _Badge('🎯', '首个计划', plan != null),
      _Badge('📅', '打卡3天', totalCount >= 3),
      _Badge('🚀', '首周坚持', streak >= 7),
      // 连续
      _Badge('🔥', '连续7天', streak >= 7),
      _Badge('⚡', '连续14天', streak >= 14),
      _Badge('💪', '连续21天', streak >= 21),
      _Badge('🌟', '连续30天', streak >= 30),
      _Badge('🏅', '连续60天', streak >= 60),
      _Badge('💎', '连续100天', streak >= 100),
      // 金额里程碑
      _Badge('🥉', '百元户', total >= 100),
      _Badge('🥈', '五百元户', total >= 500),
      _Badge('💰', '千元户', total >= 1000),
      _Badge('💵', '五千元户', total >= 5000),
      _Badge('💎', '万元户', total >= 10000),
      _Badge('🏦', '三万元户', total >= 30000),
      _Badge('👑', '五万元户', total >= 50000),
      _Badge('🏆', '十万元户', total >= 100000),
      // 打卡次数
      _Badge('📝', '打卡10次', totalCount >= 10),
      _Badge('📋', '打卡30次', totalCount >= 30),
      _Badge('📚', '打卡50次', totalCount >= 50),
      _Badge('📖', '打卡100次', totalCount >= 100),
      _Badge('🗂️', '打卡365次', totalCount >= 365),
      // 行为特征
      _Badge('🌙', '夜猫子', records.where((r) => r.date.hour >= 22 || r.date.hour < 6).length >= 5),
      _Badge('🌅', '早鸟', records.where((r) => r.date.hour >= 5 && r.date.hour < 8).length >= 5),
      _Badge('🌧️', '风雨无阻', records.where((r) => r.date.weekday == 6 || r.date.weekday == 7).length >= 10),
      _Badge('🎯', '完美一月', _countDaysInMonth(records, DateTime.now()) == DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day),
      _Badge('📈', '本周最多', weekTotal >= 500),
      _Badge('💸', '单日最高', records.isNotEmpty && records.map((r) => r.amount).reduce((a, b) => a > b ? a : b) >= 200),
      // 挑战
      _Badge('🏁', '挑战完成', plan != null && plan.progressPercent >= 1.0),
      _Badge('🎪', '同时进行中', plan != null && plan.status == 'active'),
      _Badge('🔄', '多次挑战', plan != null && totalCount >= 60),
      _Badge('🥇', '全勤王者', streak >= 90),
      _Badge('🐉', '存钱传说', total >= 50000 && streak >= 60),
      _Badge('👼', '新年决心', _isJanStreak(records, streak)),
    ];
  }

  int _countDaysInMonth(List<SavingRecord> records, DateTime now) {
    return records.where((r) => r.date.year == now.year && r.date.month == now.month)
        .map((r) => r.date.day).toSet().length;
  }

  bool _isJanStreak(List<SavingRecord> records, int streak) {
    final now = DateTime.now();
    return now.month == 1 && streak >= 7;
  }

}

/// 统计小格
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text(label, style: AppTypography.caption),
          ]),
        ),
      ),
    );
  }
}

/// 可折叠徽章卡片
class _CollapsibleBadges extends StatefulWidget {
  final List<_Badge> badges;
  const _CollapsibleBadges({required this.badges});
  @override
  State<_CollapsibleBadges> createState() => _CollapsibleBadgesState();
}

class _CollapsibleBadgesState extends State<_CollapsibleBadges> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final earnedCount = widget.badges.where((b) => b.earned).length;
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              const Text('🏅 成就徽章', style: AppTypography.h3),
              const SizedBox(width: 8),
              Text('$earnedCount/${widget.badges.length}',
                  style: AppTypography.caption.copyWith(color: AppColors.primary)),
              const Spacer(),
              Icon(_open ? Icons.expand_less : Icons.expand_more, color: AppColors.textLight),
            ]),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Wrap(spacing: 12, runSpacing: 10, children: widget.badges.map((b) {
              return Column(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: b.earned ? AppColors.primaryUltraLight : AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                    border: b.earned ? Border.all(color: AppColors.primary, width: 1.5) : null,
                  ),
                  child: Center(child: Text(b.emoji, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(height: 4),
                Text(b.label, style: TextStyle(fontSize: 10, color: b.earned ? AppColors.textDark : AppColors.textLight)),
              ]);
            }).toList()),
          ),
      ]),
    );
  }
}

class _Badge {
  final String emoji;
  final String label;
  final bool earned;
  const _Badge(this.emoji, this.label, this.earned);
}
