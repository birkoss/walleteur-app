import 'package:app/models/api.dart';
import 'package:app/models/transaction.dart';
import 'package:flutter/material.dart';

class Person with ChangeNotifier {
  final String id;
  final String name;

  double balance;

  Map<String, double> stats = {
    'amount': 0,
    'total': 0,
  };

  List<Transaction> transactions = [];

  Person(this.id, this.name, this.balance);

  Future<void> refresh(String userToken) async {
    print("refresh");
    final response = await Api.get(
      endpoint: '/v1/person/$id',
      token: userToken,
    );

    if (response['person'] != null) {
      balance = double.parse(response['person']['balance']);
      notifyListeners();
    }
  }
}
