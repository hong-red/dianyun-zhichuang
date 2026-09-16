import 'dart:math';
import 'package:flutter/material.dart';
import '../data/characters.dart';
import '../models/character.dart';
import 'chat_page.dart';
import '../services/storage_service.dart';

/// 典籍大陆地图页
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;

  final List<FloatingParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // 生成飘浮粒子
    for (int i = 0; i < 15; i++) {
      _particles.add(FloatingParticle(
        left: _random.nextDouble(),
        delay: _random.nextDouble() * 10,
        duration: 8 + _random.nextDouble() * 8,
        size: 2 + _random.nextDouble() * 3,
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _enterCharacter(Character character) async {
    int affinity = await StorageService.getAffinity(character.id);

    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          character: character,
          apiKey: 'sk-9f4bf5c1920b46c49e528a768f9240fa',
          initialAffinity: affinity,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: Stack(
          children: [
            // 背景渐变
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1a2a4a),
                    Color(0xFF0d1525),
                    Color(0xFF1a2030),
                  ],
                ),
              ),
            ),

            // 山脉背景
            _buildMountains(),

            // 月亮
            Positioned(
              top: 60,
              right: 50,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xCCFFD700),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),

            // 飘浮粒子
            ..._particles.map((p) => _buildParticle(p)),

            // 顶部栏
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '典籍大陆',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 22,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFFFE066), Color(0xFFB8860B)],
                            ),
                            border: Border.all(
                              color: const Color(0xFF8B6914),
                              width: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '100',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 地图节点
            _buildMapNode(
              character: getCharacterById('zhouyi')!,
              left: 0.15,
              top: 0.25,
              icon: '☯',
            ),
            _buildMapNode(
              character: getCharacterById('lunyu')!,
              left: 0.48,
              top: 0.18,
              icon: '📖',
            ),
            _buildMapNode(
              character: getCharacterById('shijing')!,
              left: 0.78,
              top: 0.28,
              icon: '🌸',
            ),
            _buildMapNode(
              character: getCharacterById('shangshu')!,
              left: 0.12,
              top: 0.55,
              icon: '📜',
            ),
            _buildMapNode(
              character: getCharacterById('zhouli')!,
              left: 0.46,
              top: 0.63,
              icon: '⚖',
            ),
            _buildMapNode(
              character: getCharacterById('xiaojing')!,
              left: 0.80,
              top: 0.58,
              icon: '❤',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMountains() {
    return Positioned.fill(
      child: CustomPaint(
        painter: MountainPainter(),
      ),
    );
  }

  Widget _buildParticle(FloatingParticle p) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        double progress =
            ((_floatController.value + p.delay / 10) % 1.0);
        double top = 1.0 - progress;
        double opacity = progress < 0.1
            ? progress * 10
            : progress > 0.9
                ? (1 - progress) * 10
                : 1.0;
        return Positioned(
          left: p.left * MediaQuery.of(context).size.width +
              sin(progress * pi * 2) * 10,
          top: top * MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: opacity * 0.6,
            child: Container(
              width: p.size,
              height: p.size,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD700),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapNode({
    required Character character,
    required double left,
    required double top,
    required String icon,
  }) {
    Color primaryColor =
        Color(int.parse('FF${character.primaryColor}', radix: 16));

    return Positioned(
      left: left * MediaQuery.of(context).size.width - 35,
      top: top * MediaQuery.of(context).size.height - 35,
      child: _MapNodeWidget(
        character: character,
        primaryColor: primaryColor,
        icon: icon,
        onTap: () => _enterCharacter(character),
      ),
    );
  }
}

class _MapNodeWidget extends StatefulWidget {
  final Character character;
  final Color primaryColor;
  final String icon;
  final VoidCallback onTap;

  const _MapNodeWidget({
    required this.character,
    required this.primaryColor,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_MapNodeWidget> createState() => _MapNodeWidgetState();
}

class _MapNodeWidgetState extends State<_MapNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double scale = 1 + sin(_controller.value * pi * 2) * 0.08;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          widget.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        // 外圈光晕
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    widget.primaryColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              widget.character.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
            Text(
              widget.character.roleType,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 远山
    final paint1 = Paint()..color = const Color(0x601a2a4a);
    final path1 = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width * 0.1, size.height * 0.35)
      ..lineTo(size.width * 0.2, size.height * 0.42)
      ..lineTo(size.width * 0.35, size.height * 0.28)
      ..lineTo(size.width * 0.5, size.height * 0.38)
      ..lineTo(size.width * 0.65, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.4)
      ..lineTo(size.width * 0.9, size.height * 0.32)
      ..lineTo(size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint1);

    // 中山
    final paint2 = Paint()..color = const Color(0x80152238);
    final path2 = Path()
      ..moveTo(0, size.height * 0.65)
      ..lineTo(size.width * 0.08, size.height * 0.5)
      ..lineTo(size.width * 0.18, size.height * 0.58)
      ..lineTo(size.width * 0.3, size.height * 0.48)
      ..lineTo(size.width * 0.42, size.height * 0.55)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.68, size.height * 0.53)
      ..lineTo(size.width * 0.82, size.height * 0.47)
      ..lineTo(size.width * 0.95, size.height * 0.56)
      ..lineTo(size.width, size.height * 0.52)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);

    // 近山
    final paint3 = Paint()..color = const Color(0xA00f1825);
    final path3 = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.12, size.height * 0.68)
      ..lineTo(size.width * 0.25, size.height * 0.73)
      ..lineTo(size.width * 0.38, size.height * 0.63)
      ..lineTo(size.width * 0.52, size.height * 0.7)
      ..lineTo(size.width * 0.65, size.height * 0.62)
      ..lineTo(size.width * 0.78, size.height * 0.68)
      ..lineTo(size.width * 0.9, size.height * 0.65)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FloatingParticle {
  final double left;
  final double delay;
  final double duration;
  final double size;

  FloatingParticle({
    required this.left,
    required this.delay,
    required this.duration,
    required this.size,
  });
}
