import 'package:flutter/material.dart';

import '../models/api.dart';
import 'person.dart';

class Persons with ChangeNotifier {
  final String _userToken;

  Persons(this._userToken);

  List<Person> _persons = [];

  List<Person> get persons {
    return [..._persons];
  }

  bool get isEmpty {
    return _persons.length == 0;
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

    // Order the list, by name
    _persons.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );

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
    final response = await Api.get(endpoint: '/v1/persons', token: _userToken);

    print(response);

    final persons = response['persons'] as List;
    print(persons);
    _persons = persons.map(
      (p) {
        var person = Person(
          p['id'],
          p['name'],
          double.parse(p['balance']),
        );

        person.weeklyAmount =
            p['weekly_amount'] == null ? 0 : double.parse(p['weekly_amount']);
        person.weeklyTotal = p['weekly_total'];

        return person;
      },
    ).toList();

    print(_persons);

    notifyListeners();
  }

  Future<void> updatePerson(String id, String name) async {
    await Api.patch(
      endpoint: '/v1/person/$id',
      token: _userToken,
      body: {
        'name': name,
      },
    );

    _persons.firstWhere((p) => p.id == id).name = name;

    notifyListeners();
  }
}
