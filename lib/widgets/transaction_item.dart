import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/person.dart';
import '../providers/user.dart';
import '../providers/transactions.dart';

class TransactionItem extends StatelessWidget {
  final String transactionId;
  final double amount;
  final String reason;
  final String type;
  final Person person;
  final DateTime date;
  final Function onTap;
  final Function onDelete;

  TransactionItem({
    @required this.transactionId,
    @required this.amount,
    @required this.reason,
    @required this.person,
    @required this.date,
    @required this.type,
    @required this.onTap,
    @required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).generalAlertDialogTitle,
          ),
          content: Text(
            AppLocalizations.of(context).generalAlertDialogDeleteTransaction,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                AppLocalizations.of(context).generalAlertDialogBtnNo,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                AppLocalizations.of(context).generalAlertDialogBtnYes,
              ),
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
      onDismissed: (direction) async {
        await Provider.of<TransactionsProvider>(
          context,
          listen: false,
        ).deleteTransaction(transactionId);

        /* Update the user */
        await person.refresh(Provider.of<UserProvider>(
          context,
          listen: false,
        ).token);

        onDelete();
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
        title: Row(
          children: [
            if (type != '') const Icon(Icons.history, size: 18),
            if (type != '') const SizedBox(width: 2),
            Text(reason),
          ],
        ),
        subtitle: Text(
          DateFormat.MMMMEEEEd(
            Localizations.localeOf(context).languageCode,
          ).format(date),
        ),
        trailing: Text(
          '${amount.toStringAsFixed(2)} \$',
          style: Theme.of(context).textTheme.headline3.copyWith(
                color: amount < 0 ? Theme.of(context).errorColor : null,
              ),
        ),
        onTap: onTap,
      ),
    );
  }
}
