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

  var _isInit = false;
  var _isLoading = false;
  String _personId;

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      _isInit = true;

      _personId = ModalRoute.of(context).settings.arguments as String;

      if (_personId != null) {
        _formValues['name'] = Provider.of<Persons>(context)
            .persons
            .firstWhere((p) => p.id == _personId)
            .name;
      }
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
      if (_personId == null) {
        await Provider.of<Persons>(
          context,
          listen: false,
        ).addPerson(_formValues['name']);
      } else {
        await Provider.of<Persons>(
          context,
          listen: false,
        ).updatePerson(_personId, _formValues['name']);
      }

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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).formLabelName,
                      ),
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
