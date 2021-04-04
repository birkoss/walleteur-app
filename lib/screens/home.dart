import 'package:app/screens/edit_person.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditPersonScreen.routeName);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder(
          future: _refreshPersons(context),
          builder: (ctx, snapshop) {
            if (snapshop.connectionState == ConnectionState.waiting) {
              return Loading();
            } else {
              if (Provider.of<PersonsProvider>(context, listen: false)
                      .persons
                      .length ==
                  0)
                return Center(
                  child: Text('No person at the moment...'),
                );
              else
                return RefreshIndicator(
                  onRefresh: () => _refreshPersons(context),
                  child: Consumer<PersonsProvider>(
                    builder: (ctx, personsProvider, _) => ListView.builder(
                      itemCount: personsProvider.persons.length,
                      itemBuilder: (ctx, index) => ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            personsProvider.persons[index].name[0]
                                .toUpperCase(),
                          ),
                        ),
                        title: Text(personsProvider.persons[index].name),
                        subtitle: Text('Last week: +XX \$'),
                        trailing: Text(
                          '${personsProvider.persons[index].balance.toStringAsFixed(2)} \$',
                        ),
                        onTap: () {
                          // ...
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
