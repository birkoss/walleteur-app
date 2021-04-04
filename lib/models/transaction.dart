import 'package:flutter/foundation.dart';

class Transaction {
  final String id;
  final double amount;
  final String reason;
  final DateTime date;

  Transaction({
    @required this.id,
    @required this.amount,
    @required this.reason,
    @required this.date,
  });
}
