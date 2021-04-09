import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import './screens/edit_person.dart';
import './screens/edit_transaction.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/profile.dart';
import './screens/register.dart';
import './screens/splash.dart';
import './screens/transactions.dart';

import './providers/persons.dart';
import './providers/transactions.dart';
import './providers/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProxyProvider<UserProvider, Persons>(
          create: null,
          update: (ctx, user, persons) => Persons(user.token),
        ),
        ChangeNotifierProxyProvider<UserProvider, TransactionsProvider>(
          create: null,
          update: (ctx, user, transactions) => TransactionsProvider(user.token),
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (ctx, user, _) => MaterialApp(
          title: 'Walleteur',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.green,
            textTheme: TextTheme(
              headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
              headline2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              bodyText2: TextStyle(fontSize: 14.0),
            ),
          ),
          home: user.isLogged
              ? HomeScreen()
              : FutureBuilder(
                  future: user.tryAutoLogin(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SplashScreen();
                    } else {
                      return LoginScreen();
                    }
                  },
                ),
          routes: {
            LoginScreen.routeName: (ctx) => LoginScreen(),
            RegisterScreen.routeName: (ctx) => RegisterScreen(),
            EditPersonScreen.routeName: (ctx) => EditPersonScreen(),
            EditTransactionScreen.routeName: (ctx) => EditTransactionScreen(),
            TransactionsScreen.routeName: (ctx) => TransactionsScreen(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
          },
        ),
      ),
    );
  }
}
