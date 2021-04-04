import 'dart:convert';

import 'package:app/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/transaction.dart';

class TransactionsProvider with ChangeNotifier {
  final String _userToken;

  TransactionsProvider(this._userToken);

  List<Transaction> _transactions = [];

  List<Transaction> get transactions {
    return [..._transactions];
  }

  Future<void> addTransaction(
    String personId,
    double amount,
    String reason,
  ) async {
    final url = Uri.http('localhost:8000', '/v1/person/$personId/transactions');

    await http.post(url,
        body: json.encode({
          'amount': amount,
          'reason': reason,
        }),
        headers: {
          'Authorization': 'token $_userToken',
          'content-type': 'application/json',
        });

    await fetch();
  }

  Future<void> deleteTransaction(String transactionId) async {
    // ..
  }

  Future<void> fetch() async {
    final url = Uri.http('localhost:8000', '/v1/transactions');
    final response = await http.get(url, headers: {
      'Authorization': 'token $_userToken',
      'content-type': 'application/json',
    });

    final responseData = json.decode(response.body);

    if (responseData['transactions'] == null) {
      throw HttpException(
          'Cannot fetch transactions list! Please try again later!');
    }

    final transactionsData = responseData['transactions'] as List;
    _transactions = transactionsData
        .map((t) => Transaction(
              id: t['id'],
              amount: double.parse(t['amount']),
              reason: t['reason'],
              date: DateTime.parse(t['date_added']),
            ))
        .toList();

    print("fetch notifyListeners....");
    notifyListeners();
  }
}
