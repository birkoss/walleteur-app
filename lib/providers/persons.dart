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

    // @TODO: Alphabetical sort (like from the API)
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

  // @TODO: Optimize with Person.refresh()
  Future<void> fetch() async {
    final response = await Api.get(endpoint: '/v1/persons', token: _userToken);

    final persons = response['persons'] as List;
    _persons = persons
        .map((p) => Person(p['id'], p['name'], double.parse(p['balance'])))
        .toList();

    final stats = response['weeklyStats'] as List;
    print(stats);
    stats.forEach((s) {
      _persons.firstWhere((p) => p.id == s['personId']).stats = {
        'amount': s['amount'],
        'total': s['total'] + 0.0,
      };
    });

    print(_persons[0].stats);

    notifyListeners();
  }
}
