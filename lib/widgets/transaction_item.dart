import 'package:app/models/person.dart';
import 'package:app/providers/transactions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionItem extends StatelessWidget {
  final String transactionId;
  final double amount;
  final String reason;
  final Person person;
  final DateTime date;
  final Function onTap;

  TransactionItem({
    @required this.transactionId,
    @required this.amount,
    @required this.reason,
    @required this.person,
    @required this.date,
    @required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to remove this transaction?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
      ),
      background: Container(
        color: Theme.of(context).errorColor,
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      key: ValueKey(transactionId),
      onDismissed: (direction) {
        Provider.of<TransactionsProvider>(context, listen: false)
            .deleteTransaction(transactionId);
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: amount > 0
              ? Theme.of(context).accentColor
              : Theme.of(context).errorColor,
          child: Text(
            amount > 0 ? "+" : "-",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(reason),
        subtitle: Row(
          children: [
            Icon(Icons.people, size: 18, color: Colors.grey),
            const SizedBox(width: 2),
            Text(person.name),
            const SizedBox(width: 10),
            const Icon(Icons.today, size: 18, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              DateFormat.MMMMEEEEd().format(date),
            ),
          ],
        ),
        trailing: Text(
          '${amount.toStringAsFixed(2)} \$',
        ),
        onTap: onTap,
      ),
    );
  }
}
