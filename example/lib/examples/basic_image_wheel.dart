import 'package:flutter/material.dart';
import 'package:winwheel/winwheel.dart';

class BasicImageWheel extends StatefulWidget {
  _BasicImageWheelState createState() => _BasicImageWheelState();
}

class _BasicImageWheelState extends State<BasicImageWheel> {
  static WinwheelController ctrl;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wheel of Fortune'),
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
                  drawMode: WinwheelDrawMode.image,
                  drawText: true,
                  imageOverlay: false,
                  textMargin: 0,
                  pointerAngle: 0,
                  pointerGuide: PointerGuide(
                    display: true,
                  ),
                  segments: <Segment>[
                    Segment(),
                    Segment(),
                    Segment(),
                    Segment(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
