import 'package:app/models/person.dart';
import 'package:flutter/material.dart';

class PersonsProvider with ChangeNotifier {
  final String _userToken;

  PersonsProvider(this._userToken);

  List<Person> _persons = [];

  List<Person> get persons {
    return [..._persons];
  }
}
