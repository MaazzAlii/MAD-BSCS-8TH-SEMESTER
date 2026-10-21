import 'package:flutter/material.dart';

void main() => runApp(const GestureDetectorExample());

class GestureDetectorExample extends StatelessWidget {
  const GestureDetectorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Gesture Detector App",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Gesture Detector"),
        ),
        body: const Center(
          child: GestureWidget(),
        ),
      ),
    );
  }
}

class GestureWidget extends StatefulWidget {
  const GestureWidget({super.key});

  @override
  State<GestureWidget> createState() => _GestureWidgetState();
}

class _GestureWidgetState extends State<GestureWidget> {
  Color _color = Colors.blue;
  String _eventText = "You haven't performed any action";
  final double radius = 16.0;

  void _onTap() {
    setState(() {
      _color = Colors.red;
      _eventText = "Box is red: you single-tapped";
    });
  }

  void _onDoubleTap() {
    setState(() {
      _color = Colors.yellow;
      _eventText = "Box is yellow: you double-tapped";
    });
  }

  void _onLongPress() {
    setState(() {
      _color = Colors.green;
      _eventText = "Box is green: you long-pressed";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _onTap,
          onDoubleTap: _onDoubleTap,
          onLongPress: _onLongPress,
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _eventText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}