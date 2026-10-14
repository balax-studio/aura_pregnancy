import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// 1. PulseAura: 3D Fetus ve Öne Çıkan Kartlar Arkasındaki Ritmik Nefes / Nabız Işıması
class PulseAura extends StatefulWidget {
  final Widget child;
  final Color auraColor;
  final double maxScale;
  final Duration duration;
  final bool isEnabled;

  const PulseAura({
    super.key,
    required this.child,
    this.auraColor = const Color(0x33FFB6C1),
    this.maxScale = 1.035,
    this.duration = const Duration(milliseconds: 2400),
    this.isEnabled = true,
  });

  @override
  State<PulseAura> createState() => _PulseAuraState();
}

class _PulseAuraState extends State<PulseAura> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.maxScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (widget.isEnabled && !isTest) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulseAura oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
      if (widget.isEnabled && !isTest) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.auraColor.withValues(
                    alpha: (widget.auraColor.a * _opacityAnimation.value).clamp(0.0, 1.0),
                  ),
                  blurRadius: 28 * _scaleAnimation.value,
                  spreadRadius: 4 * (_scaleAnimation.value - 1.0) * 10,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 2. CountingNumberText: Sayıların (Gün, ml, Boy, Gram) Dönen Sayaç (Odometer) Şeklinde Sayılması
class CountingNumberText extends StatelessWidget {
  final num value;
  final String prefix;
  final String suffix;
  final TextStyle style;
  final Duration duration;
  final Curve curve;
  final int decimalPlaces;

  const CountingNumberText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    required this.style,
    this.duration = const Duration(milliseconds: 750),
    this.curve = Curves.easeOutCubic,
    this.decimalPlaces = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, currentVal, child) {
        final formatted = decimalPlaces > 0
            ? currentVal.toStringAsFixed(decimalPlaces)
            : currentVal.toInt().toString();

        return Text(
          '$prefix$formatted$suffix',
          style: style,
        );
      },
    );
  }
}

/// 3. RippleShockwave: Tekme ve Hedef Tamamlama Butonlarında Dışa Açılan Şok Dalgası Halkası
class RippleShockwave extends StatefulWidget {
  final Widget child;
  final Color rippleColor;
  final double maxRadius;
  final VoidCallback? onTap;

  const RippleShockwave({
    super.key,
    required this.child,
    this.rippleColor = const Color(0x66FF8DA1),
    this.maxRadius = 70.0,
    this.onTap,
  });

  @override
  State<RippleShockwave> createState() => RippleShockwaveState();
}

class RippleShockwaveState extends State<RippleShockwave> with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _radiusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOutQuad),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void trigger() {
    _rippleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        trigger();
        widget.onTap?.call();
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _rippleController,
            builder: (context, child) {
              if (!_rippleController.isAnimating && _rippleController.value == 0) {
                return const SizedBox.shrink();
              }
              final size = widget.maxRadius * 2 * _radiusAnimation.value;
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.rippleColor.withValues(
                      alpha: (widget.rippleColor.a * _opacityAnimation.value).clamp(0.0, 1.0),
                    ),
                    width: 3.0 * (1.0 - _radiusAnimation.value).clamp(0.5, 3.0),
                  ),
                ),
              );
            },
          ),
          widget.child,
        ],
      ),
    );
  }
}

/// 4. StaggeredSlideFade: Kartların Kademeli (Staggered) Olarak Yukarıdan Aşağıya Süzülerek Belirmesi
class StaggeredSlideFade extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayStep;
  final Duration duration;
  final Offset offset;

  const StaggeredSlideFade({
    super.key,
    required this.child,
    this.index = 0,
    this.delayStep = const Duration(milliseconds: 45),
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 0.06),
  });

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    final totalDelay = isTest ? Duration.zero : widget.delayStep * widget.index;
    if (totalDelay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(totalDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// 5. SparkleBurst: Mikro Pırıltı ve Yıldız Patlaması (Hedef / Eşik Başarılarında)
class SparkleBurst extends StatefulWidget {
  final Widget child;

  const SparkleBurst({super.key, required this.child});

  @override
  State<SparkleBurst> createState() => SparkleBurstState();
}

class SparkleBurstState extends State<SparkleBurst> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_SparkleParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void fire() {
    _particles.clear();
    const colors = [
      Color(0xFFFFB6C1),
      Color(0xFFFFD1DC),
      Color(0xFFB5EAD7),
      Color(0xFFC7CEEA),
      Color(0xFFFFDAC1),
    ];

    for (int i = 0; i < 14; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 30 + _random.nextDouble() * 50;
      final color = colors[i % colors.length];
      final size = 4.0 + _random.nextDouble() * 4.0;
      _particles.add(_SparkleParticle(
        dx: math.cos(angle) * speed,
        dy: math.sin(angle) * speed,
        color: color,
        size: size,
      ));
    }

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _SparklePainter(
        progress: _controller.value,
        particles: _particles,
        isAnimating: _controller.isAnimating,
      ),
      child: widget.child,
    );
  }
}

class _SparkleParticle {
  final double dx;
  final double dy;
  final Color color;
  final double size;

  _SparkleParticle({
    required this.dx,
    required this.dy,
    required this.color,
    required this.size,
  });
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final List<_SparkleParticle> particles;
  final bool isAnimating;

  _SparklePainter({
    required this.progress,
    required this.particles,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAnimating || progress == 0.0 || progress == 1.0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final currentPos = Offset(
        center.dx + p.dx * Curves.easeOutQuad.transform(progress),
        center.dy + p.dy * Curves.easeOutQuad.transform(progress),
      );

      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = p.color.withValues(alpha: alpha);

      canvas.drawCircle(currentPos, p.size * (1.0 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
