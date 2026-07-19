import '../models/saving_method.dart';
import 'saving_calculator.dart';

/// 智能存钱推荐引擎
class SavingRecommender {
  SavingRecommender._();

  /// 根据月收入推荐存钱方案
  /// [monthlyIncome] 月收入金额
  /// [preference] 偏好：easy=轻松 / medium=适中 / hard=挑战
  static List<SavingRecommendation> recommend(
    double monthlyIncome, {
    String preference = 'medium',
  }) {
    final methods = SavingMethod.defaultMethods;
    final recommendations = <SavingRecommendation>[];

    for (final method in methods) {
      double expectedAnnual;

      if (method.id == '365_days' || method.id == '52_weeks') {
        expectedAnnual = method.estimatedAnnual;
      } else if (method.id == 'month_countdown') {
        expectedAnnual = method.estimatedAnnual;
      } else {
        expectedAnnual =
            SavingCalculator.calculateAnnualTotal(method.id,
                monthlyIncome: monthlyIncome);
      }

      // 过滤不适合的方案
      if (!_isSuitable(method.id, monthlyIncome, preference)) continue;

      final reason = _generateReason(
          method.id, monthlyIncome, expectedAnnual, preference);

      recommendations.add(SavingRecommendation(
        method: method,
        expectedAnnual: expectedAnnual,
        reason: reason,
      ));
    }

    // 按预计年存款排序
    recommendations.sort((a, b) => b.expectedAnnual.compareTo(a.expectedAnnual));

    // 根据偏好过滤
    return _filterByPreference(recommendations, preference);
  }

  /// 检查方法是否适合该收入水平
  static bool _isSuitable(
      String methodId, double monthlyIncome, String preference) {
    switch (methodId) {
      case '365_days':
        // 年存66795，建议月收入5000+
        return monthlyIncome >= 3000 || preference == 'hard';
      case '52_weeks':
        // 年存13780，适合所有人
        return true;
      case 'month_countdown':
        // 年存5580，适合低预算
        return true;
      case '333_rule':
        // 月收入>0即可
        return monthlyIncome > 0;
      case '6_jars':
        // 需要一定规划能力，月收入3000+
        return monthlyIncome >= 2000;
      case '12_cd':
        // 需要稳定收入
        return monthlyIncome >= 2500;
      default:
        return true;
    }
  }

  /// 生成推荐理由
  static String _generateReason(
    String methodId,
    double monthlyIncome,
    double expectedAnnual,
    String preference,
  ) {
    final savingsRate = monthlyIncome > 0
        ? ((expectedAnnual / 12) / monthlyIncome * 100).round()
        : 0;

    switch (methodId) {
      case '365_days':
        if (preference == 'hard') {
          return '挑战型首选！年底攒下¥${expectedAnnual.round()}，成就感爆棚';
        }
        return '每天存一点，年底收获¥${expectedAnnual.round()}的惊喜';
      case '52_weeks':
        return '轻松起步，一年攒¥${expectedAnnual.round()}，适合存钱入门';
      case 'month_countdown':
        return '越存越轻松！每月¥465，一年¥5580，零压力攒钱';
      case '333_rule':
        return '每月储蓄$savingsRate%收入，约¥${(monthlyIncome / 3).round()}，简单好坚持';
      case '6_jars':
        return '全面规划财务，储蓄+投资约¥${expectedAnnual.round()}/年';
      case '12_cd':
        return '强制储蓄$savingsRate%月收入，每月¥${(monthlyIncome * 0.3).round()}，还有利息收益';
      default:
        return '推荐尝试';
    }
  }

  /// 根据偏好过滤推荐结果
  static List<SavingRecommendation> _filterByPreference(
    List<SavingRecommendation> recommendations,
    String preference,
  ) {
    switch (preference) {
      case 'easy':
        // 只推荐 easy 难度的
        return recommendations
            .where((r) => r.method.difficulty == 'easy')
            .take(3)
            .toList();
      case 'hard':
        // 包含 hard 难度
        return recommendations.take(3).toList();
      case 'medium':
      default:
        // 排除 hard，优先 easy 和 medium
        return recommendations
            .where((r) => r.method.difficulty != 'hard')
            .take(3)
            .toList();
    }
  }
}
