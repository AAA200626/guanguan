/// 存钱计算引擎 — 每种方法用真实公式
class SavingCalculator {
  SavingCalculator._();

  /// 当月天数
  static int currentMonthDays() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  /// 某周期的应存金额（按方法真实公式）
  /// periodIndex: 0-based (第1天=0, 第1周=0, 第1月=0)
  static double getAmountForPeriod(String methodId, int periodIndex,
      {double monthlyIncome = 5000}) {
    switch (methodId) {
      // ── 递增型 ──
      case '365_days':
        // 第N天存N元 (N = periodIndex+1)
        return (periodIndex + 1).toDouble();

      case '52_weeks':
        // 第N周存N×10元
        return (periodIndex + 1) * 10.0;

      // ── 倒数型 ──
      case 'month_countdown':
        // 每月1号=当月天数, 2号=当月天数-1, ... 最后一天=1
        final days = currentMonthDays();
        return (days - periodIndex).clamp(1, days).toDouble();

      // ── 星期循环型 ──
      case 'weekday_cycle':
        // 周一10→周二20→...→周日70（periodIndex mod 7）
        return ((periodIndex % 7) + 1) * 10.0;

      // ── 收入比例型（每月固定） ──
      case '333_rule':
        return monthlyIncome / 3;

      case '10_percent':
        return monthlyIncome * 0.10;

      case '1234_rule':
        // 储蓄40% + 投资30% = 70%
        return monthlyIncome * 0.70;

      case '12_cd':
        return monthlyIncome * 0.30;

      case '6_jars':
        return monthlyIncome * 0.20;

      // ── 小额趣味型 ──
      case 'round_up':
        return 10.0; // 每次消费取整，日均约10元

      case 'dream_jar':
        return monthlyIncome * 0.15;

      case 'pretend_save':
        return 20.0; // 假装消费，日均20元

      case 'bet_save':
        return monthlyIncome * 0.20;

      default:
        return monthlyIncome * 0.20;
    }
  }

  /// 预计年存总额
  static double calculateAnnualTotal(String methodId,
      {double monthlyIncome = 5000}) {
    switch (methodId) {
      case '365_days':
        // 等差数列: (1+365)×365÷2
        return 66795.0;

      case '52_weeks':
        // (10+520)×52÷2
        return 13780.0;

      case 'month_countdown':
        // 每月(1+30)×30÷2×12/30 ≈ 5580
        return 5580.0;

      case 'weekday_cycle':
        // 每周280 × 52
        return 14560.0;

      case '333_rule':
        return (monthlyIncome / 3) * 12;

      case '10_percent':
        return monthlyIncome * 0.10 * 12;

      case '1234_rule':
        return monthlyIncome * 0.70 * 12;

      case '12_cd':
        return monthlyIncome * 0.30 * 12;

      case '6_jars':
        return monthlyIncome * 0.20 * 12;

      case 'round_up':
        return 3650.0;

      case 'dream_jar':
        return monthlyIncome * 0.15 * 12;

      case 'pretend_save':
        return 7300.0;

      case 'bet_save':
        return monthlyIncome * 0.20 * 12;

      default:
        return monthlyIncome * 0.20 * 12;
    }
  }

  /// 今日存款（快捷方法）
  static double dailyAmount(String methodId, {double monthlyIncome = 5000}) {
    return getAmountForPeriod(methodId, 0, monthlyIncome: monthlyIncome);
  }

  /// 月均存款
  static double calculateMonthlyTotal(String methodId,
      {double monthlyIncome = 5000}) {
    return calculateAnnualTotal(methodId, monthlyIncome: monthlyIncome) / 12;
  }

  /// 日均存款
  static double calculateDailyAverage(String methodId,
      {double monthlyIncome = 5000}) {
    final daily = getAmountForPeriod(methodId, 0, monthlyIncome: monthlyIncome);
    // 对于每天变化的方法，返回平均值
    switch (methodId) {
      case '365_days':
        return (1.0 + 365.0) / 2; // 平均每天183
      case '52_weeks':
        return (10.0 + 520.0) / 2 / 7; // 平均每天38
      case 'month_countdown':
        return (1.0 + 30.0) / 2; // 平均每天15.5
      case 'weekday_cycle':
        return (10.0 + 70.0) / 2; // 平均每天40
      default:
        return daily;
    }
  }

  /// 总周期数
  static int getTotalPeriods(String methodId) {
    switch (methodId) {
      case '52_weeks': return 52;
      case '333_rule': case '6_jars': case '12_cd':
      case '10_percent': case '1234_rule': case 'bet_save':
        return 12;
      default: return 365;
    }
  }

  /// 周期标签
  static String getPeriodLabel(String methodId, int periodIndex) {
    if (methodId == '52_weeks') return '第 ${periodIndex + 1} 周';
    if (methodId == '333_rule' || methodId == '6_jars' || methodId == '12_cd' ||
        methodId == '10_percent' || methodId == '1234_rule' || methodId == 'bet_save') {
      return '第 ${periodIndex + 1} 个月';
    }
    return '第 ${periodIndex + 1} 天';
  }

  /// 周期类型
  static String getPeriodType(String methodId) {
    if (methodId == '52_weeks') return '每周';
    if (methodId == '333_rule' || methodId == '6_jars' || methodId == '12_cd' ||
        methodId == '10_percent' || methodId == '1234_rule' || methodId == 'bet_save') {
      return '每月';
    }
    return '每天';
  }
}
