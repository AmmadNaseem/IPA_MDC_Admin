import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'package:moderndrycleanersadmin/config/pallete.dart';

class MyCustomPainter extends CustomPainter{

  MyCustomPainter(this.values):
        bluePaint = Paint()
          ..color = Pallete.blue.withAlpha(50)
          ..style=PaintingStyle.fill,
        pinkPaint = Paint()
          ..color = Pallete.lightBlue.withAlpha(50)
          ..style=PaintingStyle.fill,
        purplePaint = Paint()
          ..color = Pallete.darkBlue.withAlpha(50)
          ..style=PaintingStyle.fill,
        mypaint = Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(0,900 ),
            [
              Pallete.lightBlue.withAlpha(50),
              Pallete.darkBlue.withAlpha(50),
            ],
          ),

        mypaint2 = Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 200),
            Offset(0,700 ),
            [
              Pallete.lightBlue.withAlpha(50),
              Pallete.blue.withAlpha(50),
            ],
          );
  final mypaint;
  final mypaint2;
  //       customPaint= Paint()
  //   ..shader = ui.Gradient.linear(
  //     startOffset,
  //     endOffset,
  //     [
  // Pallete.purple,
  // Pallete.blue,
  //     ],
  //   );
  final Paint bluePaint;
  final Paint pinkPaint;
  final Paint purplePaint;
  // final Paint customPaint;
  final int values;
  @override
  void paint(Canvas canvas, Size size) {
    // paintBlue(canvas,size);
    if(values == 0){
      paintCustomDesign(canvas,size);

    }
    if(values==1){
      paintSecondCircle(canvas,size);

    }
    if(values==2){
      paintCircle(canvas,size);

    }
    if(values==3){
      paintCustomDesign2(canvas,size);
    }
    // paintSmallCircle(canvas,size);
  }
  void paintBlue(Canvas canvas,Size size){
    final path = Path();
    path.moveTo(0, size.height/2);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, pinkPaint);
  }
  void paintCircle(Canvas canvas,Size size){
    final path = Path();
    path.moveTo(size.width/2, size.height/2);
    canvas.drawCircle(Offset(size.width, size.height), 200, mypaint);
    canvas.drawCircle(Offset(100, 100), 55, mypaint);
    canvas.drawCircle(Offset(size.width-100, 20), 25, mypaint);

  }
  void paintSecondCircle(Canvas canvas,Size size){
    canvas.drawCircle(Offset(0, size.height), 200, mypaint2);
    canvas.drawCircle(Offset(150, size.height/1.7), 40, mypaint2);
    canvas.drawCircle(Offset(size.width/4, size.height/6), 30, mypaint2);
    canvas.drawCircle(Offset(size.width/2, 200), 55, mypaint2);
    canvas.drawCircle(Offset(size.width, 0), 55, mypaint2);




  }
  void paintCustomDesign(Canvas canvas,Size size){
    final path = Path();
    path.moveTo (size.width, size.height / 2);
    path. lineTo(size.width, 0);
    path. lineTo(0, 0) ;
    _addPointsToPath(path,[
      Point (0, 0),
      Point (size.width, size.height / 4),
      Point (size.width / 2, size.height / 2),
      Point(size.width, size.height / 2),]);
    canvas.drawPath(path, mypaint);
    canvas.drawCircle(Offset(0, size.height), 250, mypaint2);


  }

  void paintCustomDesign2(Canvas canvas,Size size){
    final path = Path();
    path.moveTo (size.width, size.height / 2);
    path. lineTo(size.width, 0);
    path. lineTo(0, 0) ;
    _addPointsToPath(path,[
      Point (0, 0),
      Point (size.width, size.height / 4),
      Point (size.width / 2, size.height / 2),
      Point(size.width, size.height / 2),
    ]);
    canvas.drawPath(path, mypaint);
    canvas.drawCircle(Offset(-50, size.height/2), 100, mypaint2);
    canvas.drawCircle(Offset(100, size.height/(1.2)), 50, mypaint2);

  }



  @override
  bool shouldRepaint(MyCustomPainter oldDelegate) {
    return true;
  }


}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);
}

void _addPointsToPath(Path path, List<Point> points) {
  if (points.length < 3) {
    throw UnsupportedError('Need three or more points to create a path.');
  }

  for (var i = 0; i < points.length - 2; i++) {
    final xc = (points[i].x + points[i + 1].x) / 2;
    final yc = (points[i].y + points[i + 1].y) / 2;
    path.quadraticBezierTo(points[i].x, points[i].y, xc, yc);
  }

  // connect the last two points
  path.quadraticBezierTo(
      points[points.length - 2].x,
      points[points.length - 2].y,
      points[points.length - 1].x,
      points[points.length - 1].y);
}