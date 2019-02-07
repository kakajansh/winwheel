import 'package:flutter/material.dart';
import 'package:example/examples/basic_code_wheel.dart';
import 'package:example/examples/wheel_of_fortune.dart';
import 'package:example/examples/basic_image_wheel.dart';
import 'package:example/examples/image_per_segment.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winwheel Demo App',
      // theme: ThemeData(primaryColor: Colors.orange),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/basic_code_wheel': (context) => BasicCodeWheel(),
        '/wheel_of_fortune': (context) => WheelOfFortune(),
        '/basic_image_wheel': (context) => BasicImageWheel(),
        '/image_per_segment': (context) => ImagePerSegment(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  static List examples = [
    {
      'image': '',
      'title': 'Basic code wheel',
      'route': '/basic_code_wheel',
    },
    {
      'image': '',
      'title': 'Wheel of Fortune style wheel',
      'route': '/wheel_of_fortune',
    },
    {
      'image': '',
      'title': 'Basic image wheel',
      'route': '/basic_image_wheel',
    },
    {
      'image': '',
      'title': 'One image per segment',
      'route': '/image_per_segment',
    }
  ];

  Widget _buildItem(BuildContext context, Map item) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, item['route']);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              item['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Winwheel'),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.0),
        child: GridView.count(
          crossAxisCount: 2,
          children: examples.map((item) => _buildItem(context, item)).toList(),
        ),
      ),
    );
  }
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         body: Center(
//           child: Container(
//             height: 600,
//             width: 300,
//             color: Colors.white,
//             child: Winwheel(
//               numSegments: 8,
//               outerRadius: 100,
//               innerRadius: 30,
//               strokeStyle: Colors.white,
//               textFontSize: 16.0,
//               textFillStyle: Colors.red,
//               textFontWeight: FontWeight.bold,
//               textAlignment: WinwheelTextAlignment.center,
//               textOrientation: WinwheelTextOrientation.horizontal,
//               wheelImage: 'assets/planes.png',
//               drawMode: WinwheelDrawMode.code,
//               drawText: true,
//               imageOverlay: false,
//               textMargin: 0,
//               pointerAngle: 0,
//               pointerGuide: PointerGuide(
//                 display: true,
//               ),
//               segments: <Segment>[
//                 Segment(
//                   fillStyle: Colors.blue,
//                   textFillStyle: Colors.black,
//                   text: 'multi\nline',
//                   image: 'assets/jane.png',
//                   strokeStyle: Colors.black,
//                 ),
//                 Segment(
//                   fillStyle: Colors.red,
//                   text: '400',
//                   image: 'assets/tom.png',
//                   strokeStyle: Colors.yellow,
//                 ),
//                 Segment(
//                   fillStyle: Colors.yellow,
//                   text: '900',
//                   image: 'assets/mary.png',
//                   strokeStyle: Colors.green,
//                 ),
//                 Segment(
//                   fillStyle: Colors.green,
//                   text: 'loooonggg text',
//                   image: 'assets/alex.png',
//                   strokeStyle: Colors.black,
//                 ),
//                 Segment(
//                   fillStyle: Colors.black,
//                   text: '500',
//                   image: 'assets/sarah.png',
//                   strokeStyle: Colors.blue,
//                 ),
//                 Segment(
//                   fillStyle: Colors.yellow,
//                   text: '900',
//                   image: 'assets/bruce.png',
//                   strokeStyle: Colors.red,
//                 ),
//                 Segment(
//                   fillStyle: Colors.green,
//                   text: 'loooonggg text',
//                   image: 'assets/rose.png',
//                   strokeStyle: Colors.yellow,
//                 ),
//                 Segment(
//                   fillStyle: Colors.black,
//                   text: '500',
//                   image: 'assets/steve.png',
//                   strokeStyle: Colors.green,
//                 ),
//               ],
//               pins: Pin(
//                 // visible: true,
//                 number: 16,
//                 margin: 5,
//                 // outerRadius: 5,
//                 fillStyle: Colors.white,
//               ),
//               animation: WinwheelAnimation(
//                 type: WinwheelAnimationType.spinToStop,
//                 callbackFinished: (int segment) {
//                   print('animation finished');
//                   print(segment);
//                 },
//                 spins: 8,
//                 duration: const Duration(
//                   seconds: 15,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             print('animate');
//           },
//           child: Icon(Icons.play_arrow),
//         ),
//       ),
//     );
//   }
// }
