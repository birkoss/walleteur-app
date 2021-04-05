import 'package:flutter/material.dart';

import '../models/api.dart';
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
    await Api.post(
      endpoint: '/v1/person/$personId/transactions',
      token: _userToken,
      body: {
        'amount': amount,
        'reason': reason,
      },
    );

    await fetch();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await Api.delete(
      endpoint: '/v1/transaction/$transactionId',
    );

    _transactions.removeWhere((t) => t.id == transactionId);

    notifyListeners();
  }

  Future<void> fetch() async {
    final response = await Api.get(
      endpoint: '/v1/transactions',
      token: _userToken,
    );

    final transactionsData = response['transactions'] as List;
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
