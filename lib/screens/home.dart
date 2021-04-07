import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_person.dart';
import '../screens/profile.dart';

import '../widgets/empty.dart';
import '../widgets/loading.dart';
import '../widgets/main_drawer.dart';
import '../widgets/person_item.dart';

import '../providers/persons.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  Future<void> _refreshPersons(BuildContext context) async {
    await Provider.of<PersonsProvider>(context, listen: false).fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
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
                          itemBuilder: (ctx, index) =>
                              ChangeNotifierProvider.value(
                            value: personsProvider.persons[index],
                            key: ValueKey(personsProvider.persons[index].id),
                            child: PersonItem(
                              () {
                                Navigator.of(context).pushNamed(
                                  ProfileScreen.routeName,
                                  arguments: personsProvider.persons[index].id,
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
