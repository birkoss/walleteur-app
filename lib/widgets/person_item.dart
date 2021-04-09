import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../providers/persons.dart';
import '../providers/person.dart';

class PersonItem extends StatelessWidget {
  final Function onTap;

  PersonItem(this.onTap);

  @override
  Widget build(BuildContext context) {
    var person = Provider.of<Person>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).generalAlertDialogTitle,
          ),
          content: Text(
            AppLocalizations.of(context).generalAlertDialogDeletePerson,
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
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(
          top: 4,
          bottom: 20,
        ),
      ),
      key: ValueKey(person.id),
      onDismissed: (direction) {
        Provider.of<Persons>(context, listen: false).deletePerson(person.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 6,
        child: Consumer<Person>(
          builder: (ctx, p, _) => ListTile(
            leading: CircleAvatar(
              child: Text(
                person.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(person.name),
            subtitle: p.isUpdatingBalance
                ? LinearProgressIndicator()
                : Text(
                    AppLocalizations.of(context).personItemLastWeek +
                        (p.stats['amount'] > 0 ? "+" : "") +
                        '${p.stats['amount'].toStringAsFixed(2)} \$',
                  ),
            trailing: p.isUpdatingBalance
                ? SizedBox(
                    width: 50,
                    child: LinearProgressIndicator(),
                  )
                : Text(
                    '${p.balance.toStringAsFixed(2)} \$',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: person.balance < 0
                          ? Theme.of(context).errorColor
                          : null,
                    ),
                  ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
