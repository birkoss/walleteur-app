import 'package:flutter/material.dart';

class Person with ChangeNotifier {
  final String id;
  final String name;
  final double balance;

  Map<String, double> stats = {
    'amount': 0,
    'total': 0,
  };

  Person(this.id, this.name, this.balance);
}
