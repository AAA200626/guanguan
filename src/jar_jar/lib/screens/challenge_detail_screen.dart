import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/saving_method.dart';
import '../utils/saving_calculator.dart';
import '../providers/saving_provider.dart';
import '../utils/database_helper.dart';
import '../widgets/progress_ring.dart';

/// 挑战详情页 — 每日打卡核心界面
class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final UserPlan plan;

  const ChallengeDetailScreen({super.key, required this.plan});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState
    extends ConsumerState<ChallengeDetailScreen> {
  late UserPlan _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    if (_plan.id == null) return;
    final records = await DatabaseHelper.instance.getRecordsByPlan(_plan.id!);
    if (mounted) {
      ref.read(checkInRecordsProvider.notifier).state = records;
      // 同步已存金额
      final totalSaved = records.fold(0.0, (sum, r) => sum + r.amount);
      setState(() {
        _plan = _plan.copyWith(savedAmount: totalSaved);
      });
      ref.read(activePlanProvider.notifier).state = _plan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final method =
        SavingMethod.defaultMethods.firstWhere((m) => m.id == _plan.methodId);
    final records = ref.watch(checkInRecordsProvider);
    final monthlyIncome = ref.watch(monthlyIncomeProvider);

    // 计算当前周期
    final now = DateTime.now();
    final startDate = _plan.startDate;
    final daysSinceStart = now.difference(startDate).inDays;
    final currentPeriodIndex = daysSinceStart.clamp(0, 999999);

    final customAmounts = ref.watch(customDayAmountsProvider);
    final todayStr = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    final defaultAmount = SavingCalculator.getAmountForPeriod(
        method.id, currentPeriodIndex,
        monthlyIncome: monthlyIncome);
    final todayAmount = customAmounts[todayStr] ?? defaultAmount;
    final isTodayChecked = records.any((r) =>
        r.date.year == now.year &&
        r.date.month == now.month &&
        r.date.day == now.day);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(_plan.methodName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            // 总进度卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '第 ${currentPeriodIndex + 1} ${_periodUnit(method.ruleType)}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProgressRing(
                      progress: _plan.progressPercent,
                      size: 150,
                      strokeWidth: 12,
                      centerChild: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¥${_plan.savedAmount.round()}',
                            style: AppTypography.h2,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '目标 ¥${_plan.targetAmount.round()}',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${(_plan.progressPercent * 100).toStringAsFixed(1)}% 完成',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 今日/今月打卡卡片
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _isMonthlyMethod(method.id) ? '📅 本月 ${now.year}/${now.month}' : '📅 今天 $todayStr',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      SavingCalculator.getPeriodLabel(
                          method.id, currentPeriodIndex),
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isMonthlyMethod(method.id) ? '今月存入' : '今日存入',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '¥ ${todayAmount.toStringAsFixed(0)}',
                      style: AppTypography.amount.copyWith(
                        color: isTodayChecked
                            ? AppColors.textLight
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 打卡按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isTodayChecked
                            ? null
                            : () => _doCheckIn(todayAmount),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTodayChecked
                              ? AppColors.backgroundGrey
                              : AppColors.primary,
                          foregroundColor: isTodayChecked
                              ? AppColors.textLight
                              : Colors.white,
                          disabledBackgroundColor: AppColors.backgroundGrey,
                          disabledForegroundColor: AppColors.textLight,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isTodayChecked
                                  ? Icons.check_circle_rounded
                                  : Icons.touch_app_rounded,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isTodayChecked
                                  ? (_isMonthlyMethod(method.id) ? '今月已打卡 ✓' : '今日已打卡 ✓')
                                  : '打卡',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 日历（日/周法显示天，月存法显示月）
            _buildCalendar(method.id, records, monthlyIncome),
            const SizedBox(height: 16),
            // 最近记录
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📝 最近记录', style: AppTypography.h3),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            '还没有打卡记录，今天开始吧！',
                            style: AppTypography.caption,
                          ),
                        ),
                      )
                    else
                      ...records.reversed.take(5).map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 18,
                                    color: r.isCompleted
                                        ? AppColors.primary
                                        : AppColors.textLight),
                                const SizedBox(width: 8),
                                Text(
                                  '${r.date.month}/${r.date.day}',
                                  style: AppTypography.body,
                                ),
                                const Spacer(),
                                Text(
                                  '¥${r.amount.round()}',
                                  style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      ),
    );
  }

  String _periodUnit(String ruleType) {
    switch (ruleType) {
      case 'daily':
        return '天';
      case 'weekly':
        return '周';
      case 'monthly':
        return '个月';
      default:
        return '';
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  bool _isMonthlyMethod(String methodId) =>
      methodId == '333_rule' || methodId == '6_jars' || methodId == '12_cd' ||
      methodId == '10_percent' || methodId == '1234_rule' || methodId == 'bet_save';

  Widget _buildCalendar(String methodId, List<SavingRecord> records, double income) {
    final now = DateTime.now();
    if (_isMonthlyMethod(methodId)) {
      // 月存法：显示12个月
      final checkedMonths = records.map((r) => r.date.month).toSet();
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('📅 ${now.year}年', style: AppTypography.h3),
              const Spacer(),
              Text('${checkedMonths.length}/12 月', style: AppTypography.caption.copyWith(color: AppColors.primary)),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: List.generate(12, (i) {
              final m = i + 1;
              final checked = checkedMonths.contains(m);
              return Container(
                width: (MediaQuery.of(context).size.width - 72) / 6,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${m}月', textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: checked ? Colors.white : AppColors.textDark,
                )),
              );
            })),
          ]),
        ),
      );
    }
    // 日/周法：显示当月日历
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDow = DateTime(year, month, 1).weekday;
    final checkedDays = records.where((r) => r.date.year == year && r.date.month == month).map((r) => r.date.day).toSet();
    final rows = ((firstDow - 1 + daysInMonth) / 7).ceil();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📅 ${year}年${month}月', style: AppTypography.h3),
          const SizedBox(height: 10),
          Row(children: ['一','二','三','四','五','六','日'].map((d) => Expanded(child: Center(child: Text(d, style: AppTypography.caption.copyWith(fontSize: 10))))).toList()),
          const SizedBox(height: 4),
          ...List.generate(rows, (r) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(children: List.generate(7, (c) {
              final day = r * 7 + c - firstDow + 2;
              if (day < 1 || day > daysInMonth) return const Expanded(child: SizedBox.shrink());
              final isChecked = checkedDays.contains(day);
              final isToday = now.day == day;
              return Expanded(child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isChecked ? AppColors.primary : AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(5),
                  border: isToday && !isChecked ? Border.all(color: AppColors.primary, width: 1.5) : null,
                ),
                child: AspectRatio(aspectRatio: 1,
                  child: Center(child: Text('$day', style: TextStyle(fontSize: 11, fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isChecked ? Colors.white : AppColors.textDark)))),
              ));
            })),
          )),
        ]),
      ),
    );
  }

  void _doCheckIn(double amount) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
    final customAmounts = ref.read(customDayAmountsProvider);
    final finalAmount = customAmounts[todayStr] ?? amount;

    final record = SavingRecord(
      planId: _plan.id ?? 0,
      date: now,
      amount: finalAmount,
      isCompleted: true,
    );

    await saveRecord(record);
    ref.read(checkInRecordsProvider.notifier).state = [
      ...ref.read(checkInRecordsProvider), record,
    ];

    setState(() {
      _plan = _plan.copyWith(savedAmount: _plan.savedAmount + finalAmount);
    });
    await updatePlanDb(_plan);
    ref.read(activePlanProvider.notifier).state = _plan;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🎉 打卡成功！+¥${finalAmount.round()}'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    }
  }
}