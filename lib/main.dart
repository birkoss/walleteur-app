import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/edit_person.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/register.dart';
import './screens/splash.dart';

import './providers/persons.dart';
import './providers/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("MyApp.build()");
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
        ChangeNotifierProxyProvider<UserProvider, PersonsProvider>(
          create: null,
          update: (ctx, user, persons) => PersonsProvider(user.token),
        ),
      ],
      child: Consumer<UserProvider>(
        builder: (ctx, user, _) => MaterialApp(
          title: 'Walleteur',
          theme: ThemeData(
            primarySwatch: Colors.green,
            accentColor: Colors.amber,
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
          },
        ),
      ),
    );
  }
}
