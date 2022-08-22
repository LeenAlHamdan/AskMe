// ignore_for_file: use_rethrow_when_possible

import 'dart:convert';

import '../models/http_exception.dart';
import '../models/answer.dart';
import '../models/apis.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class AnswerProvider with ChangeNotifier {
  List<Answer> _answers = [];

  int _total = 0;
  final int _limit = 6;

  List<int> pages = [];

  int get total => _total;

  List<Answer> get answers {
    return [..._answers];
  }

  int get pagesNum {
    return (_total / _limit).ceil();
  }

  Answer? findById(int id) {
    try {
      return _answers.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAnswer(int id, String token) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.answer}/$id');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 204) {
        _answers.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> answerRateUp(
    int answerId,
    String token,
  ) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.answer}/$answerId');

    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 201) {
        try {
          answers.firstWhere((element) => element.id == answerId).rating++;
          answers.firstWhere((element) => element.id == answerId).isRated =
              true;
          notifyListeners();
        } catch (_) {}
      } else if (response.statusCode == 400) {
        throw HttpException('duplicate');
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setAnswerAsSolution(
    int answerId,
    bool isSolution,
    String token,
  ) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.answerIsSolution}');

    try {
      final response = await http.patch(
        url,
        body: json.encode(
          {
            'answerId': answerId,
            'isSolution': isSolution,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        try {
          answers.firstWhere((element) => element.id == answerId).isSolution =
              isSolution;
          notifyListeners();
        } catch (_) {}
      } else if (response.statusCode == 400) {
        throw HttpException('duplicate');
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> answerRateDown(
    int answerId,
    String token,
  ) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.answer}/$answerId');

    try {
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 204) {
        try {
          answers.firstWhere((element) => element.id == answerId).rating--;
          answers.firstWhere((element) => element.id == answerId).isRated =
              false;
          notifyListeners();
        } catch (_) {}
      } else if (response.statusCode == 400) {
        throw HttpException('duplicate');
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> fetchAndSetAnswers(String token, int pageNum, int? userId,
      {bool? isRefresh, int? questionId, bool? isAdmin}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _answers = [];
    }
    if (pages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = answers.length;
    final question = questionId != null ? '&questionId=$questionId' : '';
    final user = userId != null ? '&userId=$userId' : '';

    if (offest == _total && _total != 0) {
      return;
    }
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.answerGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$question$user');
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
          throw HttpException('error');
        }

        _total = extractedData['total'] ?? _total;
        final data = extractedData['data'] as List<dynamic>;

        List<Answer> loadedAnswer = [];

        for (var answer in data) {
          if (answer['id'] != null &&
              answer['answer'] != null &&
              answer['createdAt'] != null &&
              answer['questionId'] != null &&
              answer['isSolution'] != null &&
              answer['questionSubject'] != null &&
              answer['userId'] != null &&
              answer['userPhone'] != null &&
              answer['userEmail'] != null &&
              answer['userName'] != null &&
              answer['rating'] != null) {
            loadedAnswer.add(Answer(
              id: answer['id'],
              answer: answer['answer'],
              createdAt: answer['createdAt'],
              questionId: answer['questionId'],
              isSolution: answer['isSolution'] > 0,
              isRated: answer['isRated'] != null && answer['isRated'] > 0,
              questionSubject: answer['questionSubject'],
              userId: answer['userId'],
              userPhone: answer['userPhone'],
              userEmail: answer['userEmail'],
              userName: answer['userName'],
              userProfileImageUrl: answer['userProfileImageUrl'],
              rating: answer['rating'].toDouble(),
            ));
          }
        }

        //      if (pages.contains(pageNum)) return;

        _answers.addAll(loadedAnswer);
        if (loadedAnswer.isEmpty) pages.remove(pageNum);

        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
