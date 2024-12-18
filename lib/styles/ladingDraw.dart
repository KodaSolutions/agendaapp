import 'package:agenda_app/kboardVisibilityManager.dart';
import 'package:agenda_app/projectStyles/appColors.dart';
import 'package:flutter/material.dart';

class LadingDraw extends StatefulWidget {
  const LadingDraw({Key? key}) : super(key: key);

  @override
  State<LadingDraw> createState() => _LadingDrawState();
}

class _LadingDrawState extends State<LadingDraw> {

  late KeyboardVisibilityManager keyboardVisibilityManager;
  @override
  void initState() {
    keyboardVisibilityManager = KeyboardVisibilityManager();
    keyboardVisibilityManager.keyboardVisibilitySubscription =
        keyboardVisibilityManager.keyboardVisibilityController.onChange.listen((bool visible) {
          setState(() {
            isHighWave = visible;
          });
        });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    keyboardVisibilityManager.dispose();
    super.dispose();
  }

  bool isHighWave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: AppColors3.primaryColor),
        child: CustomPaint(
          painter: _LadingDraw(isHighWave: keyboardVisibilityManager.visibleKeyboard),
        ),
      ),
    );
  }
}

class _LadingDraw extends CustomPainter {
  final bool isHighWave;

  _LadingDraw({required this.isHighWave});

  @override
  void paint(Canvas canvas, Size size) {
    final paintSubline = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final pathSubline = Path();

    double offset2 = isHighWave ? 0.08 : 0.0;

    pathSubline.lineTo(0, size.height * (0.61 - offset2));
    pathSubline.quadraticBezierTo(
        size.width * 0.25, size.height * (0.57 - offset2),
        size.width * 0.5, size.height * (0.6 - offset2));
    pathSubline.quadraticBezierTo(
        size.width * 0.75, size.height * (0.64 - offset2),
        size.width, size.height * (0.595 - offset2));
    pathSubline.lineTo(size.width, 0);
    canvas.drawPath(pathSubline, paintSubline);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    double offset = isHighWave ? 0.08 : 0.0;

    path.lineTo(0, size.height * (0.61 - offset));
    path.quadraticBezierTo(
        size.width * 0.25, size.height * (0.57 - offset),
        size.width * 0.5, size.height * (0.6 - offset));
    path.quadraticBezierTo(
        size.width * 0.75, size.height * (0.64 - offset),
        size.width, size.height * (0.595 - offset));
    path.lineTo(size.width, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
