import 'package:flutter/foundation.dart';

class ScheduledTransaction {
  final String id;
  final double amount;
  final String reason;
  final DateTime date;
  final int intervalAmount;
  final String intervalType;

  ScheduledTransaction({
    @required this.id,
    @required this.amount,
    @required this.reason,
    @required this.date,
    @required this.intervalAmount,
    @required this.intervalType,
  });
}
