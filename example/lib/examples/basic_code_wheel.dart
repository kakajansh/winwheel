import 'package:flutter/material.dart';
import 'package:winwheel/winwheel.dart';
import 'dart:math' as math;

class BasicCodeWheel extends StatefulWidget {
  _BasicCodeWheelState createState() => _BasicCodeWheelState();
}

class _BasicCodeWheelState extends State<BasicCodeWheel> {
  static WinwheelController ctrl;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic code wheel'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Theme.of(context).primaryColor.withAlpha(180),
              child: Center(
                child: Winwheel(
                  handleCallback: ((handler) {
                    ctrl = handler;
                  }),
                  controller: ctrl,
                  // numSegments: 8,
                  outerRadius: 120,
                  innerRadius: 15,
                  strokeStyle: Colors.white,
                  textFontSize: 16.0,
                  textFillStyle: Colors.red,
                  textFontWeight: FontWeight.bold,
                  textAlignment: WinwheelTextAlignment.center,
                  textOrientation: WinwheelTextOrientation.horizontal,
                  wheelImage: 'assets/planes.png',
                  drawMode: WinwheelDrawMode.code,
                  drawText: true,
                  imageOverlay: false,
                  textMargin: 0,
                  pointerAngle: 0,
                  pointerGuide: PointerGuide(
                    display: true,
                  ),
                  segments: <Segment>[
                    Segment(
                      fillStyle: Theme.of(context).primaryColor,
                      textFillStyle: Colors.white,
                      text: 'multi\nline',
                      strokeStyle: Colors.orange,
                    ),
                    Segment(
                      fillStyle: Colors.white,
                      textFillStyle: Theme.of(context).primaryColor,
                      text: '400',
                      strokeStyle: Colors.orange,
                    ),
                    Segment(
                      fillStyle: Theme.of(context).primaryColor,
                      textFillStyle: Colors.white,
                      text: '900',
                      strokeStyle: Colors.orange,
                    ),
                    Segment(
                      fillStyle: Colors.white,
                      textFillStyle: Theme.of(context).primaryColor,
                      text: 'loooonggg',
                      strokeStyle: Colors.orange,
                    ),
                    Segment(
                      fillStyle: Theme.of(context).primaryColor,
                      textFillStyle: Colors.white,
                      text: '600',
                      strokeStyle: Colors.orange,
                    ),
                    Segment(
                      fillStyle: Colors.white,
                      textFillStyle: Theme.of(context).primaryColor,
                      text: '50',
                      strokeStyle: Colors.orange,
                    ),
                  ],
                  pins: Pin(
                    // visible: true,
                    number: 16,
                    margin: 6,
                    // outerRadius: 5,
                    fillStyle: Colors.orange,
                  ),
                  animation: WinwheelAnimation(
                    type: WinwheelAnimationType.spinToStop,
                    spins: 4,
                    duration: const Duration(
                      seconds: 15,
                    ),
                    callbackFinished: (int segment) {
                      setState(() {
                        isPlaying = false;
                      });

                      print('animation finished');
                      print(segment);
                    },
                    callbackBefore: () {
                      setState(() {
                        isPlaying = true;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: <Widget>[
                  IconButton(
                    iconSize: 62,
                    color: Theme.of(context).primaryColor,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        ctrl.pause();

                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        ctrl.play();

                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          print('add');
                          List colors = [
                            Colors.pink,
                            Colors.purple,
                            Colors.amber,
                            Colors.red,
                            Colors.blue,
                            Colors.cyan,
                            Colors.deepPurple,
                            Colors.indigo,
                            Colors.lightBlue
                          ];
                          math.Random random = new math.Random();
                          ctrl.addSegment(
                            Segment(
                              fillStyle: colors[random.nextInt(colors.length)],
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            SizedBox(
                              width: 4,
                            ),
                            Text('add segment'),
                          ],
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          ctrl.deleteSegment();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text('delete segment'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
