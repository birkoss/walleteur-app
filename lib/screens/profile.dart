import 'package:app/models/api.dart';
import 'package:app/models/person.dart';
import 'package:app/models/transaction.dart';
import 'package:app/providers/persons.dart';
import 'package:app/providers/user.dart';
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
  List<Transaction> transactions;

  Future<void> getTransaction(BuildContext context, String personId) async {
    final response = await Api.get(
        endpoint: '/v1/person/$personId/transactions',
        token: Provider.of<UserProvider>(context, listen: false).token);

    final transactionsData = response['transactions'] as List;
    transactions = transactionsData
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
    final personId = ModalRoute.of(context).settings.arguments as String;
    Person currentPerson = Provider.of<PersonsProvider>(
      context,
      listen: false,
    ).persons.firstWhere((p) => p.id == personId);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentPerson.name),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // ...
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: getTransaction(context, currentPerson.id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return transactions.length == 0
              ? Empty('No transaction yet')
              : ListView.builder(
                  itemBuilder: (ctx, index) => TransactionItem(
                    transactionId: transactions[index].id,
                    amount: transactions[index].amount,
                    reason: transactions[index].reason,
                    person: transactions[index].person,
                    date: transactions[index].date,
                    onTap: () {
                      // ...
                    },
                  ),
                  itemCount: transactions.length,
                );
        },
      ),
    );
  }
}
