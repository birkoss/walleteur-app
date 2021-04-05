import 'package:flutter/material.dart';

import '../models/api.dart';
import '../models/person.dart';

class PersonsProvider with ChangeNotifier {
  final String _userToken;

  PersonsProvider(this._userToken);

  List<Person> _persons = [];

  List<Person> get persons {
    return [..._persons];
  }

  Future<void> addPerson(String name) async {
    final response = await Api.post(
      endpoint: '/v1/persons',
      token: _userToken,
      body: {
        'name': name,
      },
    );

    _persons.add(Person(response['personId'], name, 0));
    notifyListeners();
  }

  Future<void> deletePerson(String id) async {
    await Api.delete(
      endpoint: '/v1/person/$id',
      token: _userToken,
    );

    _persons.removeWhere((p) => p.id == id);

    notifyListeners();
  }

  Future<void> fetch() async {
    print("fetch....");

    final response = await Api.get(endpoint: '/v1/persons', token: _userToken);

    final persons = response['persons'] as List;
    _persons = persons
        .map((p) => Person(p['id'], p['name'], double.parse(p['balance'])))
        .toList();

    print("notifyListeners....");
    notifyListeners();
  }
}
