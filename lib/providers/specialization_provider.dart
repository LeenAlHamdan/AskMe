// ignore_for_file: use_rethrow_when_possible

import 'dart:convert';
import 'dart:io';

import '../models/apis.dart';
import '../models/specialization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpecializationProvider with ChangeNotifier {
  List<Specialization> _specializations = [];
  List<Specialization> _searched = [];

  List<int> pages = [];
  List<int> pagesSearched = [];

  int _total = 0;
  int _totalSearched = 0;

  final int _limit = 15;

  int get limit => _limit;

  int get total => _total;
  int get totalSearched => _totalSearched;

  List<Specialization> get searched {
    return [..._searched];
  }

  List<Specialization> get specializations {
    return [..._specializations];
  }

  Specialization? findById(int id) {
    try {
      return _specializations
          .firstWhere((specialization) => specialization.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addSpecialization({
    required String arabicTitle,
    required String englishTitle,
    required int fieldId,
    required String fieldNameAr,
    required String fieldNameEn,
    required String token,
  }) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.specialization}');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'nameAr': arabicTitle,
            'nameEn': englishTitle,
            'fieldId': fieldId,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final specialization =
            json.decode(response.body)['data'] as Map<String, dynamic>;

        final newSpecialization = Specialization(
          id: specialization['id'],
          nameAr: arabicTitle,
          nameEn: englishTitle,
          fieldId: fieldId,
          fieldNameAr: fieldNameAr,
          fieldNameEn: fieldNameEn,
        );

        _specializations.add(newSpecialization);
        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> updateSpecialization(
    int id,
    String token, {
    String? arabicTitle,
    String? englishTitle,
    int? fieldId,
    String? fieldNameAr,
    String? fieldNameEn,
  }) async {
    if (arabicTitle == null && englishTitle == null && fieldId == null) {
      return;
    }
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.specialization}/$id');
    try {
      final String b = json.encode(
        {
          if (arabicTitle != null) 'nameAr': arabicTitle,
          if (englishTitle != null) 'nameEn': englishTitle,
          if (fieldId != null) 'fieldId': fieldId,
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
        final specializationIndex = _specializations
            .indexWhere((specialization) => specialization.id == id);

        if (specializationIndex >= 0) {
          if (fieldId != null) {
            _specializations[specializationIndex].fieldId = colo['fieldId'];
            if (fieldNameAr != null && fieldNameEn != null) {
              _specializations[specializationIndex].fieldNameAr = fieldNameAr;
              _specializations[specializationIndex].fieldNameEn = fieldNameEn;
            }
          }
          if (arabicTitle != null) {
            _specializations[specializationIndex].nameAr = colo['nameAr'];
          }
          if (englishTitle != null) {
            _specializations[specializationIndex].nameEn = colo['nameEn'];
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

  Future<void> deleteSpecialization(int id, String token) async {
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.specialization}/$id');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 204) {
        _specializations
            .removeWhere((specialization) => specialization.id == id);
        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Specialization>> fetchAndSetSpecializations(
      String token, int pageNum,
      {bool? isRefresh, int? fieldId}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _specializations = [];
    }

    if (pages.contains(pageNum)) {
      return specializations;
    }

    final field = fieldId != null ? '&fieldId=$fieldId' : '';
    final offest = specializations.isNotEmpty ? specializations.length : 0;
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.specializationGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$field');

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

        List<Specialization> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var item in data) {
          if (item['id'] != null &&
              item['nameAr'] != null &&
              item['nameEn'] != null &&
              item['fieldId'] != null &&
              item['fieldNameAr'] != null &&
              item['fieldNameEn'] != null) {
            loadedItems.add(Specialization(
              id: item['id'],
              nameAr: item['nameAr'],
              nameEn: item['nameEn'],
              fieldId: item['fieldId'],
              fieldNameAr: item['fieldNameAr'],
              fieldNameEn: item['fieldNameEn'],
            ));
          }
        }

        if (pages.contains(pageNum)) return specializations;

        _specializations.addAll(loadedItems);

        pages.add(pageNum);
        notifyListeners();
        return specializations;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<Specialization>> search(
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
        '${APIs.host}/${APIs.environment}/${APIs.specializationGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$search');

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

        List<Specialization> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;
        _totalSearched = extractedData['total'] ?? _totalSearched;

        for (var item in data) {
          if (item['id'] != null &&
              item['nameAr'] != null &&
              item['nameEn'] != null &&
              item['fieldId'] != null &&
              item['fieldNameAr'] != null &&
              item['fieldNameEn'] != null) {
            loadedItems.add(Specialization(
              id: item['id'],
              nameAr: item['nameAr'],
              nameEn: item['nameEn'],
              fieldId: item['fieldId'],
              fieldNameAr: item['fieldNameAr'],
              fieldNameEn: item['fieldNameEn'],
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
