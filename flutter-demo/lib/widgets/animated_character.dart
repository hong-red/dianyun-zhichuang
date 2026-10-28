import 'dart:math';
import 'package:flutter/material.dart';
import '../models/character.dart';

/// 带动画的角色立绘组件
/// - 呼吸动画（轻微缩放）
/// - 浮动效果（上下轻微飘动）
/// - 点击反馈（跳动+光晕）
/// - 说话时轻微晃动
class AnimatedCharacter extends StatefulWidget {
  final Character character;
  final double height;
  final bool isSpeaking;
  final bool isThinking;
  final VoidCallback? onTap;

  const AnimatedCharacter({
    super.key,
    required this.character,
    this.height = 160,
    this.isSpeaking = false,
    this.isThinking = false,
    this.onTap,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathAnimation;
  late Animation<double> _floatAnimation;

  bool _isTapped = false;
  double _tapScale = 1.0;
  double _tapRotation = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _breathAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isTapped) return;

    setState(() {
      _isTapped = true;
      _tapScale = 0.9;
    });

    // 弹跳动画
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _tapScale = 1.08;
          _tapRotation = 0.05;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _tapScale = 0.97;
          _tapRotation = -0.03;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _tapScale = 1.02;
          _tapRotation = 0.02;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _tapScale = 1.0;
          _tapRotation = 0.0;
          _isTapped = false;
        });
      }
    });

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor =
        Color(int.parse('FF${widget.character.primaryColor}', radix: 16));

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double breathScale = _breathAnimation.value;
          double floatY = _floatAnimation.value;

          // 说话时额外抖动
          double speakShake = 0;
          if (widget.isSpeaking) {
            speakShake = sin(_controller.value * 2 * pi * 3) * 1.5;
          }

          // 思考时缓慢旋转
          double thinkRotate = 0;
          if (widget.isThinking) {
            thinkRotate = sin(_controller.value * 2 * pi) * 0.02;
          }

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translate(
                speakShake,
                floatY + (widget.isSpeaking ? -2 : 0),
              )
              ..scale(breathScale * _tapScale)
              ..rotateZ(_tapRotation + thinkRotate),
            child: child,
          );
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景光晕（柔和扩散）
            Container(
              width: widget.height * 1.1,
              height: widget.height * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // 角色立绘（完整显示，无圆形裁剪）
            if (widget.character.imagePath != null)
              Image.asset(
                widget.character.imagePath!,
                height: widget.height,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAvatar(primaryColor);
                },
              )
            else
              _buildFallbackAvatar(primaryColor),
            // 点击波纹效果
            if (_isTapped)
              Container(
                width: widget.height * 0.8,
                height: widget.height * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.6),
                    width: 3,
                  ),
                ),
              ),
            // 思考时的气泡
            if (widget.isThinking)
              Positioned(
                top: 10,
                right: 10,
                child: _ThinkingBubble(color: primaryColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(Color primaryColor) {
    return Container(
      width: widget.height * 0.75,
      height: widget.height * 0.75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
      ),
      child: Center(
        child: Text(
          widget.character.name.substring(0, 1),
          style: TextStyle(
            fontSize: widget.height * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 思考气泡
class _ThinkingBubble extends StatefulWidget {
  final Color color;
  const _ThinkingBubble({required this.color});

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            double delay = index * 0.2;
            double progress = (_controller.value + delay) % 1.0;
            double scale = 0.5 + sin(progress * pi) * 0.5;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.7 * scale),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
