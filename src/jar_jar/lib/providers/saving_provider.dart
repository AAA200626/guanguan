import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saving_method.dart';
import '../utils/saving_calculator.dart';
import '../utils/saving_recommender.dart';
import '../utils/database_helper.dart';

/// 底部导航 tab 索引（0=首页, 1=挑战, 2=我的）
final bottomTabIndexProvider = StateProvider<int>((ref) => 0);

/// 用户昵称
final userNameProvider = StateProvider<String>((ref) => '存钱达人');

/// 自定义单日金额 Map<"YYYY-MM-DD", amount>
final customDayAmountsProvider =
    StateProvider<Map<String, double>>((ref) => {});

/// 选中的存钱方法
final selectedMethodProvider = StateProvider<SavingMethod?>((ref) => null);

/// 月收入（用于智能推荐）
final monthlyIncomeProvider = StateProvider<double>((ref) => 5000);

/// 每月存钱目标（¥）
final monthlyTargetProvider = StateProvider<double>((ref) => 3000);

/// 存钱偏好：easy / medium / hard
final savingPreferenceProvider = StateProvider<String>((ref) => 'medium');

/// 当前活跃的存钱计划（从DB加载）
final activePlanProvider = StateProvider<UserPlan?>((ref) => null);

/// DB加载完成的标记
final dbLoadedProvider = StateProvider<bool>((ref) => false);

/// 从数据库加载所有数据
final loadFromDatabase = FutureProvider<void>((ref) async {
  final plan = await DatabaseHelper.instance.getActivePlan();
  if (plan != null) {
    ref.read(activePlanProvider.notifier).state = plan;
    final records = await DatabaseHelper.instance.getRecordsByPlan(plan.id!);
    ref.read(checkInRecordsProvider.notifier).state = records;
  }
  ref.read(dbLoadedProvider.notifier).state = true;
});

/// 智能推荐结果
final recommendationsProvider = Provider<List<SavingRecommendation>>((ref) {
  final income = ref.watch(monthlyIncomeProvider);
  final preference = ref.watch(savingPreferenceProvider);
  return SavingRecommender.recommend(income, preference: preference);
});

/// 所有存钱方法列表
final savingMethodsProvider =
    Provider<List<SavingMethod>>((ref) => SavingMethod.defaultMethods);

/// 打卡记录列表（当前计划的打卡记录）
final checkInRecordsProvider = StateProvider<List<SavingRecord>>((ref) => []);

/// 今日应存金额
final todayAmountProvider = Provider<double>((ref) {
  final income = ref.watch(monthlyIncomeProvider);
  return SavingCalculator.dailyAmount('daily', monthlyIncome: income);
});

/// 创建计划并保存到数据库
Future<UserPlan> createPlan(UserPlan plan) async {
  final id = await DatabaseHelper.instance.insertPlan(plan);
  return plan.copyWith(id: id);
}

/// 保存打卡记录到数据库
Future<void> saveRecord(SavingRecord record) async {
  await DatabaseHelper.instance.insertRecord(record);
}

/// 更新计划到数据库
Future<void> updatePlanDb(UserPlan plan) async {
  await DatabaseHelper.instance.updatePlan(plan);
}
