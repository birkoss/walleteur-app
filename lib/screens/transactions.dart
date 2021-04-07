import 'package:app/widgets/empty.dart';
import 'package:app/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: const Text('Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: FutureBuilder(
          future: _refreshTransactions(context),
          builder: (ctx, snapshop) {
            if (snapshop.connectionState == ConnectionState.waiting) {
              return Loading();
            } else {
              return Consumer<TransactionsProvider>(
                builder: (ctx, transactionsProvider, _) => RefreshIndicator(
                  onRefresh: () => _refreshTransactions(context),
                  child: transactionsProvider.transactions.length == 0
                      ? Empty('No transaction at the moment...')
                      : ListView.builder(
                          itemCount: transactionsProvider.transactions.length,
                          itemBuilder: (ctx, index) => TransactionItem(
                            transactionId:
                                transactionsProvider.transactions[index].id,
                            amount:
                                transactionsProvider.transactions[index].amount,
                            reason:
                                transactionsProvider.transactions[index].reason,
                            person:
                                transactionsProvider.transactions[index].person,
                            date: transactionsProvider.transactions[index].date,
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
              );
            }
          },
        ),
      ),
    );
  }
}
