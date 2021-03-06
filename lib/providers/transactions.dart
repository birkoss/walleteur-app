import 'package:app/providers/person.dart';
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

  // @TODO: Add interest (type=I), configurable in the drawer
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

  Future<void> addScheduledTransaction(
    String personId,
    double amount,
    String reason,
    String date,
    int intervalAmount,
    String intervalType,
  ) async {
    print("addScheduledTransaction");
    await Api.post(
      endpoint: '/v1/person/$personId/scheduledTransactions',
      token: _userToken,
      body: {
        'amount': amount,
        'reason': reason,
        'date_next_due': date,
        'interval_amount': intervalAmount,
        'interval_type': intervalType,
      },
    );

    await fetch();
  }

  Future<void> deleteTransaction(String transactionId) async {
    print("deleteTransaction: $transactionId");
    await Api.delete(
      endpoint: '/v1/transaction/$transactionId',
      token: _userToken,
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
            type: t['type'],
            person: Person(
              t['person']['id'],
              t['person']['name'],
              double.parse(t['person']['balance']),
            )))
        .toList();

    notifyListeners();
  }
}
