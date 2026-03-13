import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 苹果风格的缓动曲线
class AppleCurves {
  /// 标准缓动 - 用于大多数动画
  static const Cubic standard = Cubic(0.4, 0.0, 0.2, 1.0);
  
  /// 减速缓动 - 用于元素进入屏幕
  static const Cubic decelerate = Cubic(0.0, 0.0, 0.2, 1.0);
  
  /// 加速缓动 - 用于元素离开屏幕
  static const Cubic accelerate = Cubic(0.4, 0.0, 1.0, 1.0);
  
  /// 弹性缓动 - 用于强调动画
  static const Cubic spring = Cubic(0.34, 1.56, 0.64, 1.0);
  
  /// 丝滑弹簧效果
  static const Cubic smoothSpring = Cubic(0.175, 0.885, 0.32, 1.275);
  
  /// 快速减速
  static const Cubic fastOutSlowIn = Cubic(0.4, 0.0, 0.2, 1.0);
  
  /// iOS风格弹簧
  static const Cubic iosSpring = Cubic(0.5, 1.2, 0.3, 1.0);
}

/// 动画持续时间常量
class AnimationDurations {
  /// 快速 - 用于微交互（150ms）
  static const Duration fast = Duration(milliseconds: 150);
  
  /// 标准 - 用于大多数过渡（300ms）
  static const Duration normal = Duration(milliseconds: 300);
  
  /// 慢速 - 用于强调动画（450ms）
  static const Duration slow = Duration(milliseconds: 450);
  
  /// 弹性 - 用于弹簧效果（600ms）
  static const Duration spring = Duration(milliseconds: 600);
  
  /// 页面转场（400ms）
  static const Duration pageTransition = Duration(milliseconds: 400);
  
  /// 列表项错开延迟基础值
  static const Duration staggerBase = Duration(milliseconds: 50);
}

/// 页面转场动画 - 苹果风格
class ApplePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool fromBottom;
  
  ApplePageRoute({
    required this.child,
    this.fromBottom = false,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: AnimationDurations.pageTransition,
    reverseTransitionDuration: AnimationDurations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (fromBottom) {
        // 从底部滑入（用于模态页面）
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppleCurves.decelerate,
          reverseCurve: AppleCurves.accelerate,
        );
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.5,
              end: 1.0,
            ).animate(curve),
            child: child,
          ),
        );
      } else {
        // 从右侧滑入（用于导航页面）
        final curve = CurvedAnimation(
          parent: animation,
          curve: AppleCurves.standard,
          reverseCurve: AppleCurves.accelerate,
        );
        
        final secondaryCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: AppleCurves.standard,
        );
        
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(curve),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curve),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-0.3, 0),
              ).animate(secondaryCurve),
              child: child,
            ),
          ),
        );
      }
    },
  );
}

/// 缩放转场 - 用于卡片展开等
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Offset? origin;
  
  ScalePageRoute({
    required this.child,
    this.origin,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => child,
    transitionDuration: AnimationDurations.slow,
    reverseTransitionDuration: AnimationDurations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: AppleCurves.spring,
        reverseCurve: AppleCurves.accelerate,
      );
      
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(curve),
        alignment: origin != null 
          ? Alignment(
              (origin!.dx / MediaQuery.of(context).size.width) * 2 - 1,
              (origin!.dy / MediaQuery.of(context).size.height) * 2 - 1,
            )
          : Alignment.center,
        child: FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

/// 列表项入场动画 Widget
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  
  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = AnimationDurations.staggerBase,
  });
  
  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.slow,
      vsync: this,
    );
    
    final curve = CurvedAnimation(
      parent: _controller,
      curve: AppleCurves.decelerate,
    );
    
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(curve);
    _scale = Tween<double>(begin: 0.95, end: 1).animate(curve);
    
    // 错开延迟
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _controller.forward();
    });
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
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value * MediaQuery.of(context).size.height * 0.1,
            child: Transform.scale(
              scale: _scale.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// 带按压反馈的按钮
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scale;
  final Duration duration;
  
  const PressableButton({
    super.key,
    required this.child,
    this.onPressed,
    this.scale = 0.95,
    this.duration = AnimationDurations.fast,
  });
  
  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppleCurves.spring,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }
  
  void _onTapCancel() {
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 带悬浮效果的卡片
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final double hoverElevation;
  
  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.02,
    this.hoverElevation = 8.0,
  });
  
  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _elevation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.fast,
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: widget.hoverScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppleCurves.spring,
      ),
    );
    _elevation = Tween<double>(begin: 0, end: widget.hoverElevation).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppleCurves.standard,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onTapDown(TapDownDetails details) {
    setState(() => _isHovered = true);
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }
  
  void _onTapCancel() {
    setState(() => _isHovered = false);
    _controller.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08 * _elevation.value / widget.hoverElevation),
                    blurRadius: _elevation.value * 2,
                    offset: Offset(0, _elevation.value * 0.5),
                    spreadRadius: _elevation.value * 0.1,
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// 淡入动画 Widget
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset slideOffset;
  
  const FadeIn({
    super.key,
    required this.child,
    this.duration = AnimationDurations.normal,
    this.delay = Duration.zero,
    this.slideOffset = const Offset(0, 0.05),
  });
  
  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    final curve = CurvedAnimation(
      parent: _controller,
      curve: AppleCurves.decelerate,
    );
    
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(curve);
    
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
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
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: _slide.value * MediaQuery.of(context).size.height,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 计数器动画
class AnimatedCounter extends StatefulWidget {
  final int value;
  final TextStyle style;
  final Duration duration;
  
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = AnimationDurations.normal,
  });
  
  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousValue = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _previousValue = widget.value;
  }
  
  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = IntTween(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppleCurves.standard,
      ));
      _controller.forward(from: 0);
    }
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
        return Text(
          '${_animation.value}',
          style: widget.style,
        );
      },
    );
  }
}

/// 圆形进度动画
class AnimatedCircularProgress extends StatefulWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;
  final Duration duration;
  
  const AnimatedCircularProgress({
    super.key,
    required this.value,
    this.size = 40,
    this.strokeWidth = 3,
    required this.backgroundColor,
    required this.valueColor,
    this.duration = AnimationDurations.slow,
  });
  
  @override
  State<AnimatedCircularProgress> createState() => _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animateTo(widget.value);
  }
  
  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animateTo(widget.value);
    }
  }
  
  void _animateTo(double value) {
    _animation = Tween<double>(
      begin: _previousValue,
      end: value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppleCurves.spring,
    ));
    _controller.forward(from: 0);
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: _animation.value,
            strokeWidth: widget.strokeWidth,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation(widget.valueColor),
          ),
        );
      },
    );
  }
}

/// 滑动删除动画包装器
class AnimatedDismissible extends StatelessWidget {
  final String keyValue;
  final Widget child;
  final DismissDirectionCallback? onDismissed;
  final Widget? background;
  final Duration duration;
  
  const AnimatedDismissible({
    super.key,
    required this.keyValue,
    required this.child,
    this.onDismissed,
    this.background,
    this.duration = AnimationDurations.normal,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(keyValue),
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      background: background,
      movementDuration: duration,
      resizeDuration: duration,
      child: child,
    );
  }
}

/// 底部弹出面板动画
class BottomSheetAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const BottomSheetAnimation({
    super.key,
    required this.child,
    this.duration = AnimationDurations.pageTransition,
  });
  
  @override
  State<BottomSheetAnimation> createState() => _BottomSheetAnimationState();
}

class _BottomSheetAnimationState extends State<BottomSheetAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slide;
  late Animation<double> _opacity;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    final curve = CurvedAnimation(
      parent: _controller,
      curve: AppleCurves.decelerate,
    );
    
    _slide = Tween<double>(begin: 1, end: 0).animate(curve);
    _opacity = Tween<double>(begin: 0, end: 1).animate(curve);
    
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
        return Transform.translate(
          offset: Offset(0, _slide.value * 100),
          child: Opacity(
            opacity: _opacity.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 脉冲动画 - 用于强调
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scale;
  final bool repeat;
  
  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.scale = 1.05,
    this.repeat = false,
  });
  
  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.scale)
            .chain(CurveTween(curve: AppleCurves.decelerate)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.scale, end: 1.0)
            .chain(CurveTween(curve: AppleCurves.accelerate)),
        weight: 1,
      ),
    ]).animate(_controller);
    
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
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
        return Transform.scale(
          scale: _scale.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 摇晃动画 - 用于错误提示
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Duration duration;
  
  const ShakeAnimation({
    super.key,
    required this.child,
    this.trigger = false,
    this.duration = AnimationDurations.normal,
  });
  
  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shake;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppleCurves.spring,
      ),
    );
  }
  
  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.trigger && widget.trigger) {
      _controller.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final shakeValue = math.sin(_shake.value * math.pi * 4) * 10 * (1 - _shake.value);
        return Transform.translate(
          offset: Offset(shakeValue, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// 骨架屏动画
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;
  
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    required this.baseColor,
    required this.highlightColor,
  });
  
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppleCurves.standard,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _ShimmerTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _ShimmerTransform extends GradientTransform {
  final double percent;
  
  const _ShimmerTransform(this.percent);
  
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}
