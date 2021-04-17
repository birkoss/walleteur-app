import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Api {
  static final String _baseUrl = 'https://api.walleteur.app';
  //static final String _baseUrl = 'http://localhost:8000';

  static Map<String, String> _getHeaders(String token) {
    Map<String, String> headers = {
      'content-type': 'application/json',
    };

    if (token != null) {
      headers['authorization'] = 'token $token';
    }

    return headers;
  }

  static Future<dynamic> delete({
    @required String endpoint,
    @required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(Api._baseUrl + endpoint),
        headers: Api._getHeaders(token),
      );

      print(Api._getHeaders(token));

      final data = json.decode(response.body);

      print(data);
      if (data['error'] != null) {
        throw HttpException(data['error']);
      }

      return data;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  static Future<dynamic> get({
    String endpoint,
    String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(Api._baseUrl + endpoint),
        headers: Api._getHeaders(token),
      );

      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['error'] != null) {
        throw HttpException(data['error']);
      }

      return data;
    } catch (error) {
      print("Api.get()");
      print(error);
      throw error;
    }
  }

  static Future<dynamic> patch({
    String endpoint,
    Object body,
    String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(Api._baseUrl + endpoint),
        headers: Api._getHeaders(token),
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (data['error'] != null) {
        throw HttpException(data['error']);
      }

      return data;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  static Future<dynamic> post({
    String endpoint,
    Object body,
    String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Api._baseUrl + endpoint),
        headers: Api._getHeaders(token),
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (data['error'] != null) {
        throw HttpException(data['error']);
      }

      return data;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
