import 'package:flutter/material.dart';
import 'package:svg_path_parser/svg_path_parser.dart';
import 'package:path_drawing/path_drawing.dart';

class CustomLoader extends StatefulWidget {
  final double size;
  const CustomLoader({super.key, this.size = 128.0});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with TickerProviderStateMixin {
  late final AnimationController _wormController;
  late final Animation<double> _wormAnimation;

  late final AnimationController _bumpController;
  late final Animation<Offset> _bumpAnimation;

  @override
  void initState() {
    super.initState();

    _wormController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _wormAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 10, end: 295), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 295, end: 1165), weight: 75),
      ],
    ).animate(CurvedAnimation(
      parent: _wormController,
      curve: const Cubic(0.42, 0.17, 0.75, 0.83),
    ));

    _bumpController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _bumpAnimation = TweenSequence<Offset>(
      [
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 42),
        TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: const Offset(0.0133, 0.0675)),
            weight: 2),
        TweenSequenceItem(
            tween: Tween(begin: const Offset(0.0133, 0.0675), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 5),
        TweenSequenceItem(
            tween:
                Tween(begin: Offset.zero, end: const Offset(-0.1667, -0.0054)),
            weight: 2),
        TweenSequenceItem(
            tween:
                Tween(begin: const Offset(-0.1667, -0.0054), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 4),
        TweenSequenceItem(
            tween:
                Tween(begin: Offset.zero, end: const Offset(0.0366, -0.0246)),
            weight: 2),
        TweenSequenceItem(
            tween:
                Tween(begin: const Offset(0.0366, -0.0246), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 4),
        TweenSequenceItem(
            tween:
                Tween(begin: Offset.zero, end: const Offset(-0.0059, 0.1527)),
            weight: 2),
        TweenSequenceItem(
            tween:
                Tween(begin: const Offset(-0.0059, 0.1527), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 3),
        TweenSequenceItem(
            tween:
                Tween(begin: Offset.zero, end: const Offset(-0.0192, -0.0468)),
            weight: 2),
        TweenSequenceItem(
            tween:
                Tween(begin: const Offset(-0.0192, -0.0468), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 3),
        TweenSequenceItem(
            tween: Tween(begin: Offset.zero, end: const Offset(0.0938, 0.0096)),
            weight: 2),
        TweenSequenceItem(
            tween: Tween(begin: const Offset(0.0938, 0.0096), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 3),
        TweenSequenceItem(
            tween:
                Tween(begin: Offset.zero, end: const Offset(-0.0455, 0.0198)),
            weight: 2),
        TweenSequenceItem(
            tween:
                Tween(begin: const Offset(-0.0455, 0.0198), end: Offset.zero),
            weight: 2),
        TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 8),
      ],
    ).animate(_bumpController);

    _wormController.repeat();
    _bumpController.repeat();
  }

  @override
  void dispose() {
    _wormController.dispose();
    _bumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double actualSize =
          widget.size == 0 ? constraints.biggest.shortestSide : widget.size;

      if (actualSize.isInfinite || actualSize == 0) return const SizedBox();

      return AnimatedBuilder(
        animation: Listenable.merge([_wormAnimation, _bumpAnimation]),
        builder: (context, child) {
          final bump = _bumpAnimation.value;
          return Transform.translate(
            offset: Offset(bump.dx * actualSize, bump.dy * actualSize),
            child: CustomPaint(
              size: Size(actualSize, actualSize),
              painter: _LoaderPainter(
                dashOffset: _wormAnimation.value,
              ),
            ),
          );
        },
      );
    });
  }
}

class _LoaderPainter extends CustomPainter {
  final double dashOffset;

  _LoaderPainter({required this.dashOffset});

  static const String _pathData =
      "M92,15.492S78.194,4.967,66.743,16.887c-17.231,17.938-28.26,96.974-28.26,96.974L119.85,59.892l-99-31.588,57.528,89.832L97.8,19.349,13.636,88.51l89.012,16.015S81.908,38.332,66.1,22.337C50.114,6.156,36,15.492,36,15.492a56,56,0,1,0,56,0Z";

  static final Path _wormPath = parseSvgPath(_pathData);

  static final Gradient _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomLeft,
    colors: [
      HSLColor.fromAHSL(1.0, 193, 0.90, 0.55).toColor(),
      HSLColor.fromAHSL(1.0, 223, 0.90, 0.55).toColor(),
    ],
  );

  static final Paint _wormPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 16
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 128.0, size.height / 128.0);

    _wormPaint.shader =
        _gradient.createShader(const Rect.fromLTWH(0, 0, 128, 128));

    final Path dashedPath = dashPath(
      _wormPath,
      dashArray: CircularIntervalList<double>([44, 1111]),
      dashOffset: DashOffset.absolute(dashOffset),
    );

    canvas.drawPath(dashedPath, _wormPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) {
    return oldDelegate.dashOffset != dashOffset;
  }
}
