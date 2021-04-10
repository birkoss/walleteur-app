import 'package:app/models/api.dart';
import 'package:app/models/transaction.dart';
import 'package:flutter/material.dart';

class Person with ChangeNotifier {
  final String id;
  final String name;

  double balance;
  bool isUpdatingBalance = false;

  int weeklyTotal = 0;
  double weeklyAmount = 0;

  List<Transaction> transactions = [];

  Person(
    this.id,
    this.name,
    this.balance,
  );

  Future<void> refresh(String userToken) async {
    isUpdatingBalance = true;
    notifyListeners();

    print("refresh");
    final response = await Api.get(
      endpoint: '/v1/person/$id',
      token: userToken,
    );

    /* Refresh balance and weekly stats */
    if (response['person'] != null) {
      var person = response['person'] as Map;
      balance = double.parse(person['balance']);
      weeklyAmount = double.parse(person['weekly_amount']);
      weeklyTotal = person['weekly_total'];
      notifyListeners();
    }

    isUpdatingBalance = false;
    notifyListeners();
  }
}
