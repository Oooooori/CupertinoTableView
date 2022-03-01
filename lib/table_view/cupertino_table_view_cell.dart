import 'package:flutter/cupertino.dart';

/// TableViewCell类
class CupertinoTableViewCell extends StatefulWidget {
  const CupertinoTableViewCell({
    Key? key,
    required this.builder,
    this.pressedOpacity,
    this.hitBehavior,
    this.onTap,
  }) : super(key: key);

  final double? pressedOpacity;
  final WidgetBuilder builder;
  final HitTestBehavior? hitBehavior;
  final VoidCallback? onTap;

  @override
  State<CupertinoTableViewCell> createState() => _CupertinoTableViewCellState();
}

class _CupertinoTableViewCellState extends State<CupertinoTableViewCell>
    with SingleTickerProviderStateMixin {
  /// pressed动画时长
  static const Duration kFadeOutDuration = Duration(milliseconds: 120);

  /// pressed动画时长
  static const Duration kFadeInDuration = Duration(milliseconds: 180);

  /// pressed动画opacity值
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _setUpAnimation();
    _setTween();
  }

  @override
  void didUpdateWidget(covariant CupertinoTableViewCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setTween();
  }

  /// 初始化动画
  void _setUpAnimation() {
    if (widget.onTap == null) {
      enablePressedAnimation = false;
    } else {
      double pressedOpacity = widget.pressedOpacity ?? 0;
      enablePressedAnimation = pressedOpacity < 1 && pressedOpacity > 0;
    }

    if (!enablePressedAnimation) {
      return;
    }

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        ?.drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.builder(context);
    }
    return GestureDetector(
      behavior: widget.hitBehavior ?? HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: enablePressedAnimation ? _handleTapDown : null,
      onTapUp: enablePressedAnimation ? _handleTapUp : null,
      onTapCancel: enablePressedAnimation ? _handleTapCancel : null,
      child: enablePressedAnimation
          ? FadeTransition(
              opacity: _opacityAnimation!,
              child: widget.builder(context),
            )
          : widget.builder(context),
    );
  }

  /// cell是否被按下去了
  bool _cellHeldDown = false;

  /// 是否应用pressed动画
  bool enablePressedAnimation = false;

  /// 处理TapDown
  void _handleTapDown(TapDownDetails event) {
    if (!_cellHeldDown) {
      _cellHeldDown = true;
      _animate();
    }
  }

  /// 处理TapUp
  void _handleTapUp(TapUpDetails event) {
    if (_cellHeldDown) {
      _cellHeldDown = false;
      _animate();
    }
  }

  /// 处理TapCancel
  void _handleTapCancel() {
    if (_cellHeldDown) {
      _cellHeldDown = false;
      _animate();
    }
  }

  /// pressed动画实现
  void _animate() {
    if (_animationController?.isAnimating ?? true) {
      return;
    }
    final bool wasHeldDown = _cellHeldDown;
    final TickerFuture ticker = _cellHeldDown
        ? _animationController!.animateTo(1.0,
            duration: kFadeOutDuration, curve: Curves.easeInOutCubicEmphasized)
        : _animationController!.animateTo(0.0,
            duration: kFadeInDuration, curve: Curves.easeOutCubic);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _cellHeldDown) {
        _animate();
      }
    });
  }
}
