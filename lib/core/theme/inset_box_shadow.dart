import 'package:flutter/material.dart' as material;

/// Saf Flutter Inset & Claymorphism Box Shadow Motoru
class BoxShadow extends material.BoxShadow {
  final bool inset;

  const BoxShadow({
    super.color = const material.Color(0xFF000000),
    super.offset = material.Offset.zero,
    super.blurRadius = 0.0,
    super.spreadRadius = 0.0,
    super.blurStyle = material.BlurStyle.normal,
    this.inset = false,
  });

  @override
  BoxShadow scale(double factor) {
    final scaledBlur = blurRadius * factor;
    return BoxShadow(
      color: color,
      offset: offset * factor,
      blurRadius: scaledBlur < 0.0 ? 0.0 : scaledBlur,
      spreadRadius: spreadRadius * factor,
      blurStyle: blurStyle,
      inset: inset,
    );
  }
}

/// Inset / Çift İç Gölge Destekli Claymorphism BoxDecoration
class BoxDecoration extends material.BoxDecoration {
  const BoxDecoration({
    super.color,
    super.image,
    super.border,
    super.borderRadius,
    List<BoxShadow>? boxShadow,
    super.gradient,
    super.backgroundBlendMode,
    super.shape = material.BoxShape.rectangle,
  }) : super(boxShadow: boxShadow);

  @override
  material.BoxPainter createBoxPainter([material.VoidCallback? onChanged]) {
    return _ClayBoxPainter(this, onChanged);
  }
}

class _ClayBoxPainter extends material.BoxPainter {
  final BoxDecoration _decoration;

  _ClayBoxPainter(this._decoration, material.VoidCallback? onChanged) : super(onChanged);

  void _paintBox(material.Canvas canvas, material.Rect rect, material.TextDirection? textDirection) {
    switch (_decoration.shape) {
      case material.BoxShape.circle:
        assert(_decoration.borderRadius == null);
        final center = rect.center;
        final radius = rect.shortestSide / 2.0;
        _paintShadows(canvas, rect, null, center, radius, textDirection);
        break;
      case material.BoxShape.rectangle:
        if (_decoration.borderRadius == null) {
          _paintShadows(canvas, rect, material.RRect.fromRectAndRadius(rect, material.Radius.zero), null, null, textDirection);
        } else {
          _paintShadows(
            canvas,
            rect,
            _decoration.borderRadius!.resolve(textDirection).toRRect(rect),
            null,
            null,
            textDirection,
          );
        }
        break;
    }
  }

  void _paintShadows(
    material.Canvas canvas,
    material.Rect rect,
    material.RRect? rrect,
    material.Offset? center,
    double? radius,
    material.TextDirection? textDirection,
  ) {
    if (_decoration.boxShadow == null) return;

    for (final shadow in _decoration.boxShadow!) {
      final isInset = shadow is BoxShadow && shadow.inset;

      if (!isInset) {
        // Dış Gölge (Outer Drop Shadow)
        final paint = shadow.toPaint();
        final bounds = rect.shift(shadow.offset).inflate(shadow.spreadRadius);

        if (rrect != null) {
          final shadowRRect = _decoration.borderRadius != null
              ? _decoration.borderRadius!.resolve(textDirection).toRRect(bounds)
              : material.RRect.fromRectAndRadius(bounds, material.Radius.zero);
          canvas.drawRRect(shadowRRect, paint);
        } else if (center != null && radius != null) {
          canvas.drawCircle(center + shadow.offset, radius + shadow.spreadRadius, paint);
        }
      }
    }
  }

  void _paintBackground(material.Canvas canvas, material.Rect rect, material.TextDirection? textDirection) {
    material.Paint? paint;
    if (_decoration.color != null) {
      paint = material.Paint()..color = _decoration.color!;
    }
    if (_decoration.gradient != null) {
      paint = material.Paint()..shader = _decoration.gradient!.createShader(rect, textDirection: textDirection);
    }
    if (paint == null) return;

    if (_decoration.shape == material.BoxShape.circle) {
      final center = rect.center;
      final radius = rect.shortestSide / 2.0;
      canvas.drawCircle(center, radius, paint);
    } else {
      if (_decoration.borderRadius != null) {
        final rrect = _decoration.borderRadius!.resolve(textDirection).toRRect(rect);
        canvas.drawRRect(rrect, paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _paintInnerShadows(material.Canvas canvas, material.Rect rect, material.TextDirection? textDirection) {
    if (_decoration.boxShadow == null) return;

    material.RRect? rrect;
    if (_decoration.shape == material.BoxShape.rectangle) {
      rrect = _decoration.borderRadius != null
          ? _decoration.borderRadius!.resolve(textDirection).toRRect(rect)
          : material.RRect.fromRectAndRadius(rect, material.Radius.zero);
    }

    for (final shadow in _decoration.boxShadow!) {
      final isInset = shadow is BoxShadow && shadow.inset;
      if (!isInset) continue;

      // İç Gölge Çizimi (Inner Shadow with inverse clipping)
      canvas.save();
      if (rrect != null) {
        canvas.clipRRect(rrect);
      } else if (_decoration.shape == material.BoxShape.circle) {
        final path = material.Path()
          ..addOval(material.Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2.0));
        canvas.clipPath(path);
      }

      final shadowPaint = material.Paint()
        ..color = shadow.color
        ..maskFilter = material.MaskFilter.blur(material.BlurStyle.normal, shadow.blurRadius);

      final outerRect = rect.inflate(shadow.blurRadius + 20);
      final innerPath = material.Path();

      if (rrect != null) {
        final shiftedRRect = rrect.shift(shadow.offset);
        innerPath
          ..addRect(outerRect)
          ..addRRect(shiftedRRect)
          ..fillType = material.PathFillType.evenOdd;
      } else if (_decoration.shape == material.BoxShape.circle) {
        final center = rect.center + shadow.offset;
        final radius = rect.shortestSide / 2.0;
        innerPath
          ..addRect(outerRect)
          ..addOval(material.Rect.fromCircle(center: center, radius: radius))
          ..fillType = material.PathFillType.evenOdd;
      }

      canvas.drawPath(innerPath, shadowPaint);
      canvas.restore();
    }
  }

  @override
  void paint(material.Canvas canvas, material.Offset offset, material.ImageConfiguration configuration) {
    assert(configuration.size != null);
    final rect = offset & configuration.size!;
    final textDirection = configuration.textDirection;

    // 1. Dış Gölgeler
    _paintBox(canvas, rect, textDirection);

    // 2. Arka Plan Rengi / Gradient
    _paintBackground(canvas, rect, textDirection);

    // 3. İç Gölgeler (Inset Specular & Shadows)
    _paintInnerShadows(canvas, rect, textDirection);

    // 4. Sır Çerçevesi (Border & Specular Rim)
    if (_decoration.border != null) {
      if (_decoration.shape == material.BoxShape.circle) {
        _decoration.border!.paint(
          canvas,
          rect,
          textDirection: textDirection,
          shape: material.BoxShape.circle,
        );
      } else {
        _decoration.border!.paint(
          canvas,
          rect,
          textDirection: textDirection,
          shape: material.BoxShape.rectangle,
          borderRadius: _decoration.borderRadius?.resolve(textDirection),
        );
      }
    }
  }
}
