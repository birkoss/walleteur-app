import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/person.dart';
import '../providers/user.dart';

import '../models/api.dart';

class ScheduledTransactionItem extends StatelessWidget {
  final String transactionId;
  final double amount;
  final String reason;
  final Person person;
  final DateTime date;
  final Function onDelete;

  ScheduledTransactionItem({
    @required this.transactionId,
    @required this.amount,
    @required this.reason,
    @required this.person,
    @required this.date,
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
          content: const Text('Do you want to remove this transaction?'),
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
        margin: const EdgeInsets.only(
          top: 4,
          bottom: 20,
        ),
      ),
      key: ValueKey(transactionId),
      onDismissed: (direction) async {
        await Api.delete(
          endpoint: '/v1/scheduledTransaction/$transactionId',
          token: Provider.of<UserProvider>(context, listen: false).token,
        );

        onDelete();
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 6,
        child: ListTile(
          leading: CircleAvatar(
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
          subtitle: Column(
            children: [
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.today,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    DateFormat.MMMMEEEEd(
                      Localizations.localeOf(context).languageCode,
                    ).format(date),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.update,
                    size: 18,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text("Every X days"),
                ],
              ),
            ],
          ),
          trailing: Text(
            '${amount.toStringAsFixed(2)} \$',
            style: Theme.of(context).textTheme.headline3.copyWith(
                  color: amount < 0 ? Theme.of(context).errorColor : null,
                ),
          ),
        ),
      ),
    );
  }
}
