import 'dart:convert';

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

    final response = await http.post(url,
        body: json.encode({
          'amount': amount,
          'reason': reason,
        }),
        headers: {
          'Authorization': 'token $_userToken',
          'content-type': 'application/json',
        });

    final responseData = json.decode(response.body);

    _transactions.add(
      Transaction(responseData['transactionId'], amount, reason),
    );
    notifyListeners();
  }
}
