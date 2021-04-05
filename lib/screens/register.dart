import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/login.dart';

import '../models/http_exception.dart';

import '../providers/user.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordController = TextEditingController();

  Map<String, String> _formValues = {
    'email': '',
    'password': '',
  };

  void _showErrorDialog(
      [String errorMessage = 'Something went wrong. Please try again.']) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured!'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _formSubmitted() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .register(_formValues['email'], _formValues['password']);

      Navigator.of(context).pushReplacementNamed('/');
    } on HttpException catch (error) {
      switch (error.toString()) {
        case 'unique':
          _showErrorDialog('This email already exists.');
          break;
        case 'blank':
          _showErrorDialog('All fields are mandatory.');
          break;
        default:
          _showErrorDialog();
      }
    } catch (error) {
      _showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.center,
                width: width,
                height: height * 0.30,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 70,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Walleteur',
                      style: Theme.of(context).textTheme.headline1.copyWith(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline1
                              .color),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Register',
                            style: Theme.of(context).textTheme.headline2,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty || !value.contains('@')) {
                              return 'Invalid Email!';
                            }
                            return null;
                          },
                          onSaved: (newValue) =>
                              _formValues['email'] = newValue,
                        ),
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value.isEmpty || value.length < 8) {
                              return 'Invalid Password! Must be at least 8 characters!';
                            }
                            return null;
                          },
                          onSaved: (newValue) =>
                              _formValues['password'] = newValue,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Password must match!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          child: const Text('REGISTER'),
                          onPressed: _formSubmitted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                child: TextButton(
                  child: const Text('Already have an account? Login'),
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(LoginScreen.routeName);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
