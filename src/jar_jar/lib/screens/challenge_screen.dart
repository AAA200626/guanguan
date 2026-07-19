import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/saving_method.dart';
import '../providers/saving_provider.dart';
import '../utils/saving_calculator.dart';
import 'method_setup_screen.dart';

/// 挑战页 — 存钱方法列表 + 智能推荐入口
class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(savingMethodsProvider);
    final recommendations = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('🎯 选择存钱方法')),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 收入输入卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _IncomeCard(),
            ),
            // 推荐
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  const Text('🤖 推荐', style: AppTypography.h3),
                  const Spacer(),
                  _PreferenceChips(),
                ]),
              ),
              const SizedBox(height: 4),
              ...recommendations.map((r) => _RecommendCard(recommendation: r)),
              const SizedBox(height: 4),
              const Divider(indent: 14, endIndent: 14),
            ],
            // ── 每月 ──
            if (methods.where((m) => m.ruleType == 'monthly').isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: const Text('📅 每月存钱', style: AppTypography.h3),
              ),
              const SizedBox(height: 2),
              ...methods
                  .where((m) => m.ruleType == 'monthly')
                  .map((m) => _MethodCard(method: m, onTap: () => _goToSetup(context, ref, m))),
              const SizedBox(height: 8),
            ],
            // ── 每日/每周 ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: const Text('📍 每日/每周存钱', style: AppTypography.h3),
            ),
            const SizedBox(height: 2),
            ...methods
                .where((m) => m.ruleType != 'monthly')
                .map((m) => _MethodCard(method: m, onTap: () => _goToSetup(context, ref, m))),
          ],
        ),
      ),
      ),
    );
  }

  void _goToSetup(BuildContext context, WidgetRef ref, SavingMethod method) {
    ref.read(selectedMethodProvider.notifier).state = method;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MethodSetupScreen(method: method)),
    );
  }
}

/// 偏好选择 Chips
class _PreferenceChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(savingPreferenceProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['easy', 'medium', 'hard'].map((p) {
        final label = p == 'easy' ? '轻松' : p == 'medium' ? '适中' : '挑战';
        final selected = current == p;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(
            onTap: () => ref.read(savingPreferenceProvider.notifier).state = p,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(label, style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? Colors.white : AppColors.textLight,
              )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 紧凑收入输入卡片
class _IncomeCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_IncomeCard> createState() => _IncomeCardState();
}

class _IncomeCardState extends ConsumerState<_IncomeCard> {
  final _ctrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final income = ref.read(monthlyIncomeProvider);
    if (income > 0) _ctrl.text = income.round().toString();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = double.tryParse(_ctrl.text);
    if (v != null && v > 0) {
      ref.read(monthlyIncomeProvider.notifier).state = v;
      setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = ref.watch(monthlyIncomeProvider);
    final hasIncome = income > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _editing
          ? Row(children: [
              const Text('¥', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: '月收入',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _submit,
                child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
              ),
            ])
          : GestureDetector(
              onTap: () => setState(() => _editing = true),
              child: Row(children: [
                const Text('🤖', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(hasIncome ? '月收入 ¥${income.round()}' : '点此输入月收入',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(hasIncome ? '下方为智能推荐' : '输入后自动推荐存钱方案',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ),
                const Icon(Icons.edit, color: Colors.white70, size: 18),
              ]),
            ),
    );
  }
}

/// 推荐结果卡片
class _RecommendCard extends ConsumerWidget {
  final SavingRecommendation recommendation;
  const _RecommendCard({required this.recommendation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = recommendation.method;
    final income = ref.watch(monthlyIncomeProvider);
    final annual = income > 0 ? SavingCalculator.calculateAnnualTotal(m.id, monthlyIncome: income) : 0;
    final daily = income > 0 ? SavingCalculator.calculateDailyAverage(m.id, monthlyIncome: income) : 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ref.read(selectedMethodProvider.notifier).state = m;
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => MethodSetupScreen(method: m)));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(m.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600))),
            Text(
              income > 0 ? '日均¥${daily.toStringAsFixed(0)}/年¥${annual.round()}' : '',
              style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textLight, size: 16),
          ]),
        ),
      ),
    );
  }
}

/// 存钱方法卡片（支持动态金额）
class _MethodCard extends ConsumerWidget {
  final SavingMethod method;
  final VoidCallback onTap;
  const _MethodCard({required this.method, required this.onTap});

  IconData get _icon {
    switch (method.icon) {
      case 'calendar': return Icons.calendar_month_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'arrow_downward': return Icons.arrow_downward_rounded;
      case 'pie_chart': return Icons.pie_chart_rounded;
      case 'grid_view': return Icons.grid_view_rounded;
      case 'account_balance': return Icons.account_balance_rounded;
      case 'lock': return Icons.lock_rounded;
      case 'autorenew': return Icons.autorenew_rounded;
      case 'favorite': return Icons.favorite_rounded;
      case 'theater_comedy': return Icons.theater_comedy_rounded;
      case 'handshake': return Icons.handshake_rounded;
      case 'loop': return Icons.loop_rounded;
      case 'account_tree': return Icons.account_tree_rounded;
      default: return Icons.savings_rounded;
    }
  }

  Color get _diffColor {
    switch (method.difficulty) {
      case 'easy': return AppColors.difficultyEasy;
      case 'medium': return AppColors.difficultyMedium;
      case 'hard': return AppColors.difficultyHard;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final income = ref.watch(monthlyIncomeProvider);
    final annual = income > 0
        ? SavingCalculator.calculateAnnualTotal(method.id, monthlyIncome: income)
        : 0;
    final daily = income > 0
        ? SavingCalculator.calculateDailyAverage(method.id, monthlyIncome: income)
        : 0;
    final isMonthly = method.ruleType == 'monthly';
    final monthly = income > 0 ? SavingCalculator.calculateMonthlyTotal(method.id, monthlyIncome: income) : 0;
    final is333 = method.id == '333_rule';
    final amountText = income > 0
        ? (isMonthly
            ? '月存¥${is333 ? monthly.toStringAsFixed(2) : monthly.round()} · 年¥${is333 ? annual.toStringAsFixed(2) : annual.round()}'
            : '日均¥${daily.toStringAsFixed(0)} · 年¥${annual.round()}')
        : '输入收入后计算';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryUltraLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(method.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(amountText, style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
              ]),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Icon(Icons.star_rounded, size: 12,
                  color: i < method.difficultyStars ? _diffColor : AppColors.textLight.withAlpha(40))),
            ),
          ]),
        ),
      ),
    );
  }
}
