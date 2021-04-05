import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_person.dart';
import '../screens/edit_transaction.dart';

import '../widgets/empty.dart';
import '../widgets/loading.dart';
import '../widgets/main_drawer.dart';

import '../providers/persons.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  Future<void> _refreshPersons(BuildContext context) async {
    await Provider.of<PersonsProvider>(context, listen: false).fetch();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILD...");
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditPersonScreen.routeName);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: _refreshPersons(context),
          builder: (ctx, snapshop) {
            if (snapshop.connectionState == ConnectionState.waiting) {
              return Loading();
            } else {
              return Consumer<PersonsProvider>(
                builder: (ctx, personsProvider, _) => RefreshIndicator(
                  onRefresh: () => _refreshPersons(context),
                  child: personsProvider.isEmpty
                      ? Empty('No person at the moment...')
                      : ListView.builder(
                          itemCount: personsProvider.persons.length,
                          itemBuilder: (ctx, index) => Dismissible(
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
                            key: ValueKey(personsProvider.persons[index].id),
                            onDismissed: (direction) {
                              Provider.of<PersonsProvider>(context,
                                      listen: false)
                                  .deletePerson(
                                      personsProvider.persons[index].id);
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              elevation: 6,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    personsProvider.persons[index].name[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title:
                                    Text(personsProvider.persons[index].name),
                                subtitle: Text('Last week: +XX \$'),
                                trailing: Text(
                                  '${personsProvider.persons[index].balance.toStringAsFixed(2)} \$',
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    EditTransactionScreen.routeName,
                                    arguments:
                                        personsProvider.persons[index].id,
                                  );
                                },
                              ),
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
