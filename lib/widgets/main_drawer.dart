import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home.dart';
import '../screens/transactions.dart';

import '../providers/user.dart';

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Walleteur'),
            automaticallyImplyLeading: false,
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Transactions'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(TransactionsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
