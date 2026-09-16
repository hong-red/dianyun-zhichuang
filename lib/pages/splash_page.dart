import 'dart:math';
import 'package:flutter/material.dart';
import 'map_page.dart';

/// 启动画面 - 小游戏风格
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _btnController;
  late Animation<double> _titleAnimation;
  late Animation<double> _btnAnimation;

  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 生成星星
    for (int i = 0; i < 60; i++) {
      _stars.add(Star(
        left: _random.nextDouble(),
        top: _random.nextDouble(),
        size: 1 + _random.nextDouble() * 2.5,
        delay: _random.nextDouble() * 3,
        duration: 2 + _random.nextDouble() * 3,
      ));
    }

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _titleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    _btnController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _btnAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _titleController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MapPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [Color(0xFF1a1a3e), Color(0xFF0a0a1a)],
          ),
        ),
        child: Stack(
          children: [
            // 星星
            ..._stars.map((star) => _buildStar(star)),

            // 标题
            Center(
              child: FadeTransition(
                opacity: _titleAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _titleController,
                    curve: Curves.easeOut,
                  )),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 装饰线
                      Container(
                        width: 200,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFFFD700),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '典韵智创',
                        style: TextStyle(
                          fontSize: 56,
                          color: Color(0xFFFFD700),
                          letterSpacing: 12,
                          fontWeight: FontWeight.w300,
                          shadows: [
                            Shadow(
                              color: Color(0x80FFD700),
                              blurRadius: 10,
                            ),
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '典籍大陆 · 群贤毕至',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFc9b896),
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 200,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0xFFFFD700),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 开始按钮
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _titleAnimation,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _btnAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFFFFD700).withOpacity(0.3 * _btnAnimation.value),
                              blurRadius: 20 * _btnAnimation.value,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: OutlinedButton(
                      onPressed: _startGame,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD700),
                        side: const BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text(
                        '开 始 旅 程',
                        style: TextStyle(
                          fontSize: 20,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 提示文字
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _btnAnimation,
                child: const Center(
                  child: Text(
                    '点击按钮开始你的典籍之旅',
                    style: TextStyle(
                      color: Color(0x80c9b896),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStar(Star star) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1),
      duration: Duration(seconds: star.duration.toInt()),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Positioned(
          left: star.left * MediaQuery.of(context).size.width,
          top: star.top * MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + value * 0.4,
              child: Container(
                width: star.size,
                height: star.size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
      onEnd: () {
        setState(() {});
      },
    );
  }
}

class Star {
  final double left;
  final double top;
  final double size;
  final double delay;
  final double duration;

  Star({
    required this.left,
    required this.top,
    required this.size,
    required this.delay,
    required this.duration,
  });
}
