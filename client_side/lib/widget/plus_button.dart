import 'package:flutter/material.dart';

class PlusButton extends StatelessWidget {
  final VoidCallback? function;

  PlusButton({this.function});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: function,
      backgroundColor: Color(0xFF438883),
      child: Icon(Icons.add),
    );
  }
}
