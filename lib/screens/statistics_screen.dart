import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/supplement.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

/// 统计页面 - 服用率分析
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> 
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppleCurves.decelerate,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<SupplementProvider>(
          builder: (context, provider, child) {
            final supplements = provider.supplements;
            
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 顶部标题
                SliverToBoxAdapter(
                  child: FadeIn(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('统计', style: AppTextStyles.largeTitle),
                          const SizedBox(height: 4),
                          Text(
                            '过去30天服用情况',
                            style: AppTextStyles.callout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 概览卡片
                SliverToBoxAdapter(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              '总补剂',
                              supplements.length.toString(),
                              CupertinoIcons.capsule_fill,
                              AppColors.primary,
                              0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FutureBuilder<int>(
                              future: provider.getConsecutiveDays(),
                              builder: (context, snapshot) {
                                final days = snapshot.data ?? 0;
                                return _buildStatCard(
                                  '连续打卡',
                                  '$days 天',
                                  CupertinoIcons.flame_fill,
                                  days >= 7 ? const Color(0xFFFF6B6B) : AppColors.success,
                                  1,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 图表区域
                if (supplements.isNotEmpty)
                  SliverToBoxAdapter(
                    child: FadeIn(
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '各补剂服用率',
                              style: AppTextStyles.headline,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: _buildPieChart(supplements),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 趋势图
                SliverToBoxAdapter(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '本周趋势',
                            style: AppTextStyles.headline,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            child: _buildBarChart(context, supplements),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 补剂列表标题
                SliverToBoxAdapter(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 400),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '各补剂详情',
                        style: AppTextStyles.title3,
                      ),
                    ),
                  ),
                ),

                // 补剂列表
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final supplement = supplements[index];
                        return FadeIn(
                          delay: Duration(milliseconds: 500 + index * 50),
                          child: _buildSupplementStatItem(supplement, index),
                        );
                      },
                      childCount: supplements.length,
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    int index,
  ) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final delay = index * 0.1;
        final progress = (_animation.value - delay).clamp(0, 1 - delay) / (1 - delay);
        
        return Transform.translate(
          offset: Offset(0, (1 - progress) * 20),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.statistic,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.subhead,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(List supplements) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedIndex = -1;
                    return;
                  }
                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            sectionsSpace: 2,
            centerSpaceRadius: 45,
            sections: _buildPieSections(supplements),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections(List supplements) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      const Color(0xFFFF6B6B),
      const Color(0xFF5856D6),
      const Color(0xFFAF52DE),
      const Color(0xFF30B0C7),
    ];

    return List.generate(supplements.length > 6 ? 6 : supplements.length, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 70.0 : 60.0;
      
      return PieChartSectionData(
        color: colors[i % colors.length],
        value: 100 / supplements.length,
        title: '',
        radius: radius,
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: colors[i % colors.length].withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  supplements[i].name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildBarChart(BuildContext context, List supplements) {
    // 获取本周数据（周一到周日）
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // 本周一
    
    final provider = context.read<SupplementProvider>();
    
    // 计算每天的服用次数
    final values = List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final logs = provider.getLogsForDate(day);
      return logs.where((log) => log.status == IntakeStatus.taken).length;
    });
    
    final hasData = values.any((v) => v > 0);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue < 5 ? 5.0 : (maxValue * 1.2);

    if (!hasData) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chart_bar,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            Text(
              '暂无数据',
              style: AppTextStyles.subhead.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '开始服用补剂后将显示趋势',
              style: AppTextStyles.footnote.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weekDays.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    weekDays[index],
                    style: AppTextStyles.footnote,
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          weekDays.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                color: AppColors.primary,
                width: 24,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sm),
                ),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.gray800,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplementStatItem(supplement, int index) {
    return FutureBuilder<double>(
      future: context.read<SupplementProvider>().getSupplementAdherence(supplement.id!),
      builder: (context, snapshot) {
        final adherence = snapshot.data ?? 0.0;
        final color = adherence >= 0.8
            ? AppColors.success
            : adherence >= 0.5
                ? AppColors.warning
                : AppColors.danger;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  CupertinoIcons.capsule,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name,
                      style: AppTextStyles.headline,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      child: AnimatedContainer(
                        duration: AnimationDurations.slow,
                        curve: AppleCurves.spring,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: adherence,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 56,
                alignment: Alignment.centerRight,
                child: AnimatedSwitcher(
                  duration: AnimationDurations.fast,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    '${(adherence * 100).toInt()}%',
                    key: ValueKey(adherence),
                    style: AppTextStyles.title3.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
