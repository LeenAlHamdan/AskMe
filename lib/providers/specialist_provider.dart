// ignore_for_file: use_rethrow_when_possible, prefer_null_aware_operators

import 'dart:convert';
import 'dart:io';

import '../models/apis.dart';
import '../models/specialist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpecialistProvider with ChangeNotifier {
  List<Specialist> _specialists = [];

  List<int> pages = [];
  List<int> pagesSearched = [];

  int _total = 0;

  final int _limit = 24;

  int get total => _total;

  List<Specialist> get specialists {
    return [..._specialists];
  }

  Specialist? findById(int id) {
    try {
      return _specialists.firstWhere((specialist) => specialist.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> registerAsSpecialist({
    required String lat,
    required String lng,
    required int specializationId,
    required String token,
  }) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.specialist}');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'lng': lng,
            'lat': lat,
            'specializationId': specializationId,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 201) {
        // final specialist =
        json.decode(response.body)['data'] as Map<String, dynamic>;

        /*  final newMaterial = MyMaterial(
        id
        );
 */
        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> deleteSpecialist(int id, String token) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.specialist}/$id');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 204) {
        _specialists.removeWhere((specialist) => specialist.id == id);
        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<double> rateSpecialist(
    int specialistId,
    int stars,
    String token,
  ) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.rateSpecialist}');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'specialistId': specialistId,
            'stars': stars,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>?;
        if (extractedData == null) {
          throw const HttpException('error');
        }
        try {
          final specialistIndex = _specialists
              .indexWhere((specialist) => specialist.id == specialistId);

          if (specialistIndex >= 0) {
            _specialists[specialistIndex].rating =
                extractedData['data']['stars'].toDouble();
            notifyListeners();
          }
        } catch (_) {}
        return extractedData['data']['stars'].toDouble();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchAndSetSpecialists(
    String token,
    int pageNum, {
    bool? isRefresh,
    int? fieldId,
    int? specializationId,
    double? startLat,
    double? startLng,
  }) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _specialists = [];
    }

    if (pages.contains(pageNum)) {
      return;
    }
    final latitude = startLat != null ? '&startLat=$startLat' : '';
    final longitude = startLng != null ? '&startLng=$startLng' : '';
    final field = fieldId != null ? '&fieldId=$fieldId' : '';
    final specialization =
        specializationId != null ? '&specializationId=$specializationId' : '';

    final offest = specialists.isNotEmpty ? specialists.length : 0;
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.specialistGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$specialization$field$latitude$longitude');

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

        List<Specialist> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var item in data) {
          if (item['id'] != null &&
              item['name'] != null &&
              item['phone'] != null &&
              item['email'] != null &&
              item['lat'] != null &&
              item['lng'] != null &&
              item['specializationNameAr'] != null &&
              item['specializationNameEn'] != null &&
              item['fieldNameAr'] != null &&
              item['fieldNameEn'] != null) {
            loadedItems.add(Specialist(
              id: item['id'],
              name: item['name'],
              phone: item['phone'],
              email: item['email'],
              profileImageUrl: item['profileImageUrl'],
              isOnline: item['onlineCount'] > 0,
              lat: item['lat'].toDouble(),
              lng: item['lng'].toDouble(),
              specializationNameAr: item['specializationNameAr'],
              specializationNameEn: item['specializationNameEn'],
              fieldNameAr: item['fieldNameAr'],
              fieldNameEn: item['fieldNameEn'],
              rating: item['rating'] != null ? item['rating'].toDouble() : 0,
              distance:
                  item['distance'] != null ? item['distance'].toDouble() : null,
            ));
          }
        }

        if (pages.contains(pageNum)) return;

        _specialists.addAll(loadedItems);
        pages.add(pageNum);

        notifyListeners();
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
