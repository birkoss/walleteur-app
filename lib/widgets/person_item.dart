import 'package:app/providers/person.dart';
import 'package:app/providers/persons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PersonItem extends StatelessWidget {
  final Function onTap;

  PersonItem(this.onTap);

  @override
  Widget build(BuildContext context) {
    final person = Provider.of<Person>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'Do you want to remove this person?',
          ),
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
        Provider.of<PersonsProvider>(context, listen: false)
            .deletePerson(person.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 6,
        child: ListTile(
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
          subtitle: Text(
            'Last week: ' +
                (person.stats['amount'] > 0 ? "+" : "") +
                '${person.stats['amount'].toStringAsFixed(2)} \$',
          ),
          trailing: Text(
            '${person.balance.toStringAsFixed(2)} \$',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: person.balance < 0 ? Theme.of(context).errorColor : null,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
