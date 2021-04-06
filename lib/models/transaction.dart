import 'package:flutter/foundation.dart';

import '../models/person.dart';

class Transaction {
  final String id;
  final double amount;
  final String reason;
  final DateTime date;

  final Person person;

  Transaction({
    @required this.id,
    @required this.amount,
    @required this.reason,
    @required this.date,
    @required this.person,
  });
}
