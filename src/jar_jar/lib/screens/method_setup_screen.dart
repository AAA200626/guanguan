import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/saving_method.dart';
import '../utils/saving_calculator.dart';
import '../providers/saving_provider.dart';
import 'challenge_detail_screen.dart';

final customTargetProvider = StateProvider<String>((ref) => '');

class MethodSetupScreen extends ConsumerWidget {
  final SavingMethod method;
  const MethodSetupScreen({super.key, required this.method});

  IconData get _icon {
    switch (method.icon) {
      case 'calendar': return Icons.calendar_month_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'arrow_downward': return Icons.arrow_downward_rounded;
      case 'pie_chart': return Icons.pie_chart_rounded;
      case 'grid_view': return Icons.grid_view_rounded;
      case 'account_balance': return Icons.account_balance_rounded;
      default: return Icons.savings_rounded;
    }
  }

  List<String> _features() {
    switch (method.id) {
      case '365_days': return ['越往后存越多，适合收入增长期', '等差数列求和，轻松计算', '可自由选择每天存的数字', '打卡日历直观显示每天进度'];
      case '52_weeks': return ['每周存一次，频率适中', '初始额度低，轻松开始', '可以倒序，先苦后甜', '全年可存一笔不小的金额'];
      case 'month_countdown': return ['月初多月末少，越存越轻松', '每月额度递减无压力', '非常适合学生党', '门槛最低的存钱法'];
      case '333_rule': return ['简单好记：收入分三份', '储蓄率约33%，科学合理', '先储蓄再消费的理念', '可根据实际情况调整比例'];
      case '6_jars': return ['六个账户全面管理财务', '生活+自由+教育+储蓄+玩乐+社交', '全面规划每笔收入', '源自经典理财书籍'];
      case '12_cd': return ['每月存一笔一年定期', '次年每月都有存单到期', '兼顾高收益和灵活性', '适合有稳定收入的人'];
      case '10_percent': return ['最简单有效的存钱法', '先存10%，剩下的随便花', '无痛养成储蓄习惯', '适合所有人群'];
      case 'round_up': return ['消费向上取整，差额自动存', '花69存1元，花480存20元', '不知不觉攒下一笔钱', '适合经常小额消费的人'];
      case 'dream_jar': return ['为一个具体梦想而存钱', '设定目标和截止日期', '每天为梦想存一点点', '梦想成真的仪式感'];
      case 'pretend_save': return ['设定虚拟剧情来攒钱', '养娃养宠穿越任你选', '沉浸式存钱小游戏', '小红书超2600万次浏览'];
      case 'bet_save': return ['和朋友约定对赌存钱', '没完成就要请客吃饭', '外部压力等于最强动力', '适合需要监督的人'];
      case 'weekday_cycle': return ['周一存10元到周日存70元', '每周循环轻松无压力', '全年可存一笔不小的钱', '适合喜欢规律节奏的你'];
      case '1234_rule': return ['收入分四份精打细算', '消费10%+保障20%', '投资30%+长期储蓄40%', '适合想系统规划财务的人'];
      default: return ['坚持就是胜利'];
    }
  }

  void _createPlan(BuildContext context, WidgetRef ref, double annualTotal) async {
    final customText = ref.read(customTargetProvider);
    final customAmount = double.tryParse(customText);
    final target = (customAmount != null && customAmount > 0)
        ? customAmount : (annualTotal > 0 ? annualTotal : 10000.0);
    var plan = UserPlan(
      methodId: method.id, methodName: method.name,
      startDate: DateTime.now(), targetAmount: target,
    );
    plan = await createPlan(plan);
    ref.read(activePlanProvider.notifier).state = plan;
    if (context.mounted) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => ChallengeDetailScreen(plan: plan)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(monthlyIncomeProvider);
    final has = income > 0;
    final annual = has ? SavingCalculator.calculateAnnualTotal(method.id, monthlyIncome: income) : 0.0;
    final monthly = has ? SavingCalculator.calculateMonthlyTotal(method.id, monthlyIncome: income) : 0.0;
    final daily = has ? SavingCalculator.calculateDailyAverage(method.id, monthlyIncome: income) : 0.0;
    final first = has ? SavingCalculator.getAmountForPeriod(method.id, 0, monthlyIncome: income) : 0.0;
    final isMonthly = method.ruleType == 'monthly';
    final is333 = method.id == '333_rule';

    return Scaffold(
      appBar: AppBar(title: Text(method.name)),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(children: [
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
            Container(width: 64, height: 64,
              decoration: BoxDecoration(color: AppColors.primaryUltraLight, borderRadius: BorderRadius.circular(16)),
              child: Icon(_icon, color: AppColors.primary, size: 32)),
            const SizedBox(height: 12), Text(method.name, style: AppTypography.h2),
            const SizedBox(height: 6),
            Text(method.description, style: AppTypography.body.copyWith(color: AppColors.textLight), textAlign: TextAlign.center),
          ]))),
          const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            const Text('预计数据', style: AppTypography.h3), const SizedBox(height: 12),
            Row(children: [
              _S(label: '节奏', val: SavingCalculator.getPeriodType(method.id)),
              _S(label: isMonthly ? '月存' : '日均', val: has ? (isMonthly ? (is333 ? monthly.toStringAsFixed(2) : '${monthly.round()}') : daily.toStringAsFixed(0)) : '--'),
              _S(label: '年存', val: has ? (is333 ? annual.toStringAsFixed(2) : '${annual.round()}') : '--'),
            ]),
            const SizedBox(height: 10),
            Container(width: double.infinity, padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primaryUltraLight, borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                const Text('首次存入', style: AppTypography.caption),
                Text(has ? (is333 ? first.toStringAsFixed(2) : first.toStringAsFixed(0)) : '--',
                    style: AppTypography.amount.copyWith(color: AppColors.primary, fontSize: 24)),
              ])),
          ]))),
          const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('自定义目标', style: AppTypography.h3), const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                style: AppTypography.h2.copyWith(color: AppColors.primary),
                decoration: InputDecoration(
                  prefixText: '¥ ', hintText: annual > 0 ? '默认${annual.round()}' : '输入目标金额',
                  filled: true, fillColor: AppColors.backgroundGrey,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (v) => ref.read(customTargetProvider.notifier).state = v,
              ),
            ]))),
          const SizedBox(height: 10),
          Card(child: Padding(padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('方法特点', style: AppTypography.h3), const SizedBox(height: 8),
              ..._features().map((f) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6), Expanded(child: Text(f, style: AppTypography.body)),
              ]))),
            ]))),
          const SizedBox(height: 80),
        ]),
      ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardWhite,
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, -2))]),
        child: SafeArea(child: ElevatedButton(
          onPressed: () => _createPlan(context, ref, annual),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('开始存钱计划', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        )),
      ),
    );
  }
}

class _S extends StatelessWidget {
  final String label, val;
  const _S({required this.label, required this.val});
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(val, style: AppTypography.h3.copyWith(color: AppColors.primary)),
    const SizedBox(height: 2), Text(label, style: AppTypography.caption),
  ]));
}
