import 'package:flutter/foundation.dart';

import '../providers/person.dart';

class Transaction {
  final String id;
  final double amount;
  final String reason;
  final DateTime date;

  final Person person;

  final String type;

  Transaction({
    @required this.id,
    @required this.amount,
    @required this.reason,
    @required this.date,
    @required this.person,
    @required this.type,
  });
}
