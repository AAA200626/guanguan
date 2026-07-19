/// 存钱方法模型
class SavingMethod {
  final String id;
  final String name;
  final String description;
  final String difficulty; // easy / medium / hard
  final String ruleType; // daily / weekly / monthly
  final double estimatedAnnual; // 预计年存金额（基于默认参数）
  final String icon; // 图标标识
  final String suitableFor; // 适合人群描述

  const SavingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.ruleType,
    required this.estimatedAnnual,
    required this.icon,
    required this.suitableFor,
  });

  /// 获取难度星级
  int get difficultyStars {
    switch (difficulty) {
      case 'easy':
        return 1;
      case 'medium':
        return 2;
      case 'hard':
        return 3;
      default:
        return 1;
    }
  }

  /// 获取难度显示文本
  String get difficultyLabel {
    switch (difficulty) {
      case 'easy':
        return '轻松';
      case 'medium':
        return '适中';
      case 'hard':
        return '挑战';
      default:
        return difficulty;
    }
  }

  /// 默认的 6 种存钱方法
  static List<SavingMethod> get defaultMethods => [
        const SavingMethod(
          id: '365_days',
          name: '365天存钱法',
          description: '第1天存1元，第2天存2元，每天递增1元。越存越多，年底收获大惊喜！',
          difficulty: 'hard',
          ruleType: 'daily',
          estimatedAnnual: 66795,
          icon: 'calendar',
          suitableFor: '收入稳定的上班族',
        ),
        const SavingMethod(
          id: '52_weeks',
          name: '52周存钱法',
          description: '第1周存10元，每周递增10元。从轻松开始，逐步养成存钱习惯。',
          difficulty: 'medium',
          ruleType: 'weekly',
          estimatedAnnual: 13780,
          icon: 'trending_up',
          suitableFor: '学生党、职场新人',
        ),
        const SavingMethod(
          id: 'month_countdown',
          name: '月份倒数法',
          description: '每月按天数倒序存钱：1号存30元→30号存1元。越到后面越轻松！',
          difficulty: 'easy',
          ruleType: 'daily',
          estimatedAnnual: 5580,
          icon: 'arrow_downward',
          suitableFor: '学生党、零花钱存钱',
        ),
        const SavingMethod(
          id: '333_rule',
          name: '333存钱法',
          description: '每月收入分3份：1/3储蓄 + 1/3日常开支 + 1/3投资理财。先储蓄再消费！',
          difficulty: 'medium',
          ruleType: 'monthly',
          estimatedAnnual: 0, // 取决于收入
          icon: 'pie_chart',
          suitableFor: '所有人群，简单好记',
        ),
        const SavingMethod(
          id: '6_jars',
          name: '6罐存钱法',
          description: '将收入分6个虚拟罐子：生活55%、财务自由10%、教育10%、长期10%、娱乐10%、社交5%。',
          difficulty: 'hard',
          ruleType: 'monthly',
          estimatedAnnual: 0, // 取决于收入
          icon: 'grid_view',
          suitableFor: '想全面规划财务的上班族',
        ),
        const SavingMethod(
          id: '12_cd',
          name: '12存单法',
          description: '每月存一笔1年定期，坚持12个月。次年每月都有一笔到期，兼顾收益与灵活。',
          difficulty: 'medium',
          ruleType: 'monthly',
          estimatedAnnual: 0,
          icon: 'account_balance',
          suitableFor: '有稳定收入、想强制储蓄的人',
        ),
        const SavingMethod(
          id: '10_percent',
          name: '10%强制储蓄法',
          description: '每月发薪后立刻转出10%到储蓄账户，剩下的才是可花的。先存后花！',
          difficulty: 'easy',
          ruleType: 'monthly',
          estimatedAnnual: 0,
          icon: 'lock',
          suitableFor: '所有人，最简单有效的存钱法',
        ),
        const SavingMethod(
          id: 'round_up',
          name: '整数取整法',
          description: '每次消费向上取整，差额自动存起来。花69存1元，花480存20元。无痛攒钱！',
          difficulty: 'easy',
          ruleType: 'daily',
          estimatedAnnual: 3650,
          icon: 'autorenew',
          suitableFor: '经常小额消费的人，不知不觉攒一笔',
        ),
        const SavingMethod(
          id: 'dream_jar',
          name: '梦想储蓄罐',
          description: '为一个具体梦想存钱（旅行/手机/礼物），设定目标和截止日，每天为梦想存一点。',
          difficulty: 'easy',
          ruleType: 'daily',
          estimatedAnnual: 0,
          icon: 'favorite',
          suitableFor: '有明确愿望和目标的人',
        ),
        const SavingMethod(
          id: 'pretend_save',
          name: '假装存钱法',
          description: '设定虚拟剧情（养娃/养宠/穿越），按剧情"花费"实为存钱。沉浸式攒钱游戏！',
          difficulty: 'medium',
          ruleType: 'daily',
          estimatedAnnual: 7300,
          icon: 'theater_comedy',
          suitableFor: '喜欢趣味、难以坚持传统存钱的人',
        ),
        const SavingMethod(
          id: 'bet_save',
          name: '对赌存钱法',
          description: '和朋友约定每月存钱目标，没完成就请客。外部压力是最强的动力！',
          difficulty: 'hard',
          ruleType: 'monthly',
          estimatedAnnual: 0,
          icon: 'handshake',
          suitableFor: '需要外部监督和动力的人',
        ),
        const SavingMethod(
          id: 'weekday_cycle',
          name: '星期存钱法',
          description: '周一存10、周二20...周日70。每周循环，轻松无压力！',
          difficulty: 'easy',
          ruleType: 'daily',
          estimatedAnnual: 14560,
          icon: 'loop',
          suitableFor: '喜欢规律节奏、每周循环的人',
        ),
        const SavingMethod(
          id: '1234_rule',
          name: '1234存钱法',
          description: '收入分四份：10%消费+20%保障+30%投资+40%长期储蓄。存下70%！',
          difficulty: 'hard',
          ruleType: 'monthly',
          estimatedAnnual: 0,
          icon: 'account_tree',
          suitableFor: '想系统规划财务、高储蓄率的人',
        ),
      ];
}

/// 打卡记录模型
class SavingRecord {
  final int? id;
  final int planId;
  final DateTime date;
  final double amount;
  final bool isCompleted;

  const SavingRecord({
    this.id,
    required this.planId,
    required this.date,
    required this.amount,
    this.isCompleted = false,
  });

  SavingRecord copyWith({
    int? id,
    int? planId,
    DateTime? date,
    double? amount,
    bool? isCompleted,
  }) {
    return SavingRecord(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// 用户存钱计划模型
class UserPlan {
  final int? id;
  final String methodId;
  final String methodName;
  final DateTime startDate;
  final double targetAmount;
  final double savedAmount;
  final String status; // active / completed / paused

  const UserPlan({
    this.id,
    required this.methodId,
    required this.methodName,
    required this.startDate,
    required this.targetAmount,
    this.savedAmount = 0,
    this.status = 'active',
  });

  double get progressPercent =>
      targetAmount > 0 ? savedAmount / targetAmount : 0;

  UserPlan copyWith({
    int? id,
    String? methodId,
    String? methodName,
    DateTime? startDate,
    double? targetAmount,
    double? savedAmount,
    String? status,
  }) {
    return UserPlan(
      id: id ?? this.id,
      methodId: methodId ?? this.methodId,
      methodName: methodName ?? this.methodName,
      startDate: startDate ?? this.startDate,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      status: status ?? this.status,
    );
  }
}

/// 智能推荐结果
class SavingRecommendation {
  final SavingMethod method;
  final double expectedAnnual; // 预计年存
  final String reason; // 推荐理由

  const SavingRecommendation({
    required this.method,
    required this.expectedAnnual,
    required this.reason,
  });
}
