import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/supplement.dart';
import '../utils/constants.dart';

/// 补剂分类显示扩展
extension CategoryDisplay on SupplementCategory {
  String get displayName {
    switch (this) {
      case SupplementCategory.vitamin:
        return '维生素';
      case SupplementCategory.mineral:
        return '矿物质';
      case SupplementCategory.protein:
        return '蛋白质';
      case SupplementCategory.aminoAcid:
        return '氨基酸';
      case SupplementCategory.herb:
        return '草本';
      case SupplementCategory.probiotic:
        return '益生菌';
      case SupplementCategory.omega:
        return '鱼油';
      case SupplementCategory.joint:
        return '关节';
      case SupplementCategory.preworkout:
        return '运动';
      case SupplementCategory.other:
        return '其他';
    }
  }

  Color get displayColor {
    switch (this) {
      case SupplementCategory.vitamin:
        return const Color(0xFFE85D04);
      case SupplementCategory.mineral:
        return const Color(0xFF0077B6);
      case SupplementCategory.protein:
        return const Color(0xFF2D6A4F);
      case SupplementCategory.aminoAcid:
        return const Color(0xFF5A189A);
      case SupplementCategory.herb:
        return const Color(0xFF52796F);
      case SupplementCategory.probiotic:
        return const Color(0xFFC9184A);
      case SupplementCategory.omega:
        return const Color(0xFFFF006E);
      case SupplementCategory.joint:
        return const Color(0xFFFB8500);
      case SupplementCategory.preworkout:
        return const Color(0xFF7209B7);
      case SupplementCategory.other:
        return const Color(0xFF6B7280);
    }
  }
}

/// 补剂卡片组件 - 带动画效果
class SupplementCard extends StatefulWidget {
  final Supplement supplement;
  final int takenCount;
  final VoidCallback onTake;
  final int index;

  const SupplementCard({
    super.key,
    required this.supplement,
    required this.takenCount,
    required this.onTake,
    this.index = 0,
  });

  @override
  State<SupplementCard> createState() => _SupplementCardState();
}

class _SupplementCardState extends State<SupplementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // 错开延迟，但确保在duration内完成
    final delay = (widget.index * 0.06).clamp(0.0, 0.3);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),  // 相对位移，更平滑
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.97, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
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
    final isCompleted = widget.takenCount >= widget.supplement.maxDaily;
    final canTake = widget.takenCount < widget.supplement.maxDaily;
    final progress = widget.takenCount / widget.supplement.maxDaily;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.98 : 1.0),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isCompleted 
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.border,
              width: isCompleted ? 1.5 : 1,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: AppColors.gray200.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              children: [
                // 主内容区
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 状态图标 - 带动画
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success
                              : widget.supplement.category.displayColor,
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
                            isCompleted
                                ? CupertinoIcons.checkmark_alt
                                : CupertinoIcons.capsule,
                            key: ValueKey(isCompleted),
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.supplement.name,
                                          style: AppTextStyles.headline,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget.supplement.category.displayColor
                                              .withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(AppRadius.sm),
                                        ),
                                        child: Text(
                                          widget.supplement.category.displayName,
                                          style: AppTextStyles.caption.copyWith(
                                            color: widget.supplement.category.displayColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCompleted)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppRadius.round),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          CupertinoIcons.checkmark,
                                          size: 12,
                                          color: AppColors.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '已完成',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.supplement.dosage.isEmpty
                                  ? widget.supplement.form
                                  : '${widget.supplement.dosage} · ${widget.supplement.form}',
                              style: AppTextStyles.subhead,
                            ),
                            const SizedBox(height: 12),

                            // 进度条 - 带动画
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.xs),
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.gray100,
                                        borderRadius: BorderRadius.circular(AppRadius.xs),
                                      ),
                                      child: TweenAnimationBuilder<double>(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeOutCubic,
                                        tween: Tween<double>(begin: 0, end: progress.clamp(0, 1)),
                                        builder: (context, value, child) {
                                          return FractionallySizedBox(
                                            alignment: Alignment.centerLeft,
                                            widthFactor: value,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: isCompleted
                                                    ? AppColors.success
                                                    : AppColors.primary,
                                                borderRadius: BorderRadius.circular(AppRadius.xs),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    '${widget.takenCount}/${widget.supplement.maxDaily}',
                                    key: ValueKey(widget.takenCount),
                                    style: AppTextStyles.footnote.copyWith(
                                      color: isCompleted
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 按钮区
                if (canTake)
                  GestureDetector(
                    onTap: widget.onTake,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        color: _isPressed
                            ? AppColors.gray50
                            : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_circle,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '打卡服用',
                              style: AppTextStyles.callout.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

/// 补剂列表项 - 带动画
class SupplementListItem extends StatefulWidget {
  final Supplement supplement;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const SupplementListItem({
    super.key,
    required this.supplement,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  State<SupplementListItem> createState() => _SupplementListItemState();
}

class _SupplementListItemState extends State<SupplementListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    // 错开延迟，但确保在duration内完成
    final delay = (widget.index * 0.06).clamp(0.0, 0.3);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),  // 从下往上，与SupplementCard一致
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(delay, (delay + 0.6).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: Key('supplement_${widget.supplement.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.centerRight,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.trash,
                color: Colors.white,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                '删除',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          return await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('确认删除'),
              content: Text('确定要删除 "${widget.supplement.name}" 吗？'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('删除'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) => widget.onDelete?.call(),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            transform: Matrix4.identity()
              ..scale(_isPressed ? 0.98 : 1.0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: _isPressed
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                // 分类图标
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.supplement.category.displayColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    CupertinoIcons.capsule,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                
                // 信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.supplement.name,
                        style: AppTextStyles.headline,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.supplement.dosage.isEmpty
                            ? widget.supplement.form
                            : '${widget.supplement.dosage} · ${widget.supplement.form}',
                        style: AppTextStyles.subhead,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.supplement.category.displayColor
                                  .withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              widget.supplement.category.displayName,
                              style: AppTextStyles.caption.copyWith(
                                color: widget.supplement.category.displayColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (widget.supplement.timing.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray50,
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                widget.supplement.timing.first,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 箭头
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
