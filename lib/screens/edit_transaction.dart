import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/person.dart';
import '../providers/persons.dart';
import '../providers/user.dart';
import '../providers/transactions.dart';

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
    'date_next_due': DateTime.now().add(Duration(days: 1)),
    'intervalAmount': '7',
    'intervalType': 'daily',
  };

  var _isLoading = false;
  var _isLoaded = false;

  Person _currentPerson;
  var _isScheduled = false;
  Function _onAdded;

  List<DropdownMenuItem<String>> _intervalTypes = [
    DropdownMenuItem(
      child: Text('days'),
      value: 'daily',
    ),
    DropdownMenuItem(
      child: Text('months'),
      value: 'monthly',
    ),
  ];

  @override
  void didChangeDependencies() {
    if (!_isLoaded) {
      _isLoaded = true;

      final data = ModalRoute.of(context).settings.arguments as Map;

      final personId = data['personId'];
      _onAdded = data['onAdded'];
      _isScheduled = data['isScheduled'] == true;

      _currentPerson = Provider.of<Persons>(
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
      print("_submitForm");
      if (_isScheduled) {
        print("isScheduled...");
        print(_formValues);
        await Provider.of<TransactionsProvider>(
          context,
          listen: false,
        ).addScheduledTransaction(
          _currentPerson.id,
          double.parse(_formValues['amount']),
          _formValues['reason'],
          _formValues['date_next_due'].toString().substring(0, 10),
          int.parse(_formValues['intervalAmount']),
          _formValues['intervalType'],
        );
      } else {
        await Provider.of<TransactionsProvider>(
          context,
          listen: false,
        ).addTransaction(
          _currentPerson.id,
          double.parse(_formValues['amount']),
          _formValues['reason'],
        );
      }

      /* Refresh the current user since the balance and other stats has changed */
      await _currentPerson.refresh(Provider.of<UserProvider>(
        context,
        listen: false,
      ).token);

      /* Callback the widget to refresh the list */
      _onAdded();

      Navigator.of(context).pop();
    } catch (error) {
      print(error);
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
          _isScheduled
              ? AppLocalizations.of(context).editScheduledTransactionScreenTitle
              : AppLocalizations.of(context).editTransactionScreenTitle,
        ),
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
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).formLabelAmount,
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).errorValue;
                        }
                        if (double.tryParse(value) == null) {
                          return AppLocalizations.of(context)
                              .errorInvalidAmount;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formValues['amount'] = value;
                      },
                    ),
                    TextFormField(
                      initialValue: _formValues['reason'],
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).formLabelReason,
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).errorValue;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _formValues['reason'] = value;
                      },
                    ),
                    if (_isScheduled)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Next Due: '),
                            Text(
                              DateFormat.yMMMMEEEEd(
                                Localizations.localeOf(context).languageCode,
                              ).format(_formValues['date_next_due']),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () async {
                                // ...
                                var date = await showDatePicker(
                                  context: context,
                                  firstDate:
                                      DateTime.now().add(Duration(days: 1)),
                                  initialDate: _formValues['date_next_due'],
                                  lastDate: DateTime.now().add(
                                    Duration(days: 365),
                                  ),
                                );

                                if (date != null) {
                                  setState(() {
                                    _formValues['date_next_due'] = date;
                                  });
                                }
                              },
                              child: Text('Select Date'),
                            )
                          ],
                        ),
                      ),
                    if (_isScheduled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Repeat every'),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: _formValues['intervalAmount'],
                              decoration: InputDecoration(
                                labelText: 'Amount',
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                signed: false,
                                decimal: false,
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return AppLocalizations.of(context)
                                      .errorValue;
                                }
                                if (int.tryParse(value) == null) {
                                  return AppLocalizations.of(context)
                                      .errorInvalidAmount;
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _formValues['intervalAmount'] = value;
                              },
                            ),
                          ),
                          DropdownButton<String>(
                            value: _formValues['intervalType'],
                            items: _intervalTypes,
                            onChanged: (value) {
                              setState(() {
                                _formValues['intervalType'] = value;
                              });
                            },
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
