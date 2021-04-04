import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../screens/edit_transaction.dart';

import '../widgets/loading.dart';
import '../widgets/main_drawer.dart';

import '../providers/transactions.dart';

class TransactionsScreen extends StatelessWidget {
  static const routeName = '/transactions';

  Future<void> _refreshTransactions(BuildContext context) async {
    print("_refreshTransactions");
    await Provider.of<TransactionsProvider>(context, listen: false).fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
          future: _refreshTransactions(context),
          builder: (ctx, snapshop) {
            if (snapshop.connectionState == ConnectionState.waiting) {
              return Loading();
            } else {
              if (Provider.of<TransactionsProvider>(context, listen: false)
                      .transactions
                      .length ==
                  0)
                return Center(
                  child: Text('No transaction at the moment...'),
                );
              else
                return RefreshIndicator(
                  onRefresh: () => _refreshTransactions(context),
                  child: Consumer<TransactionsProvider>(
                    builder: (ctx, transactionsProvider, _) => ListView.builder(
                      itemCount: transactionsProvider.transactions.length,
                      itemBuilder: (ctx, index) => Dismissible(
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Are you sure?'),
                            content:
                                Text('Do you want to remove this transaction?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          ),
                        ),
                        background: Container(
                          color: Theme.of(context).errorColor,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                        ),
                        key: ValueKey(
                            transactionsProvider.transactions[index].id),
                        onDismissed: (direction) {
                          Provider.of<TransactionsProvider>(context,
                                  listen: false)
                              .deleteTransaction(
                                  transactionsProvider.transactions[index].id);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transactionsProvider
                                        .transactions[index].amount >
                                    0
                                ? Theme.of(context).accentColor
                                : Theme.of(context).errorColor,
                            child: Text(
                              transactionsProvider.transactions[index].amount >
                                      0
                                  ? "+"
                                  : "-",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                              transactionsProvider.transactions[index].reason),
                          subtitle: Row(
                            children: [
                              Icon(
                                Icons.today,
                                size: 18,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2),
                              Text(
                                DateFormat.yMMMMEEEEd().format(
                                    transactionsProvider
                                        .transactions[index].date),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 2),
                              Text(
                                DateFormat.Hm().format(transactionsProvider
                                    .transactions[index].date),
                              )
                            ],
                          ),
                          trailing: Text(
                            '${transactionsProvider.transactions[index].amount.toStringAsFixed(2)} \$',
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              EditTransactionScreen.routeName,
                              arguments:
                                  transactionsProvider.transactions[index].id,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
