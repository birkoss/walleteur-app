import 'dart:convert';

import 'package:app/models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/person.dart';

class PersonsProvider with ChangeNotifier {
  final String _userToken;

  PersonsProvider(this._userToken);

  List<Person> _persons = [];

  List<Person> get persons {
    return [..._persons];
  }

  Future<void> addPerson(String name) async {
    final url = Uri.http('localhost:8000', '/v1/persons');

    final response = await http.post(url,
        body: json.encode({
          'name': name,
        }),
        headers: {
          'Authorization': 'token $_userToken',
          'content-type': 'application/json',
        });

    final responseData = json.decode(response.body);

    _persons.add(Person(responseData['personId'], name, 0));
    notifyListeners();
  }

  Future<void> deletePerson(String id) async {
    final url = Uri.http('localhost:8000', '/v1/person/$id');

    await http.delete(url, headers: {
      'Authorization': 'token $_userToken',
      'content-type': 'application/json',
    });

    _persons.removeWhere((p) => p.id == id);

    notifyListeners();
  }

  Future<void> fetch() async {
    print("fetch....");
    final url = Uri.http('localhost:8000', '/v1/persons');
    final response = await http.get(url, headers: {
      'Authorization': 'token $_userToken',
      'content-type': 'application/json',
    });

    final responseData = json.decode(response.body);

    if (responseData['persons'] == null) {
      throw HttpException('Cannot fetch persons list! Please try again later!');
    }

    final personsData = responseData['persons'] as List;
    _persons = personsData
        .map((p) => Person(p['id'], p['name'], double.parse(p['balance'])))
        .toList();

    print("notifyListeners....");
    notifyListeners();
  }
}
