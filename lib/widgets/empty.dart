import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  final String text;

  Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text),
    );
  }
}
