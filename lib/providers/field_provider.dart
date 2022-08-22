// ignore_for_file: use_rethrow_when_possible

import 'dart:convert';
import 'dart:io';

import '../models/apis.dart';
import '../models/field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FieldProvider with ChangeNotifier {
  List<Field> _fields = [];
  List<Field> _searched = [];

  List<int> pages = [];
  List<int> pagesSearched = [];

  int _total = 0;
  int _totalSearched = 0;

  final int _limit = 15;

  int get limit => _limit;

  int get total => _total;

  int get totalSearched => _totalSearched;

  List<Field> get fields {
    return [..._fields];
  }

  List<Field> get searched {
    return [..._searched];
  }

  void checkAndAdd(Field field) {
    final result = findById(field.id);
    if (result == null) {
      _fields.add(field);
    }
  }

  Field? findById(int id) {
    try {
      return fields.firstWhere((field) => field.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addField(
      String arabicTitle, String englishTitle, String token) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.field}');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'nameAr': arabicTitle,
            'nameEn': englishTitle,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final field =
            json.decode(response.body)['data'] as Map<String, dynamic>;

        final newField = Field(
          field['id'],
          arabicTitle,
          englishTitle,
        );

        _fields.add(newField);

        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> updateField(
    int id,
    String token, {
    String? arabicTitle,
    String? englishTitle,
  }) async {
    if (arabicTitle == null && englishTitle == null) {
      return;
    }
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.field}/$id');
    try {
      final String b = json.encode(
        {
          if (arabicTitle != null) 'nameAr': arabicTitle,
          if (englishTitle != null) 'nameEn': englishTitle,
        },
      );

      final response = await http.patch(
        url,
        body: b,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        final colo = extractedData['data']['updatedData'];
        final fieldIndex = _fields.indexWhere((field) => field.id == id);

        if (fieldIndex >= 0) {
          if (arabicTitle != null) {
            _fields[fieldIndex].nameAr = colo['nameAr'];
          }
          if (englishTitle != null) {
            _fields[fieldIndex].nameEn = colo['nameEn'];
          }
        }

        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteField(int id, String token) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.field}/$id');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 204) {
        _fields.removeWhere((field) => field.id == id);
        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Field>> fetchAndSetFields(String token, int pageNum,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _fields = [];
    }
    if (pageNum == 0 && fields.isNotEmpty) {
      return fields;
    }

    if (pages.contains(pageNum)) {
      return fields;
    }

    final offest = fields.length;
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.fieldGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>?;

        if (extractedData == null) {
          throw const HttpException('error');
        }

        _total = extractedData['total'] ?? _total;

        List<Field> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var c in data) {
          if (c['id'] != null && c['nameAr'] != null && c['nameEn'] != null) {
            loadedItems.add(Field(
              c['id'],
              c['nameAr'],
              c['nameEn'],
            ));
          }
        }

        if (pages.contains(pageNum)) {
          return fields;
        }

        _fields.addAll(loadedItems);

        pages.add(pageNum);

        notifyListeners();

        return fields;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<Field>> search(
    String token,
    String name,
    int pageNum, {
    bool? isRefresh,
  }) async {
    if (isRefresh != null && isRefresh) {
      pagesSearched = [];
      _searched = [];
    }
    if (searched.isEmpty) {
      pagesSearched = [];
    }

    if (searched.isNotEmpty && pagesSearched.contains(pageNum)) {
      return searched;
    }

    final search = name != '' ? '&${APIs.name}=$name' : '';
    final offest = searched.length;

    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.fieldGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$search');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>?;
        if (extractedData == null) {
          throw const HttpException('error');
        }

        List<Field> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;
        _totalSearched = extractedData['total'] ?? _totalSearched;

        for (var field in data) {
          if (field['id'] != null &&
              field['nameAr'] != null &&
              field['nameEn'] != null) {
            loadedItems.add(Field(
              field['id'],
              field['nameAr'],
              field['nameEn'],
            ));
          }
        }

        if (pagesSearched.contains(pageNum)) return searched;

        _searched.addAll(loadedItems);
        notifyListeners();

        if (loadedItems.isNotEmpty) {
          pagesSearched.add(pageNum);
        }
        notifyListeners();
        if (pageNum == 1) {
          return searched;
        }
        return loadedItems;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
