library winwheel;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class WinwheelController {
  Function play;
  Function stop;
  Function pause;
  Function resume;
  Function stopAt;
  Function getRotationPosition;
  Function getIndicatedSegmentNumber;
  Function addSegment;
  Function deleteSegment;
  Function getRandomForSegment;
}

class Winwheel extends StatefulWidget {
  final List segments;
  final WinwheelAnimation animation;
  final PointerGuide pointerGuide;
  final double pointerAngle;
  final Pin pins;
  final double centerX;
  final double centerY;
  final double outerRadius;
  final double innerRadius;
  final int numSegments;
  final WinwheelDrawMode drawMode;
  final double rotationAngle;
  final String textFontFamily;
  final double textFontSize;
  final FontWeight textFontWeight;
  final WinwheelTextOrientation textOrientation;
  final WinwheelTextAlignment textAlignment;
  final double textMargin;
  final Color textFillStyle;
  final Color textStrokeStyle;
  final double textLineWidth;
  final Color fillStyle;
  final Color strokeStyle;
  final double lineWidth;
  final bool clearTheCanvas;
  final bool imageOverlay;
  final bool drawText;
  final String wheelImage;
  final WinwheelImageDirection imageDirection;
  final WinwheelController controller;
  final Function _handlerCallback;

  Winwheel({
    @required Function handleCallback(WinwheelController handler),
    this.segments,
    this.animation,
    this.pointerGuide,
    this.pointerAngle = 0,
    this.pins,
    this.centerX,
    this.centerY,
    this.outerRadius,
    this.innerRadius = 0,
    this.numSegments,
    this.drawMode = WinwheelDrawMode.code,
    this.rotationAngle = 0,
    this.textFontFamily = 'Arial',
    this.textFontSize = 20,
    this.textFontWeight = FontWeight.normal,
    this.textOrientation = WinwheelTextOrientation.horizontal,
    this.textAlignment = WinwheelTextAlignment.center,
    this.textMargin = 0,
    this.textFillStyle = Colors.black,
    this.textStrokeStyle,
    this.textLineWidth = 1,
    this.fillStyle = Colors.grey,
    this.strokeStyle = Colors.black,
    this.lineWidth = 1,
    this.clearTheCanvas = true,
    this.imageOverlay = false,
    this.drawText = true,
    this.wheelImage,
    this.imageDirection = WinwheelImageDirection.north,
    this.controller,
  }) : _handlerCallback = handleCallback;

  _WinwheelState createState() => _WinwheelState();
}

class _WinwheelState extends State<Winwheel>
    with SingleTickerProviderStateMixin {
  List _segments;
  WinwheelAnimation _animation;
  AnimationController _controller;
  Animation<double> _rotation;
  double _pointerAngle;
  PointerGuide _pointerGuide;
  Pin _pins;
  var painter;
  int _numSegments;
  ui.Image _wheelImage;
  WinwheelStatus _status;
  double _latestValue;

  @override
  void initState() {
    super.initState();
    _status = WinwheelStatus.initial;
    _animation = widget.animation ?? new WinwheelAnimation();
    _pointerAngle = widget.pointerAngle;
    _pointerGuide = widget.pointerGuide ?? new PointerGuide();
    _pins = widget.pins;
    _segments = new List();
    _segments.add(null);
    _numSegments = widget.numSegments ?? widget.segments.length;

    WinwheelController handler = WinwheelController();
    handler.play = this.startAnimation;
    handler.stop = this.stopAnimation;
    handler.stopAt = this.stopAt;
    handler.pause = this.pauseAnimation;
    handler.resume = this.resumeAnimation;
    handler.getRotationPosition = this.getRotationPosition;
    handler.getIndicatedSegmentNumber = this.getIndicatedSegmentNumber;
    handler.addSegment = this.addSegment;
    handler.deleteSegment = this.deleteSegment;
    handler.getRandomForSegment = this.getRandomForSegment;
    widget._handlerCallback(handler);

    for (int x = 1; x <= _numSegments; x++) {
      if (widget.segments[x - 1] != null) {
        _segments.add(widget.segments[x - 1]);
      } else {
        _segments.add(new Segment());
      }
    }

    updateSegmentSizes();

    if (widget.drawMode == WinwheelDrawMode.image) {
      _makeWheelImage(widget.wheelImage);
    } else if (widget.drawMode == WinwheelDrawMode.segmentImage) {
      _makeSegmentImages();
    }

    _controller = AnimationController(
      duration: _animation.duration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animation.callbackFinished(getIndicatedSegmentNumber());

          setState(() {
            _status = WinwheelStatus.stopped;
            _latestValue = _animation.stopAngle;
            _animation.stopAngle = null;
          });
        } else if (status == AnimationStatus.forward) {
          _animation.callbackBefore();

          setState(() {
            _status = WinwheelStatus.playing;
          });
        }
      });
    // ..addListener(() {
    // triggerSound();
    // });

    _rotation = Tween(
      begin: 0.0,
      end: _animation.propertyValue,
    ).animate(
      CurvedAnimation(
        curve: _animation.curve,
        parent: _controller,
      ),
    );

    // startAnimation();
    // computeAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void triggerSound() {
    int lastSoundTriggerNumber = 0;
    int currentTriggerNumber = 0;

    if (_animation.soundTrigger == WinwheelSoundTrigger.pin) {
      currentTriggerNumber = getCurrentPinNumber();
    } else {
      currentTriggerNumber = getIndicatedSegmentNumber();
    }

    if (currentTriggerNumber != lastSoundTriggerNumber) {
      _animation.callbackSound();
    }

    lastSoundTriggerNumber = currentTriggerNumber;
  }

  void computeAnimation() {
    // if (_animation.type == 'spinOngoing') {
    //   _animation.propertyName = 'rotationAngle';

    //   if (_animation.spins == null) {
    //     _animation.spins = 5;
    //   }

    //   if (_animation.repeat == null) {
    //     _animation.repeat = -1;
    //   }

    //   if (_animation.curve == null) {
    //     _animation.curve = Curves.linear;
    //   }

    //   _animation.propertyValue = (_animation.spins * 360).toDouble();

    //   if (_animation.direction == 'anti-clockwise') {
    //     _animation.propertyValue = (0 - _animation.propertyValue);
    //   }
    // } else if (_animation.type == 'spinToStop') {
    _animation.propertyName = 'rotationAngle';

    if (_animation.spins == null) {
      _animation.spins = 5;
    }

    if (_animation.repeat == null) {
      _animation.repeat = 0;
    }

    if (_animation.curve == null) {
      _animation.curve = Curves.linear;
    }

    if (_animation.stopAngle == null) {
      _animation.stopAngle = (math.Random().nextDouble() * 359).floorToDouble();
    } else {
      _animation.stopAngle = (360 - _animation.stopAngle + _pointerAngle);
    }

    _animation.propertyValue = (_animation.spins * 360).toDouble();

    if (_animation.direction == WinwheelAnimationDirection.anticlockwise) {
      _animation.propertyValue = (0 - _animation.propertyValue);
      _animation.propertyValue -= (360 - _animation.stopAngle);
    } else {
      _animation.propertyValue += _animation.stopAngle;
    }

    // print("stop angle: " + _animation.stopAngle.toString());
    // print("value: " + _animation.propertyValue.toString());
    // }
  }

  // ==================================================================================================================================================
  // This function starts the wheel's animation by using the properties of the animation object of of the wheel to begin the a greensock tween.
  // ==================================================================================================================================================
  void startAnimation() {
    if (_status == WinwheelStatus.paused) {
      resumeAnimation();
      return;
    }

    _controller.reset();

    // Call function to compute the animation properties.
    computeAnimation();

    _rotation = Tween(
      begin: _latestValue != null ? _latestValue : 0.0,
      end: _animation.propertyValue,
    ).animate(
      CurvedAnimation(
        curve: _animation.curve,
        parent: _controller,
      ),
    );

    _controller.forward();
  }

  // ==================================================================================================================================================
  // Pause animation by telling tween to pause.
  // ==================================================================================================================================================
  void pauseAnimation() {
    _controller.stop();
    setState(() {
      _status = WinwheelStatus.paused;
    });
  }

  // ==================================================================================================================================================
  // Resume the animation by telling tween to continue playing it.
  // ==================================================================================================================================================
  void resumeAnimation() {
    _controller.forward();
    setState(() {
      _status = WinwheelStatus.playing;
    });
  }

  // ==================================================================================================================================================
  // Use same function function which needs to be outside the class for the callback when it stops because is finished.
  // ==================================================================================================================================================
  void stopAnimation() {
    _controller.stop();
    _controller.reset();
    setState(() {
      _status = WinwheelStatus.stopped;
    });
  }

  void stopAt(double degree) {
    setState(() {
      _animation.stopAngle = degree;
    });

    computeAnimation();
  }

  // ==================================================================================================================================================
  // Returns the rotation angle of the wheel corrected to 0-360 (i.e. removes all the multiples of 360).
  // ==================================================================================================================================================
  double getRotationPosition() {
    double rawAngle = _rotation.value; // Get current rotation angle of wheel.

    // If positive work out how many times past 360 this is and then take the floor of this off the rawAngle.
    if (rawAngle >= 0) {
      if (rawAngle > 360) {
        // Get floor of the number of times past 360 degrees.
        var timesPast360 = (rawAngle / 360).floor();

        // Take all this extra off to get just the angle 0-360 degrees.
        rawAngle = (rawAngle - (360 * timesPast360));
      }
    } else {
      // Is negative, need to take off the extra then convert in to 0-360 degree value
      // so if, for example, was -90 then final value will be (360 - 90) = 270 degrees.
      if (rawAngle < -360) {
        var timesPast360 = (rawAngle / 360).ceil(); // Ceil when negative.

        rawAngle = (rawAngle -
            (360 * timesPast360)); // Is minus because dealing with negative.
      }

      rawAngle = (360 +
          rawAngle); // Make in the range 0-360. Is plus because raw is still negative.
    }

    return rawAngle;
  }

  // ====================================================================================================================
  // Works out the segment currently pointed to by the pointer of the wheel. Normally called when the spinning has stopped
  // to work out the prize the user has won. Returns the number of the segment in the segments array.
  // ====================================================================================================================
  int getIndicatedSegmentNumber() {
    int indicatedPrize = 0;
    double rawAngle = getRotationPosition();

    // Now we have the angle of the wheel, but we need to take in to account where the pointer is because
    // will not always be at the 12 o'clock 0 degrees location.
    double relativeAngle = (_pointerAngle - rawAngle).floorToDouble();
    if (relativeAngle < 0) {
      relativeAngle = 360 - relativeAngle.abs();
    }

    // Now we can work out the prize won by seeing what prize segment startAngle and endAngle the relativeAngle is between.
    for (int x = 1; x < _segments.length; x++) {
      if ((relativeAngle >= _segments[x].startAngle) &&
          (relativeAngle <= _segments[x].endAngle)) {
        indicatedPrize = x;
        break;
      }
    }

    return indicatedPrize;
  }

  // ====================================================================================================================
  // Calculates and returns a random stop angle inside the specified segment number. Value will always be 1 degree inside
  // the start and end of the segment to avoid issue with the segment overlap.
  // ====================================================================================================================
  double getRandomForSegment(int segmentNumber) {
    double stopAngle = 0;

    if (_segments[segmentNumber] != null) {
      double startAngle = _segments[segmentNumber].startAngle;
      double endAngle = _segments[segmentNumber].endAngle;
      double range = (endAngle - startAngle) - 2;

      if (range > 0) {
        stopAngle =
            (startAngle + 1 + (math.Random().nextDouble() * range).floor());
      } else {
        print('Segment size is too small to safely get random angle inside it');
      }
    } else {
      print('Segment $segmentNumber undefined');
    }

    return stopAngle;
  }

  // ====================================================================================================================
  // Works out what Pin around the wheel is considered the current one which is the one which just passed the pointer.
  // Used to work out if the pin has changed during the animation to tigger a sound.
  // ====================================================================================================================
  int getCurrentPinNumber() {
    int currentPin = 0;

    if (_pins != null) {
      double rawAngle = getRotationPosition();

      // Now we have the angle of the wheel, but we need to take in to account where the pointer is because
      // will not always be at the 12 o'clock 0 degrees location.
      double relativeAngle = (_pointerAngle - rawAngle).floorToDouble();

      if (relativeAngle < 0) {
        relativeAngle = 360 - relativeAngle.abs();
      }

      // Work out the angle of the pins as this is simply 360 / the number of pins as they space evenly around.
      double pinSpacing = (360 / _pins.number);
      double totalPinAngle = 0;

      // Now we can work out the pin by seeing what pins relativeAngle is between.
      for (int x = 0; x < _pins.number; x++) {
        if ((relativeAngle >= totalPinAngle) &&
            (relativeAngle <= (totalPinAngle + pinSpacing))) {
          currentPin = x;
          break;
        }

        totalPinAngle += pinSpacing;
      }

      // Now if rotating clockwise we must add 1 to the current pin as we want the pin which has just passed
      // the pointer to be returned as the current pin, not the start of the one we are between.
      if (_animation.direction == WinwheelAnimationDirection.clockwise) {
        currentPin++;

        if (currentPin > _pins.number) {
          currentPin = 0;
        }
      }
    }

    return currentPin;
  }

  // ====================================================================================================================
  // This function sorts out the segment sizes. Some segments may have set sizes, for the others what is left out of
  // 360 degrees is shared evenly. What this function actually does is set the start and end angle of the arcs.
  // ====================================================================================================================
  void updateSegmentSizes() {
    // If this object actually contains some segments
    if (_segments != null) {
      // First add up the arc used for the segments where the size has been set.
      double arcUsed = 0;
      int numSet = 0;

      // Remember, to make it easy to access segments, the position of the segments in the array starts from 1 (not 0).
      for (int x = 1; x <= _numSegments; x++) {
        if (_segments[x].size != null) {
          arcUsed += _segments[x].size;
          numSet++;
        }
      }

      double arcLeft = (360 - arcUsed);

      // Create variable to hold how much each segment with non-set size will get in terms of degrees.
      double degreesEach = 0;

      if (arcLeft > 0) {
        degreesEach = (arcLeft / (_numSegments - numSet));
      }

      // ------------------------------------------
      // Now loop though and set the start and end angle of each segment.
      double currentDegree = 0;

      for (int x = 1; x <= _numSegments; x++) {
        // Set start angle.
        _segments[x].startAngle = currentDegree;

        // If the size is set then add this to the current degree to get the end, else add the degreesEach to it.
        if (_segments[x].size != null) {
          currentDegree += _segments[x].size;
        } else {
          currentDegree += degreesEach;
        }

        // Set end angle.
        _segments[x].endAngle = currentDegree;
      }
    }
  }

  // ====================================================================================================================
  // Returns a reference to the segment that is at the location of the pointer on the wheel.
  // ====================================================================================================================
  Segment getIndicatedSegment() {
    // Call function below to work this out and return the prizeNumber.
    int prizeNumber = this.getIndicatedSegmentNumber();

    // Then simply return the segment in the segments array at that position.
    return _segments[prizeNumber];
  }

  // ====================================================================================================================
  // This function allows a segment to be added to the wheel. The position of the segment is optional,
  // if not specified the new segment will be added to the end of the wheel.
  // ====================================================================================================================
  Segment addSegment([Segment segment, int position]) {
    // Create a new segment object passing the options in.
    Segment newSegment = segment ?? new Segment();

    // Increment the numSegments property of the class since new segment being added.
    _numSegments++;
    int segmentPos;

    // Work out where to place the segment, the default is simply as a new segment at the end of the wheel.
    if (position != null) {
      _segments.add(null);

      // Because we need to insert the segment at this position, not overwrite it, we need to move all segments after this
      // location along one in the segments array, before finally adding this new segment at the specified location.
      for (var x = _numSegments; x > position; x--) {
        _segments[x] = _segments[x - 1];
      }

      _segments[position] = newSegment;
      segmentPos = position;
    } else {
      _segments.add(newSegment);
      segmentPos = _numSegments;
    }

    // Since a segment has been added the segment sizes need to be re-computed so call function to do this.
    updateSegmentSizes();
    setState(() {}); // TODO: is it correct?

    // Return the segment object just created in the wheel (JavaScript will return it by reference), so that
    // further things can be done with it by the calling code if desired.
    return _segments[segmentPos];
  }

  // ====================================================================================================================
  // This function deletes the specified segment from the wheel by removing it from the segments array.
  // It then sorts out the other bits such as update of the numSegments.
  // ====================================================================================================================
  void deleteSegment([int position]) {
    // There needs to be at least one segment in order for the wheel to draw, so only allow delete if there
    // is more than one segment currently left in the wheel.

    //++ check that specifying a position that does not exist - say 10 in a 6 segment wheel does not cause issues.
    if (_numSegments > 1) {
      if (position != null) {
        // The array is to be shortened so we need to move all segments after the one
        // to be removed down one so there is no gap.
        for (var x = position; x < _numSegments; x++) {
          _segments[x] = _segments[x + 1];
        }
      }

      // Unset the last item in the segments array since there is now one less.
      _segments.removeLast();
      _numSegments--;

      // Decrement the number of segments,
      // then call function to update the segment sizes.
      updateSegmentSizes();
      setState(() {}); // TODO: is it correct?
    }
  }

  Future<ui.Image> _makeImage(String image) async {
    ui.Image uiImage;

    var bd = await rootBundle.load(image);
    var codec = await ui.instantiateImageCodec(bd.buffer.asUint8List());
    var frameInfo = await codec.getNextFrame();
    uiImage = frameInfo.image;

    return uiImage;
  }

  void _makeWheelImage(String image) async {
    ui.Image img = await _makeImage(image);

    setState(() {
      _wheelImage = img;
    });
  }

  void _makeSegmentImages() async {
    for (int x = 1; x <= _numSegments; x++) {
      Segment seg = _segments[x];
      seg.imgData = await _makeImage(seg.image);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    painter = WinwheelPainter(
      rotation: _rotation,
      numSegments: _numSegments,
      degree: 360 / _numSegments,
      segments: _segments,
      pointerAngle: _pointerAngle,
      pointerGuide: _pointerGuide,
      pins: _pins,
      outerRadius: widget.outerRadius,
      innerRadius: widget.innerRadius,
      drawMode: widget.drawMode,
      rotationAngle: widget.rotationAngle,
      textFontFamily: widget.textFontFamily,
      textFontSize: widget.textFontSize,
      textFontWeight: widget.textFontWeight,
      textOrientation: widget.textOrientation,
      textAlignment: widget.textAlignment,
      textMargin: widget.textMargin,
      textFillStyle: widget.textFillStyle,
      textStrokeStyle: widget.textStrokeStyle,
      textLineWidth: widget.textLineWidth,
      fillStyle: widget.fillStyle,
      strokeStyle: widget.strokeStyle,
      lineWidth: widget.lineWidth,
      clearTheCanvas: widget.clearTheCanvas,
      imageOverlay: widget.imageOverlay,
      drawText: widget.drawText,
      wheelImage: _wheelImage,
      imageDirection: widget.imageDirection,
    );
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return new CustomPaint(painter: painter);
      },
    );
  }
}

class WinwheelPainter extends CustomPainter {
  final Animation<double> rotation;
  final double degree;
  double centerX;
  double centerY;
  double outerRadius;
  final double innerRadius;
  final int numSegments;
  final WinwheelDrawMode drawMode;
  final double rotationAngle;
  final String textFontFamily;
  final double textFontSize;
  final FontWeight textFontWeight;
  final WinwheelTextOrientation textOrientation;
  final WinwheelTextAlignment textAlignment;
  final double textMargin;
  final Color textFillStyle;
  final Color textStrokeStyle;
  final double textLineWidth;
  final Color fillStyle;
  final Color strokeStyle;
  final double lineWidth;
  final bool clearTheCanvas;
  final bool imageOverlay;
  final bool drawText;
  final double pointerAngle;
  final ui.Image wheelImage;
  final WinwheelImageDirection imageDirection;

  final List segments;
  final PointerGuide pointerGuide;
  final Pin pins;

  Canvas _canvas;

  // List _segments;
  WinwheelPainter({
    this.segments,
    this.degree,
    this.centerX,
    this.centerY,
    this.outerRadius,
    this.rotation,
    this.pointerGuide,
    this.pins,
    this.innerRadius,
    this.numSegments,
    this.drawMode,
    this.rotationAngle,
    this.textFontFamily,
    this.textFontSize,
    this.textFontWeight,
    this.textOrientation,
    this.textAlignment,
    this.textMargin,
    this.textFillStyle,
    this.textStrokeStyle,
    this.textLineWidth,
    this.fillStyle,
    this.strokeStyle,
    this.lineWidth,
    this.clearTheCanvas,
    this.imageOverlay,
    this.drawText,
    this.pointerAngle,
    this.wheelImage,
    this.imageDirection,
  }) : super(repaint: rotation);

  @override
  void paint(Canvas canvas, Size size) {
    _canvas = canvas;

    // TODO: add centerX, centerY to widget options
    if (centerX == null) {
      centerX = size.width / 2;
    }

    if (centerY == null) {
      centerY = size.height / 2;
    }

    if (outerRadius == null) {
      if (size.width < size.height) {
        outerRadius = (size.width / 2) - lineWidth;
      } else {
        outerRadius = (size.height / 2) - lineWidth;
      }
    }

    // TODO:
    if ((drawMode == WinwheelDrawMode.image) ||
        (drawMode == WinwheelDrawMode.segmentImage)) {}

    // updateSegmentSizes();

    this.draw();
  }

  void draw() {
    if (drawMode == WinwheelDrawMode.image) {
      drawWheelImage();
    } else if (drawMode == WinwheelDrawMode.segmentImage) {
      drawSegmentImages();
    } else {
      drawSegments();
    }

    if (drawText == true) {
      drawSegmentText();
    }

    if (imageOverlay == true) {
      drawSegments();
    }

    // if (pointerGuide.display == true) {
    //   drawPointerGuide();
    // }

    if (pins != null && pins.visible == true) {
      drawPins();
    }
  }

  // ====================================================================================================================
  // Converts degrees to radians which is what is used when specifying the angles on HTML5 canvas arcs.
  // ====================================================================================================================
  double _degToRad(d) {
    return d * 0.0174532925199432957;
    // return d * math.pi / 180;
  }

  // ====================================================================================================================
  // This function draws the wheel on the page by rendering the segments on the canvas.
  // ====================================================================================================================
  void drawSegments() {
    // Draw the segments if there is at least one in the segments array.
    if (segments != null) {
      Paint paint = Paint()..style = PaintingStyle.fill;

      Paint inner = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round;

      // Loop though and output all segments - position 0 of the array is not used, so start loop from index 1
      // this is to avoid confusion when talking about the first segment.
      for (int x = 1; x <= this.numSegments; x++) {
        // Get the segment object as we need it to read options from.
        Segment seg = this.segments[x];

        // Set the variables that defined in the segment, or use the default options.
        paint.color = seg.fillStyle != null ? seg.fillStyle : fillStyle;
        inner.strokeWidth = seg.lineWidth != null ? seg.lineWidth : lineWidth;
        inner.color = seg.strokeStyle != null ? seg.strokeStyle : strokeStyle;

        // Draw the outer arc of the segment clockwise in direction -->
        _canvas.drawArc(
          Rect.fromCircle(
              center: Offset(centerX, centerY), radius: outerRadius),
          _degToRad(seg.startAngle + rotation.value - 90),
          _degToRad(degree),
          true,
          paint,
        );

        if (innerRadius != null) {
          // Draw another arc, this time anticlockwise <-- at the innerRadius between the end angle and the start angle.
          // Canvas will draw a connecting line from the end of the outer arc to the beginning of the inner arc completing the shape.

          //++ Think the reason the lines are thinner for 2 of the segments is because the thing auto chops part of it
          //++ when doing the next one. Again think that actually drawing the lines will help.

          _canvas.drawArc(
              Rect.fromCircle(
                center: Offset(centerX, centerY),
                radius: innerRadius,
              ),
              _degToRad(seg.endAngle + rotation.value - 90),
              _degToRad(-degree),
              true,
              inner);
        }
      }
    }
  }

  // ====================================================================================================================
  // This draws the text on the segments using the specified text options.
  // ====================================================================================================================
  void drawSegmentText() {
    var fontFamily;
    double fontSize;
    FontWeight fontWeight;
    var orientation;
    var alignment;
    var direction;
    var margin;
    var fillStyle;
    var strokeStyle;
    var lineWidth;

    // Loop though all the segments.
    for (int x = 1; x <= numSegments; x++) {
      // Save the context so it is certain that each segment text option will not affect the other.
      _canvas.save();

      // Get the segment object as we need it to read options from.
      Segment seg = segments[x];

      // Check is text as no point trying to draw if there is no text to render.
      if (seg.text != null) {
        // Set values to those for the specific segment or use global default if null.
        fontFamily =
            (seg.textFontFamily != null) ? seg.textFontFamily : textFontFamily;
        fontSize = (seg.textFontSize != null) ? seg.textFontSize : textFontSize;
        fontWeight =
            (seg.textFontWeight != null) ? seg.textFontWeight : textFontWeight;
        orientation = (seg.textOrientation != null)
            ? seg.textOrientation
            : textOrientation;
        alignment =
            (seg.textAlignment != null) ? seg.textAlignment : textAlignment;
        margin = (seg.textMargin != null) ? seg.textMargin : textMargin;
        fillStyle =
            (seg.textFillStyle != null) ? seg.textFillStyle : textFillStyle;
        strokeStyle = (seg.textStrokeStyle != null)
            ? seg.textStrokeStyle
            : textStrokeStyle;
        lineWidth =
            (seg.textLineWidth != null) ? seg.textLineWidth : textLineWidth;

        // Split the text in to multiple lines on the \n character.
        var lines = seg.text.split('\n');

        // Figure out the starting offset for the lines as when there are multiple lines need to center the text
        // vertically in the segment (when thinking of normal horozontal text).
        double lineOffset = 0 - (fontSize * (lines.length / 2));

        for (var i = 0; i < lines.length; i++) {
          // Normal direction so do things normally.
          // Check text orientation, of horizontal then reasonably straight forward, if vertical then a bit more work to do.
          // TODO: reversed direction
          if (orientation == WinwheelTextOrientation.horizontal) {
            TextAlign textAlign;
            Offset tpOffset;
            // Work out the angle around the wheel to draw the text at, which is simply in the middle of the segment the text is for.
            // The rotation angle is added in to correct the annoyance with the canvas arc drawing functions which put the 0 degrees at the 3 oclock
            double textAngle = _degToRad(seg.endAngle -
                ((seg.endAngle - seg.startAngle) / 2) +
                rotation.value -
                90);

            // We need to rotate in order to draw the text because it is output horizontally, so to
            // place correctly around the wheel for all but a segment at 3 o'clock we need to rotate.
            _canvas.save();
            _canvas.translate(centerX, centerY);
            _canvas.rotate(textAngle);
            _canvas.translate(-centerX, -centerY);

            if (alignment == WinwheelTextAlignment.inner) {
              // Inner means that the text is aligned with the inner of the wheel. If looking at a segment in in the 3 o'clock position
              // it would look like the text is left aligned within the segment.

              // Because the segments are smaller towards the inner of the wheel, in order for the text to fit is is a good idea that
              // a margin is added which pushes the text towards the outer a bit.

              // The inner radius also needs to be taken in to account as when inner aligned.

              textAlign = TextAlign.left;
              tpOffset =
                  Offset(centerX + innerRadius + margin, centerY + lineOffset);
            } else if (alignment == WinwheelTextAlignment.outer) {
              // Outer means the text is aligned with the outside of the wheel, so if looking at a segment in the 3 o'clock position
              // it would appear the text is right aligned. To position we add the radius of the wheel in to the equation
              // and subtract the margin this time, rather than add it.

              textAlign = TextAlign.right;
              tpOffset =
                  Offset(centerX + innerRadius - margin, centerY + lineOffset);
            } else {
              // In this case the text is to drawn centred in the segment.
              // Typically no margin is required, however even though centred the text can look closer to the inner of the wheel
              // due to the way the segments narrow in (is optical effect), so if a margin is specified it is placed on the inner
              // side so the text is pushed towards the outer.

              textAlign = TextAlign.center;
              tpOffset =
                  Offset(centerX + innerRadius + margin, centerY + lineOffset);
            }

            ui.ParagraphBuilder pb = ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: textAlign,
                textDirection: TextDirection.ltr,
                fontSize: fontSize,
                fontFamily: fontFamily,
                fontWeight: fontWeight,
                maxLines: 1,
              ),
            )
              ..pushStyle(ui.TextStyle(color: fillStyle))
              ..addText(lines[i]);

            ui.Paragraph paragraph = pb.build();
            paragraph.layout(ui.ParagraphConstraints(width: outerRadius));

            // --------------------------
            // Draw the text based on its alignment adding margin if inner or outer.
            _canvas.drawParagraph(paragraph, tpOffset);

            // Restore the context so that wheel is returned to original position.
            _canvas.restore();
          } else if (orientation == WinwheelTextOrientation.vertical) {
            // If vertical then we need to do this ourselves because as far as I am aware there is no option built in to html canvas
            // which causes the text to draw downwards or upwards one character after another.

            double yPos;

            // The angle to draw the text at is halfway between the end and the starting angle of the segment.
            double textAngle =
                seg.endAngle - ((seg.endAngle - seg.startAngle) / 2);
            // Ensure the rotation angle of the wheel is added in, otherwise the test placement won't match
            // the segments they are supposed to be for.
            textAngle += rotation.value;

            // Rotate so can begin to place the text.
            _canvas.save();
            _canvas.translate(centerX, centerY);
            _canvas.rotate(_degToRad(textAngle));
            _canvas.translate(-centerX, -centerY);

            // Work out the position to start drawing in based on the alignment.
            // If outer then when considering a segment at the 12 o'clock position want to start drawing down from the top of the wheel.
            if (alignment == WinwheelTextAlignment.outer) {
              yPos = (centerY - outerRadius + margin);
            } else if (alignment == WinwheelTextAlignment.inner) {
              yPos = (centerY - innerRadius - margin);
            }

            // We need to know how much to move the y axis each time.
            // This is not quite simply the font size as that puts a larger gap in between the letters
            // than expected, especially with monospace fonts. I found that shaving a little off makes it look "right".
            double yInc = (fontSize - (fontSize / 9));

            // Loop though and output the characters.
            if (alignment == WinwheelTextAlignment.outer) {
              // For this alignment we draw down from the top of a segment at the 12 o'clock position to simply
              // loop though the characters in order.
              for (int c = 0; c < lines[i].length; c++) {
                String character = lines[i].substring(c, c + 1);

                ui.ParagraphBuilder pb = ui.ParagraphBuilder(
                  ui.ParagraphStyle(
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    fontSize: fontSize,
                    maxLines: 1,
                  ),
                )
                  ..pushStyle(ui.TextStyle(color: fillStyle))
                  ..addText(character);

                ui.Paragraph paragraph = pb.build();
                paragraph.layout(ui.ParagraphConstraints(width: fontSize));
                _canvas.drawParagraph(
                    paragraph, Offset(centerX + lineOffset, yPos));

                yPos += yInc;
              }
            } else if (alignment == WinwheelTextAlignment.inner) {
              // Here we draw from the inner of the wheel up, but in order for the letters in the text text to
              // remain in the correct order when reading, we actually need to loop though the text characters backwards.
              for (var c = seg.text.length - 1; c >= 0; c--) {
                var character = seg.text.substring(c, c + 1);

                ui.ParagraphBuilder pb = ui.ParagraphBuilder(
                  ui.ParagraphStyle(
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    fontSize: fontSize,
                    maxLines: 1,
                  ),
                )
                  ..pushStyle(ui.TextStyle(color: fillStyle))
                  ..addText(character);

                ui.Paragraph paragraph = pb.build();
                paragraph.layout(ui.ParagraphConstraints(width: fontSize));
                _canvas.drawParagraph(
                    paragraph, Offset(centerX + lineOffset, yPos));

                yPos -= yInc;
              }
            } else if (alignment == WinwheelTextAlignment.center) {
              // This is the most complex of the three as we need to draw the text top down centred between the inner and outer of the wheel.
              // So logically we have to put the middle character of the text in the center then put the others each side of it.
              // In reality that is a really bad way to do it, we can achieve the same if not better positioning using a
              // variation on the method used for the rendering of outer aligned text once we have figured out the height of the text.

              // If there is more than one character in the text then an adjustment to the position needs to be done.
              // What we are aiming for is to position the center of the text at the center point between the inner and outer radius.
              double centerAdjusment = 0;

              if (lines[i].length > 1) {
                centerAdjusment = (yInc * (lines[i].length - 1) / 2);
              }

              // Now work out where to start rendering the string. This is half way between the inner and outer of the wheel, with the
              // centerAdjustment included to correctly position texts with more than one character over the center.
              // If there is a margin it is used to push the text away from the center of the wheel.
              var yPos =
                  (centerY - innerRadius - ((outerRadius - innerRadius) / 2)) -
                      centerAdjusment -
                      margin;

              // Now loop and draw just like outer text rendering.
              for (var c = 0; c < lines[i].length; c++) {
                var character = lines[i].substring(c, c + 1);

                ui.ParagraphBuilder pb = ui.ParagraphBuilder(
                  ui.ParagraphStyle(
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    fontSize: fontSize,
                    maxLines: 1,
                  ),
                )
                  ..pushStyle(ui.TextStyle(color: fillStyle))
                  ..addText(character);

                ui.Paragraph paragraph = pb.build();
                paragraph.layout(ui.ParagraphConstraints(width: fontSize));
                _canvas.drawParagraph(
                    paragraph, Offset(centerX + lineOffset, yPos));

                yPos += yInc;
              }
            }

            _canvas.restore();
          }

          // TODO: curved orientation

          // Increment this ready for the next time.
          lineOffset += fontSize;
        }
      }

      // Restore so all text options are reset ready for the next text.
      _canvas.restore();
    }
  }

  // ====================================================================================================================
  // This function draws the wheel on the canvas by rendering the image for each segment.
  // ====================================================================================================================
  void drawSegmentImages() {
    // Draw the segments if there is at least one in the segments array.
    if (segments != null) {
      // Loop though and output all segments - position 0 of the array is not used, so start loop from index 1
      // this is to avoid confusion when talking about the first segment.
      for (int x = 1; x <= numSegments; x++) {
        // Get the segment object as we need it to read options from.
        Segment seg = segments[x];

        // Check image has loaded so a property such as height has a value.
        if (seg.imgData != null) {
          // Work out the correct X and Y to draw the image at which depends on the direction of the image.
          // Images can be created in 4 directions. North, South, East, West.
          // North: Outside at top, inside at bottom. Sits evenly over the 0 degrees angle.
          // South: Outside at bottom, inside at top. Sits evenly over the 180 degrees angle.
          // East: Outside at right, inside at left. Sits evenly over the 90 degrees angle.
          // West: Outside at left, inside at right. Sits evenly over the 270 degrees angle.
          double imageLeft = 0;
          double imageTop = 0;
          double imageAngle = 0;
          WinwheelImageDirection imageDirection;

          imageDirection = seg.imageDirection != null
              ? seg.imageDirection
              : this.imageDirection;

          if (imageDirection == WinwheelImageDirection.south) {
            // Left set so image sits half/half over the 180 degrees point.
            imageLeft = (centerX - (seg.imgData.width / 2));

            // Top so image starts at the centerY.
            imageTop = centerY;

            // Angle to draw the image is its starting angle + half its size.
            // Here we add 180 to the angle to the segment is poistioned correctly.
            imageAngle =
                (seg.startAngle + 180 + ((seg.endAngle - seg.startAngle) / 2));
          } else if (imageDirection == WinwheelImageDirection.east) {
            // Left set so image starts and the center point.
            imageLeft = centerX;

            // Top is so that it sits half/half over the 90 degree point.
            imageTop = (centerY - (seg.imgData.height / 2));

            // Again get the angle in the center of the segment and add it to the rotation angle.
            // this time we need to add 270 to that to the segment is rendered the correct place.
            imageAngle =
                (seg.startAngle + 270 + ((seg.endAngle - seg.startAngle) / 2));
          } else if (imageDirection == WinwheelImageDirection.west) {
            // Left is the centerX minus the width of the image.
            imageLeft = (centerX - seg.imgData.width);

            // Top is so that it sits half/half over the 270 degree point.
            imageTop = (centerY - (seg.imgData.height / 2));

            // Again get the angle in the center of the segment and add it to the rotation angle.
            // this time we need to add 90 to that to the segment is rendered the correct place.
            imageAngle =
                (seg.startAngle + 90 + ((seg.endAngle - seg.startAngle) / 2));
          } else // North is the default.
          {
            // Left set so image sits half/half over the 0 degrees point.
            imageLeft = (centerX - (seg.imgData.width / 2));

            // Top so image is its height out (above) the center point.
            imageTop = (centerY - seg.imgData.height);

            // Angle to draw the image is its starting angle + half its size.
            // this sits it half/half over the center angle of the segment.
            imageAngle =
                (seg.startAngle + ((seg.endAngle - seg.startAngle) / 2));
          }

          // --------------------------------------------------
          // Rotate to the position of the segment and then draw the image.
          _canvas.save();
          _canvas.translate(centerX, centerY);

          // So math here is the rotation angle of the wheel plus half way between the start and end angle of the segment.
          _canvas.rotate(_degToRad(rotation.value + imageAngle));
          _canvas.translate(-centerX, -centerY);

          // Draw the image.
          _canvas.drawImage(seg.imgData, Offset(imageLeft, imageTop), Paint());
          _canvas.restore();
        } else {
          print('Segment $x imgData is not loaded');
        }
      }
    }
  }

  // ====================================================================================================================
  // This function takes an image such as PNG and draws it on the canvas making its center at the centerX and center for the wheel.
  // ====================================================================================================================
  void drawWheelImage() {
    // Double check the wheelImage property of this class is not null. This does not actually detect that an image
    // source was set and actually loaded so might get error if this is not the case. This is why the initial call
    // to draw() should be done from a wheelImage.onload callback as detailed in example documentation.
    if (wheelImage != null) {
      Paint paint = new Paint();

      // Work out the correct X and Y to draw the image at. We need to get the center point of the image
      // aligned over the center point of the wheel, we can't just place it at 0, 0.
      double imageLeft = (centerX - (wheelImage.height / 2));
      double imageTop = (centerY - (wheelImage.width / 2));

      // Rotate and then draw the wheel.
      // We must rotate by the rotationAngle before drawing to ensure that image wheels will spin.
      _canvas.save();
      _canvas.translate(centerX, centerY);
      _canvas.rotate(_degToRad(rotation.value));
      _canvas.translate(-centerX, -centerY);
      _canvas.drawImage(wheelImage, Offset(imageLeft, imageTop), paint);
      _canvas.restore();
    }
  }

  // ====================================================================================================================
  // Draws a line from the center of the wheel to the outside at the angle where the code thinks the pointer is.
  // ====================================================================================================================
  void drawPointerGuide() {
    Paint paint = Paint()
      ..color = pointerGuide.strokeStyle
      ..style = PaintingStyle.stroke
      ..strokeWidth = pointerGuide.lineWidth;

    _canvas.save();

    // Rotate the canvas to the line goes towards the location of the pointer.
    _canvas.translate(centerX, centerY);
    _canvas.rotate(_degToRad(pointerAngle));
    _canvas.translate(-centerX, -centerY);

    // Draw from the center of the wheel outwards past the wheel outer radius.
    _canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, -(outerRadius / 4)),
      paint,
    );

    _canvas.restore();
  }

  // ====================================================================================================================
  // Draws the pins around the outside of the wheel.
  // ====================================================================================================================
  void drawPins() {
    if (pins != null && pins.number != null) {
      // Work out the angle to draw each pin a which is simply 360 / the number of pins as they space evenly around.
      //++ There is a slight oddity with the pins in that there is a pin at 0 and also one at 360 and these will be drawn
      //++ directly over the top of each other. Also pins are 0 indexed which could possibly cause some confusion
      //++ with the getCurrentPin function - for now this is just used for audio so probably not a problem.
      double pinSpacing = (360 / pins.number);

      Paint paint = Paint()
        ..color = pins.fillStyle
        ..style = PaintingStyle.fill;

      for (int i = 1; i <= pins.number; i++) {
        _canvas.save();

        // Move to the center.
        _canvas.translate(centerX, centerY);

        // Rotate to to the pin location which is i * the pinSpacing.
        _canvas.rotate(_degToRad(i * pinSpacing + rotation.value));

        // Move back out.
        _canvas.translate(-centerX, -centerY);

        _canvas.drawCircle(
          Offset(centerX,
              (centerY - outerRadius) + pins.outerRadius + pins.margin),
          pins.outerRadius,
          paint,
        );

        _canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(WinwheelPainter old) {
    return rotation.value != old.rotation.value ||
        numSegments != old.numSegments;
  }
}

class Pin {
  bool visible;
  int number;
  double outerRadius;
  Color fillStyle;
  Color strokeStyle;
  double lineWidth;
  double margin;

  Pin({
    this.visible = true,
    this.number = 36,
    this.outerRadius = 3,
    this.fillStyle = Colors.grey,
    this.strokeStyle = Colors.black,
    this.lineWidth = 1,
    this.margin = 3,
  });
}

class Segment {
  double size;
  String text;
  Color fillStyle;
  Color strokeStyle;
  double lineWidth;
  String textFontFamily;
  double textFontSize;
  FontWeight textFontWeight;
  WinwheelTextOrientation textOrientation;
  WinwheelTextAlignment textAlignment;
  double textMargin;
  Color textFillStyle;
  Color textStrokeStyle;
  double textLineWidth;
  String image;
  WinwheelImageDirection imageDirection;
  ui.Image imgData;
  double startAngle = 0;
  double endAngle = 0;

  Segment({
    this.size,
    this.text = '',
    this.fillStyle,
    this.strokeStyle,
    this.lineWidth,
    this.textFontFamily,
    this.textFontSize,
    this.textFontWeight,
    this.textOrientation,
    this.textAlignment,
    this.textMargin,
    this.textFillStyle,
    this.textStrokeStyle,
    this.textLineWidth,
    this.image,
    this.imageDirection,
    this.imgData,
  });
}

class WinwheelAnimation {
  WinwheelAnimationType
      type; // For now there are only supported types are spinOngoing (continuous), spinToStop, spinAndBack, custom.
  WinwheelAnimationDirection direction; // clockwise or anti-clockwise.
  var propertyName;
  double propertyValue;
  Duration duration;
  int repeat;
  Curve curve;
  double stopAngle;
  int spins;
  var clearTheCanvas;
  Function callbackFinished;
  Function callbackBefore;
  Function callbackAfter;
  Function callbackSound;
  var soundTrigger;

  WinwheelAnimation({
    this.type = WinwheelAnimationType.spinOngoing,
    this.direction = WinwheelAnimationDirection.clockwise,
    this.propertyName,
    this.propertyValue,
    this.duration = const Duration(seconds: 10),
    this.repeat = 0,
    this.curve = Curves.easeOut,
    this.stopAngle,
    this.spins,
    this.clearTheCanvas,
    this.callbackFinished,
    this.callbackBefore,
    this.callbackAfter,
    this.callbackSound,
    this.soundTrigger = WinwheelSoundTrigger.segment,
  });
}

class PointerGuide {
  bool display;
  Color strokeStyle;
  double lineWidth;

  PointerGuide({
    this.display = false,
    this.strokeStyle = Colors.red,
    this.lineWidth = 3,
  });
}

enum WinwheelStatus {
  initial,
  playing,
  paused,
  stopped,
}

enum WinwheelDrawMode {
  code,
  image,
  segmentImage,
}

enum WinwheelAnimationType {
  spinOngoing,
  spinToStop,
  spinAndBack,
}

enum WinwheelAnimationDirection {
  clockwise,
  anticlockwise,
}

enum WinwheelTextAlignment {
  inner,
  outer,
  center,
}

enum WinwheelTextOrientation {
  vertical,
  horizontal,
}

enum WinwheelImageDirection {
  south,
  east,
  west,
  north,
}

enum WinwheelSoundTrigger {
  segment,
  pin,
}
