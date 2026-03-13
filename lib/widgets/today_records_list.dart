import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/supplement.dart';
import '../providers/supplement_provider.dart';
import '../utils/constants.dart';

/// 今日记录列表组件 - 带动画效果
class TodayRecordsList extends StatelessWidget {
  final Function(IntakeLog)? onUndo;

  const TodayRecordsList({
    super.key,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SupplementProvider>(
      builder: (context, provider, child) {
        final logs = provider.getTodayAllLogs();
        
        if (logs.isEmpty) {
          return _buildEmptyState();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < logs.length; i++) ...[
                  _AnimatedRecordItemWrapper(
                    log: logs[i],
                    isLast: i == logs.length - 1,
                    onUndo: onUndo,
                    index: i,
                  ),
                  if (i < logs.length - 1)
                    const Divider(
                      height: 1,
                      indent: 76,
                      color: AppColors.border,
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  CupertinoIcons.clock,
                  size: 28,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '今日暂无记录',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '服用后记录将显示在这里',
                style: AppTextStyles.footnote.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 带动画的记录项包装器
class _AnimatedRecordItemWrapper extends StatefulWidget {
  final IntakeLog log;
  final bool isLast;
  final Function(IntakeLog)? onUndo;
  final int index;

  const _AnimatedRecordItemWrapper({
    required this.log,
    required this.isLast,
    this.onUndo,
    required this.index,
  });

  @override
  State<_AnimatedRecordItemWrapper> createState() => _AnimatedRecordItemWrapperState();
}

class _AnimatedRecordItemWrapperState extends State<_AnimatedRecordItemWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final delay = widget.index * 0.05;
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, delay + 0.5, curve: Curves.easeOutCubic),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _RecordItem(
          log: widget.log,
          isLast: widget.isLast,
          onUndo: widget.onUndo,
        ),
      ),
    );
  }
}

/// 记录项 - 带动画效果
class _RecordItem extends StatefulWidget {
  final IntakeLog log;
  final bool isLast;
  final Function(IntakeLog)? onUndo;

  const _RecordItem({
    required this.log,
    required this.isLast,
    this.onUndo,
  });

  @override
  State<_RecordItem> createState() => _RecordItemState();
}

class _RecordItemState extends State<_RecordItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _statusController;
  late Animation<double> _statusScaleAnimation;

  @override
  void initState() {
    super.initState();
    _statusController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _statusScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _statusController,
        curve: Curves.elasticOut,
      ),
    );

    _statusController.forward();
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supplement = context.read<SupplementProvider>().supplements.firstWhere(
      (s) => s.id == widget.log.supplementId,
      orElse: () => Supplement(
        name: '未知补剂',
        dosage: '',
        form: '',
        frequency: '',
        timing: [],
        maxDaily: 1,
      ),
    );

    final timeStr = DateFormat('HH:mm').format(widget.log.time);
    final isTaken = widget.log.status == IntakeStatus.taken;

    return Dismissible(
      key: Key('record_${widget.log.id}_${widget.log.time.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.25,
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: widget.isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(AppRadius.lg))
              : null,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.arrow_counterclockwise,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              '撤销',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => widget.onUndo?.call(widget.log),
      child: Container(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 状态图标 - 带动画
              ScaleTransition(
                scale: _statusScaleAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isTaken ? AppColors.success : AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      isTaken ? CupertinoIcons.checkmark_alt : CupertinoIcons.xmark,
                      key: ValueKey(isTaken),
                      color: isTaken ? Colors.white : AppColors.gray400,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.log.quantity} ${supplement.form}',
                      style: AppTextStyles.footnote,
                    ),
                  ],
                ),
              ),

              // 时间和状态
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: AppTextStyles.callout.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isTaken
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isTaken ? '已服用' : '漏服',
                        key: ValueKey(isTaken),
                        style: AppTextStyles.caption.copyWith(
                          color: isTaken ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
