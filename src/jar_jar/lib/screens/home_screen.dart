import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/saving_method.dart';
import '../providers/saving_provider.dart';
import '../utils/saving_calculator.dart';
import '../widgets/progress_ring.dart';
import 'challenge_detail_screen.dart';

/// 首页 — 资产总览 + 当前计划
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 启动时加载数据库数据
    ref.watch(loadFromDatabase);

    final activePlan = ref.watch(activePlanProvider);
    final allSavings = _calculateAllSavings(ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text('罐罐'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: _TotalAssetCard(totalSaved: allSavings, plan: activePlan),
            ),
            const SizedBox(height: 8),
            _CurrentPlanCard(plan: activePlan),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToChallenge(ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  double _calculateAllSavings(WidgetRef ref) {
    final records = ref.watch(checkInRecordsProvider);
    return records.fold(0, (sum, r) => sum + r.amount);
  }

  void _goToChallenge(WidgetRef ref) {
    ref.read(bottomTabIndexProvider.notifier).state = 1;
  }
}

String _padNum(int n) => n.toString().padLeft(2, '0');

/// 在首页直接修改今日金额
bool _isDailyMethod(String methodId) => methodId != '333_rule' && methodId != '6_jars' && methodId != '12_cd' && methodId != '10_percent' && methodId != '1234_rule' && methodId != 'bet_save';

double _calcTodayAmount(WidgetRef ref, UserPlan plan) {
  final now = DateTime.now();
  final todayStr = '${now.year}-${_padNum(now.month)}-${_padNum(now.day)}';
  final customAmounts = ref.read(customDayAmountsProvider);
  if (customAmounts.containsKey(todayStr)) return customAmounts[todayStr]!;
  final daysSinceStart = now.difference(plan.startDate).inDays;
  final income = ref.read(monthlyIncomeProvider);
  return SavingCalculator.getAmountForPeriod(plan.methodId, daysSinceStart.clamp(0, 999999), monthlyIncome: income);
}

void _editTodayAmount(BuildContext context, WidgetRef ref, UserPlan plan, double currentAmount) {
  final ctrl = TextEditingController(text: currentAmount.toStringAsFixed(0));
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('✏️ 修改今日金额'),
      content: TextField(
        controller: ctrl, autofocus: true, keyboardType: TextInputType.number,
        style: AppTypography.amount.copyWith(fontSize: 28, color: AppColors.primary),
        decoration: InputDecoration(prefixText: '¥ ', filled: true, fillColor: AppColors.backgroundGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
        ElevatedButton(
          onPressed: () {
            final v = double.tryParse(ctrl.text);
            if (v != null && v > 0) {
              final now = DateTime.now();
              final key = '${now.year}-${_padNum(now.month)}-${_padNum(now.day)}';
              final updated = Map<String, double>.from(ref.read(customDayAmountsProvider));
              updated[key] = v;
              ref.read(customDayAmountsProvider.notifier).state = updated;
            }
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

/// 直接打卡（不跳页）
void _doDirectCheckIn(BuildContext context, WidgetRef ref, UserPlan plan) async {
  final now = DateTime.now();
  final records = ref.read(checkInRecordsProvider);

  // 检查今日是否已打卡
  final alreadyDone = records.any((r) =>
      r.date.year == now.year && r.date.month == now.month && r.date.day == now.day);
  if (alreadyDone) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('✅ 今日已打卡，明天继续加油！'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
    return;
  }

  // 计算今日金额（优先用自定义）
  final todayStr = '${now.year}-${_padNum(now.month)}-${_padNum(now.day)}';
  final customAmounts = ref.read(customDayAmountsProvider);
  final daysSinceStart = now.difference(plan.startDate).inDays;
  final income = ref.read(monthlyIncomeProvider);
  final defaultAmt = SavingCalculator.getAmountForPeriod(plan.methodId, daysSinceStart.clamp(0, 999999), monthlyIncome: income);
  final amount = customAmounts[todayStr] ?? defaultAmt;

  final record = SavingRecord(planId: plan.id ?? 0, date: now, amount: amount, isCompleted: true);
  await saveRecord(record);

  ref.read(checkInRecordsProvider.notifier).state = [...records, record];
  final updatedPlan = plan.copyWith(savedAmount: plan.savedAmount + amount);
  ref.read(activePlanProvider.notifier).state = updatedPlan;
  await updatePlanDb(updatedPlan);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('🎉 打卡成功！+¥${amount.round()}'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }
}

/// 总资产卡片
class _TotalAssetCard extends ConsumerWidget {
  final double totalSaved;
  final UserPlan? plan;

  const _TotalAssetCard({required this.totalSaved, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = plan != null && plan!.targetAmount > 0
        ? totalSaved / plan!.targetAmount
        : 0.0;
    final hasProgress = plan != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text('已存金额', style: AppTypography.caption),
            const SizedBox(height: 4),
            Text(
              '¥ ${totalSaved.toStringAsFixed(0)}',
              style: AppTypography.amount.copyWith(fontSize: 30),
            ),
            const SizedBox(height: 12),
            ProgressRing(
              progress: progress.clamp(0.0, 1.0),
              size: 110,
              strokeWidth: 8,
            ),
            const SizedBox(height: 8),
            if (hasProgress)
              Text(
                '目标 ¥${plan!.targetAmount.round()}  ·  ${(progress * 100).toStringAsFixed(0)}%',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                '设置目标开始存钱吧 ✨',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                ),
              ),
            // 每日/每周法显示今日金额，月存法只显示打卡
            if (plan != null) ...[
              const SizedBox(height: 10),
              if (_isDailyMethod(plan!.methodId)) ...[
                GestureDetector(
                  onTap: () => _editTodayAmount(context, ref, plan!, _calcTodayAmount(ref, plan!)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('今日 ¥${_calcTodayAmount(ref, plan!).toStringAsFixed(0)}',
                        style: AppTypography.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 14, color: AppColors.textLight),
                  ]),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _doDirectCheckIn(context, ref, plan!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('打卡', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 当前计划卡片
class _CurrentPlanCard extends ConsumerWidget {
  final UserPlan? plan;

  const _CurrentPlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(checkInRecordsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text('📋 当前计划', style: AppTypography.h3),
              const Spacer(),
              if (plan != null)
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ChallengeDetailScreen(plan: plan!))),
                  child: Text('详情 ›', style: AppTypography.caption.copyWith(color: AppColors.primary)),
                ),
            ]),
            const SizedBox(height: 10),
            if (plan != null) ...[
              _ActivePlanContent(plan: plan!, records: records),
            ] else ...[
              _EmptyPlanContent(),
            ],
          ],
        ),
      ),
    );
  }
}

/// 活跃计划内容
class _ActivePlanContent extends StatelessWidget {
  final UserPlan plan;
  final List<SavingRecord> records;

  const _ActivePlanContent({required this.plan, required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengeDetailScreen(plan: plan),
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryUltraLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.savings_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.methodName,
                          style: AppTypography.h3
                              .copyWith(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text(
                        '已存 ¥${plan.savedAmount.round()} · 打卡 ${records.length} 次',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: plan.progressPercent,
            backgroundColor: AppColors.primaryUltraLight,
            color: AppColors.primary,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(plan.progressPercent * 100).toStringAsFixed(0)}%',
          style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
      ],
    );
  }
}

/// 空计划占位 — 点击跳转挑战页
class _EmptyPlanContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(bottomTabIndexProvider.notifier).state = 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.primaryUltraLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text('还没有存钱计划',
                  style: AppTypography.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('点击这里选择一个存钱方法开始吧',
                  style: AppTypography.caption),
            ],
          ),
        ),
    );
  }
}
