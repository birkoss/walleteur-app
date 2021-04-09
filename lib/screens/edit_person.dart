import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../widgets/loading.dart';

import '../providers/persons.dart';

class EditPersonScreen extends StatefulWidget {
  static const routeName = '/edit-person';

  @override
  _EditPersonScreenState createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _form = GlobalKey<FormState>();

  var _formValues = {
    'name': '',
  };

  var _isLoading = false;

  void _submitForm() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Persons>(
        context,
        listen: false,
      ).addPerson(_formValues['name']);

      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            AppLocalizations.of(context).generalAlertDialogErrorTitle,
          ),
          content: Text(
            AppLocalizations.of(context).generalAlertDialogErrorMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Ok'),
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
        title: Text(
          AppLocalizations.of(context).editPersonScreenTitle,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: _isLoading
          ? Loading()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _formValues['name'],
                      decoration: const InputDecoration(labelText: 'Name'),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).errorValue;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formValues['name'] = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
