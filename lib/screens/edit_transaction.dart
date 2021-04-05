import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/persons.dart';
import '../providers/transactions.dart';

import '../models/person.dart';

class EditTransactionScreen extends StatefulWidget {
  static const routeName = '/edit-transaction';

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _form = GlobalKey<FormState>();

  var _formValues = {
    'amount': '',
    'reason': '',
  };

  var _isLoading = false;
  var _isLoaded = false;

  Person _currentPerson;

  @override
  void didChangeDependencies() {
    if (!_isLoaded) {
      _isLoaded = true;

      final personId = ModalRoute.of(context).settings.arguments as String;
      _currentPerson = Provider.of<PersonsProvider>(
        context,
        listen: false,
      ).persons.firstWhere((p) => p.id == personId);
    }
    super.didChangeDependencies();
  }

  void _submitForm() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TransactionsProvider>(
        context,
        listen: false,
      ).addTransaction(
        _currentPerson.id,
        double.parse(_formValues['amount']),
        _formValues['reason'],
      );

      await Provider.of<PersonsProvider>(context, listen: false).fetch();

      Navigator.of(context).pop();
    } catch (error) {
      print(error);
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text('Something went wrong!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('Ok'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPerson.name),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formValues['amount'],
                      decoration: const InputDecoration(labelText: 'Amount'),
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please provide a valid amount!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formValues['amount'] = value;
                      },
                    ),
                    TextFormField(
                      initialValue: _formValues['reason'],
                      decoration: const InputDecoration(labelText: 'Reason'),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide a value!';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formValues['reason'] = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
