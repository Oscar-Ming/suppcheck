import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

// Web 兼容的日期格式化
String formatDateSafe(DateTime date, String pattern) {
  try {
    return DateFormat(pattern, 'zh_CN').format(date);
  } catch (e) {
    return '${date.month}月${date.day}日';
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 日历页面 - 查看历史记录
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> 
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _controller = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
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
                          const Text('日历', style: AppTextStyles.largeTitle),
                          const SizedBox(height: 4),
                          Text(
                            '查看历史服用记录',
                            style: AppTextStyles.callout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 日历
                SliverToBoxAdapter(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2026, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return _selectedDay != null && isSameDay(_selectedDay!, day);
                          },
                          calendarFormat: _calendarFormat,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            provider.selectDate(selectedDay);
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: AppTextStyles.headline,
                            leftChevronIcon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                CupertinoIcons.chevron_left,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            rightChevronIcon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: const Icon(
                                CupertinoIcons.chevron_right,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            headerPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            cellPadding: const EdgeInsets.all(8),
                            defaultTextStyle: AppTextStyles.body,
                            weekendTextStyle: AppTextStyles.body,
                            selectedTextStyle: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            todayTextStyle: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 3,
                            markerSize: 5,
                            markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                            markerDecoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: AppTextStyles.footnote.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            weekendStyle: AppTextStyles.footnote.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            dowTextFormatter: (date, locale) {
                              return ['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1];
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 选中日期记录标题
                SliverToBoxAdapter(
                  child: FadeIn(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDateSafe(_selectedDay!, 'M月d日') + ' 记录',
                            style: AppTextStyles.title3,
                          ),
                          // 只有选中的日期是今天时才显示"今天"标签
                          if (_selectedDay != null && isSameDay(_selectedDay!, DateTime.now()))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
                              child: Text(
                                '今天',
                                style: AppTextStyles.footnote.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 当日记录列表
                _buildDayRecords(provider),

                const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayRecords(SupplementProvider provider) {
    final supplements = provider.supplements;
    final selectedDate = _selectedDay ?? DateTime.now();
    final isSelectedToday = isSameDay(selectedDate, DateTime.now());
    
    // 获取选中日期所有补剂的记录
    final Map<int, int> takenCounts = {};
    for (final supplement in supplements) {
      if (isSelectedToday) {
        takenCounts[supplement.id!] = provider.getTodayTakenCount(supplement.id!);
      } else {
        takenCounts[supplement.id!] = 0;
      }
    }

    // 获取选中日期的实际记录
    final logs = provider.getLogsForDate(selectedDate);
    final Set<int> supplementsWithLogs = logs.map((l) => l.supplementId).toSet();
    
    // 如果没有补剂
    if (supplements.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: FadeIn(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text,
                    size: 36,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '还没有添加补剂',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 显示选中日期有记录的补剂
    final displaySupplements = supplements.where(
      (s) => isSelectedToday || supplementsWithLogs.contains(s.id)
    ).toList();

    if (displaySupplements.isEmpty && !isSelectedToday) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: FadeIn(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Icon(
                    CupertinoIcons.doc_text,
                    size: 36,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '当日无记录',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 对于今天显示所有补剂，对于历史日期只显示有记录的
    final itemsToShow = isSelectedToday ? supplements : displaySupplements;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final supplement = itemsToShow[index];
            final takenCount = takenCounts[supplement.id!] ?? 0;
            final isTaken = takenCount > 0 || supplementsWithLogs.contains(supplement.id);

            return FadeIn(
              delay: Duration(milliseconds: 300 + index * 50),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: isTaken 
                        ? AppColors.success.withOpacity(0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: isTaken
                            ? const LinearGradient(
                                colors: [AppColors.success, Color(0xFF16A34A)],
                              )
                            : null,
                        color: isTaken ? null : AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        isTaken 
                            ? CupertinoIcons.checkmark_alt
                            : CupertinoIcons.capsule,
                        color: isTaken ? Colors.white : AppColors.textTertiary,
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
                          const SizedBox(height: 2),
                          Text(
                            supplement.dosage,
                            style: AppTextStyles.subhead,
                          ),
                          if (isSelectedToday) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                              child: AnimatedContainer(
                                duration: AnimationDurations.normal,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.gray100,
                                  borderRadius: BorderRadius.circular(AppRadius.xs),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (takenCount / supplement.maxDaily).clamp(0, 1),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: takenCount >= supplement.maxDaily 
                                          ? AppColors.success 
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(AppRadius.xs),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isTaken 
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: Text(
                        isTaken 
                            ? (isSelectedToday ? '已服 $takenCount/${supplement.maxDaily}' : '已服用')
                            : '未服用',
                        style: AppTextStyles.footnote.copyWith(
                          color: isTaken ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: itemsToShow.length,
        ),
      ),
    );
  }
}
