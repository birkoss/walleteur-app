import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/loading.dart';
import '../widgets/main_drawer.dart';

import '../providers/persons.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  Future<void> _refreshPersons(BuildContext context) {
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder(
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
                      title: Text(personsProvider.persons[index].name),
                    ),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
