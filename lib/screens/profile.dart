import 'package:app/models/api.dart';
import 'package:app/providers/person.dart';
import 'package:app/models/transaction.dart';
import 'package:app/providers/persons.dart';
import 'package:app/providers/user.dart';
import 'package:app/screens/edit_transaction.dart';
import 'package:app/widgets/empty.dart';
import 'package:app/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Person _currentPerson;

  List<Transaction> _transactions = [];

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

  Future<void> _getTransaction() async {
    print("Profile._getTransaction()");
    final response = await Api.get(
      endpoint: '/v1/person/${_currentPerson.id}/transactions',
      token: Provider.of<UserProvider>(context, listen: false).token,
    );

    final transactionsData = response['transactions'] as List;
    _transactions = transactionsData
        .map((t) => Transaction(
            id: t['id'],
            amount: double.parse(t['amount']),
            reason: t['reason'],
            date: DateTime.parse(t['date_added']),
            person: Person(
              t['person']['id'],
              t['person']['name'],
              double.parse(t['person']['balance']),
            )))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    print("Profile.build...");
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPerson.name),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditTransactionScreen.routeName,
                arguments: {
                  'personId': _currentPerson.id,
                  'onAdded': () {
                    setState(() {
                      // ...
                    });
                  }
                },
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _getTransaction(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return _transactions.length == 0
              ? Empty('No transaction yet')
              : ListView.builder(
                  itemBuilder: (ctx, index) => TransactionItem(
                    transactionId: _transactions[index].id,
                    amount: _transactions[index].amount,
                    reason: _transactions[index].reason,
                    person: _currentPerson,
                    date: _transactions[index].date,
                    onTap: () {
                      // ...
                    },
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
    );
  }
}
