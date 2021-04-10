import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../screens/edit_transaction.dart';

import '../widgets/empty.dart';
import '../widgets/scheduled_transaction_item.dart';

import '../models/api.dart';
import '../models/scheduled_transaction.dart';

import '../providers/person.dart';
import '../providers/persons.dart';
import '../providers/user.dart';

class ScheduledTransactionsScreen extends StatefulWidget {
  static const routeName = '/scheduled-transactions';
  @override
  _ScheduledTransactionsScreenState createState() =>
      _ScheduledTransactionsScreenState();
}

class _ScheduledTransactionsScreenState
    extends State<ScheduledTransactionsScreen> {
  Person _currentPerson;

  List<ScheduledTransaction> _transactions = [];

  @override
  void didChangeDependencies() {
    if (_currentPerson == null) {
      final personId = ModalRoute.of(context).settings.arguments as String;

      _currentPerson = Provider.of<Persons>(
        context,
      ).persons.firstWhere((p) => p.id == personId);
    }
    super.didChangeDependencies();
  }

  Future<void> _getScheduledTransaction() async {
    final response = await Api.get(
      endpoint: '/v1/person/${_currentPerson.id}/scheduledTransactions',
      token: Provider.of<UserProvider>(context, listen: false).token,
    );

    final transactionsData = response['transactions'] as List;

    _transactions = transactionsData
        .map(
          (t) => ScheduledTransaction(
            id: t['id'],
            amount: double.parse(t['amount']),
            reason: t['reason'],
            intervalAmount: t['interval_amount'],
            intervalType: t['interval_type'],
            date: DateTime.parse(t['date_next_due']),
          ),
        )
        .toList();

    print(_transactions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPerson.name),
        actions: [
          IconButton(
            icon: Icon(Icons.more_time),
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditTransactionScreen.routeName,
                arguments: {
                  'personId': _currentPerson.id,
                  'isScheduled': true,
                  'onAdded': () {
                    setState(() {
                      // ...
                    });
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: _getScheduledTransaction(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return _transactions.length == 0
                ? Empty(AppLocalizations.of(context).profileScreenNoTransaction)
                : ListView.builder(
                    itemBuilder: (ctx, index) => ScheduledTransactionItem(
                      transactionId: _transactions[index].id,
                      amount: _transactions[index].amount,
                      reason: _transactions[index].reason,
                      person: _currentPerson,
                      date: _transactions[index].date,
                      onDelete: () {
                        setState(() {
                          // ...
                        });
                      },
                    ),
                    itemCount: _transactions.length,
                  );
          },
        ),
      ),
    );
  }
}
