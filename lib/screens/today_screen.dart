import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/supplement.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';
import '../widgets/supplement_card.dart';
import '../widgets/today_records_list.dart';
import 'add_supplement_screen.dart';
import 'settings_screen.dart';

// Web 兼容的日期格式化
String formatDateSafe(DateTime date, String pattern) {
  try {
    return DateFormat(pattern, 'zh_CN').format(date);
  } catch (e) {
    return '${date.month}月${date.day}日';
  }
}

/// 今日页面 - 主要打卡界面
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // 页面淡入动画
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // FAB动画
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.elasticOut,
      ),
    );

    _fabRotateAnimation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplementProvider>().loadSupplements();
      _fadeController.forward();
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<SupplementProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const _LoadingView();
              }

              final supplements = provider.supplements;
              final today = DateTime.now();
              final dateStr = formatDateSafe(today, 'M月d日 EEEE');

              return CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // 顶部标题栏
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AnimatedSlide(
                                offset: const Offset(0, 0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                                child: Text(
                                  dateStr,
                                  style: AppTextStyles.callout,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _navigateToSettings(context),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.gray50,
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                  ),
                                  child: const Icon(
                                      CupertinoIcons.settings,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('今日补剂', style: AppTextStyles.largeTitle),
                              if (supplements.isNotEmpty)
                                _buildProgressIndicator(provider),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 连续打卡天数
                          FutureBuilder<int>(
                            future: provider.getConsecutiveDays(),
                            builder: (context, snapshot) {
                              final days = snapshot.data ?? 0;
                              if (days > 0) {
                                return AnimatedSlide(
                                  offset: Offset.zero,
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  child: _buildStreakBadge(days),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 补剂列表
                  if (supplements.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else ...[
                    // 待服用补剂
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final supplement = supplements[index];
                            return SupplementCard(
                              supplement: supplement,
                              takenCount: provider.getTodayTakenCount(supplement.id!),
                              onTake: () => _showTakeDialog(context, supplement),
                              index: index,
                            );
                          },
                          childCount: supplements.length,
                        ),
                      ),
                    ),

                    // 今日记录标题
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 36,
                          bottom: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '今日记录',
                              style: AppTextStyles.title3,
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(AppRadius.round),
                              ),
                              child: Text(
                                '${provider.getTodayAllLogs().length} 条',
                                style: AppTextStyles.footnote.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 今日记录
                    SliverToBoxAdapter(
                      child: TodayRecordsList(
                          onUndo: (log) async {
                            final supplement = supplements.firstWhere(
                              (s) => s.id == log.supplementId,
                              orElse: () => Supplement(
                                name: '',
                                dosage: '',
                                form: '',
                                frequency: '',
                                timing: [],
                                maxDaily: 1,
                              ),
                            );
                            if (supplement.id != null) {
                              await provider.undoIntake(supplement, log);
                            }
                          },
                        ),
                      ),
                  ],

                  // 底部间距
                  const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: Transform.rotate(
            angle: _fabRotateAnimation.value,
            child: child,
          ),
        );
      },
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToAddSupplement(context),
        icon: const Icon(CupertinoIcons.add),
        label: const Text('添加补剂'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  Widget _buildProgressIndicator(SupplementProvider provider) {
    final total = provider.supplements.length;
    var completed = 0;
    for (final s in provider.supplements) {
      if (provider.getTodayTakenCount(s.id!) > 0) completed++;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(color: AppColors.border),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          '$completed/$total',
          key: ValueKey(completed),
          style: AppTextStyles.footnote.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(int days) {
    final isHot = days >= 7;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isHot
            ? const Color(0xFFFF6B6B).withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(
          color: isHot
              ? const Color(0xFFFF6B6B).withOpacity(0.2)
              : AppColors.success.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: Icon(
              isHot ? CupertinoIcons.flame_fill : CupertinoIcons.flame,
              key: ValueKey(isHot),
              size: 18,
              color: isHot ? const Color(0xFFFF6B6B) : AppColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '连续打卡 $days 天',
            style: AppTextStyles.callout.copyWith(
              color: isHot ? const Color(0xFFFF6B6B) : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Icon(
                CupertinoIcons.capsule,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '还没有添加补剂',
              style: AppTextStyles.title3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮添加你的第一个补剂',
              style: AppTextStyles.callout,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToAddSupplement(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const AddSupplementScreen(),
      ),
    );
  }

  void _showTakeDialog(BuildContext context, supplement) {
    final provider = context.read<SupplementProvider>();
    final validation = provider.canTakeSupplement(supplement);

    if (!validation.canTake) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('无法服用'),
          content: Text(validation.message!),
          actions: [
            CupertinoDialogAction(
              child: const Text('确定'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => _BottomSheetAnimation(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖动条
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    '记录服用',
                    style: AppTextStyles.title2,
                  ),
                  const SizedBox(height: 24),
                  
                  // 补剂信息卡片
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                      children: [
                        Text(
                          supplement.name,
                          style: AppTextStyles.title3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${supplement.dosage} / ${supplement.form}',
                          style: AppTextStyles.subhead,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Text(
                            '取消',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: const Text(
                            '确认服用',
                            style: AppTextStyles.button,
                          ),
                          onPressed: () async {
                            await provider.recordIntake(supplement, 1);
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showSuccessToast(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessToast(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          scale: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.gray900.withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: AppColors.success,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  '已记录',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) Navigator.pop(context);
    });
  }
}

/// 加载视图
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(
                AppColors.textSecondary.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '加载中...',
            style: AppTextStyles.subhead,
          ),
        ],
      ),
    );
  }
}

/// 底部弹出动画组件
class _BottomSheetAnimation extends StatefulWidget {
  final Widget child;

  const _BottomSheetAnimation({required this.child});

  @override
  State<_BottomSheetAnimation> createState() => _BottomSheetAnimationState();
}

class _BottomSheetAnimationState extends State<_BottomSheetAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 缩放动画组件
class AnimatedScale extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double scale;

  const AnimatedScale({
    super.key,
    required this.child,
    required this.duration,
    required this.curve,
    required this.scale,
  });

  @override
  State<AnimatedScale> createState() => _AnimatedScaleState();
}

class _AnimatedScaleState extends State<AnimatedScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: widget.scale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
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
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
