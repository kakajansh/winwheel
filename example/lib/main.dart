import 'package:flutter/material.dart';
import './examples/basic_code_wheel.dart';
import './examples/wheel_of_fortune.dart';
import './examples/basic_image_wheel.dart';
import './examples/image_per_segment.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winwheel Demo App',
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
