import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/supplement.dart';
import '../providers/supplement_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/animations.dart';

/// 提醒管理页面
class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> 
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _reminders = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
    );
    _loadReminders();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    
    final supplements = context.read<SupplementProvider>().supplements;
    final List<Map<String, dynamic>> reminders = [];

    for (final supplement in supplements) {
      for (final timing in supplement.timing) {
        reminders.add({
          'supplement': supplement,
          'timing': timing,
          'isEnabled': true,
        });
      }
    }

    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CupertinoNavigationBar(
        middle: const Text('提醒管理'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('测试通知'),
          onPressed: () => _testNotification(context),
        ),
        border: null,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : _reminders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _reminders.length,
                    itemBuilder: (context, index) {
                      final item = _reminders[index];
                      return FadeIn(
                        delay: Duration(milliseconds: 100 + index * 50),
                        child: _buildReminderCard(
                          supplement: item['supplement'] as Supplement,
                          timing: item['timing'] as String,
                          isEnabled: item['isEnabled'] as bool,
                          onToggle: (value) {
                            setState(() {
                              item['isEnabled'] = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeIn(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Icon(
                CupertinoIcons.bell,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有提醒',
              style: AppTextStyles.title3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '添加补剂时会自动创建提醒',
              style: AppTextStyles.callout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required Supplement supplement,
    required String timing,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    final timeStr = _parseTimeDisplay(timing);

    return AnimatedContainer(
      duration: AnimationDurations.fast,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isEnabled 
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.border,
          width: isEnabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: AnimationDurations.fast,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.gray800],
                    )
                  : null,
              color: isEnabled ? null : AppColors.gray100,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: AnimatedSwitcher(
              duration: AnimationDurations.fast,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isEnabled ? CupertinoIcons.bell_fill : CupertinoIcons.bell_slash,
                key: ValueKey(isEnabled),
                color: isEnabled ? Colors.white : AppColors.textTertiary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplement.name,
                  style: AppTextStyles.headline.copyWith(
                    color: isEnabled ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? AppColors.primary.withOpacity(0.08)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        timing,
                        style: AppTextStyles.caption.copyWith(
                          color: isEnabled ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        timeStr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _parseTimeDisplay(String timing) {
    final timeMap = {
      '早上': '08:00',
      '早餐后': '08:30',
      '午餐前': '11:30',
      '午餐后': '12:30',
      '晚餐前': '17:30',
      '晚餐后': '18:30',
      '睡前': '21:30',
    };

    for (final entry in timeMap.entries) {
      if (timing.contains(entry.key)) {
        return entry.value;
      }
    }

    return '08:00';
  }

  Future<void> _testNotification(BuildContext context) async {
    await NotificationService.instance.showNotification(
      id: 9999,
      title: '测试通知',
      body: '这是 SuppCheck 的测试通知',
    );

    if (context.mounted) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => BottomSheetAnimation(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppColors.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '测试通知已发送',
                    style: AppTextStyles.title3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '请检查系统通知栏',
                    style: AppTextStyles.callout,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Text(
                        '确定',
                        style: AppTextStyles.button,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
