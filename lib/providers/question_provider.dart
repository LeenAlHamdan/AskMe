// ignore_for_file: use_rethrow_when_possible

import 'dart:convert';

import '../models/http_exception.dart';
import '../models/question.dart';
import '../models/apis.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> _searched = [];
  List<Question> _favoriteQuestions = [];

  int _total = 0;
  int _totalFav = 0;
  int _totalSearched = 0;

  final int _limit = 6;

  List<int> pages = [];
  List<int> pagesSearched = [];
  List<int> pagesFav = [];

  int get total => _total;
  int get favTotal => _totalFav;

  List<Question> get questions {
    return [..._questions];
  }

  List<Question> get searched {
    return [..._searched];
  }

  List<Question> get favoriteQuestions {
    return [..._favoriteQuestions];
  }

  int get pagesNum {
    return (_total / _limit).ceil();
  }

  Question? findById(int id) {
    try {
      return _questions.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteQuestion(int id, String token) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.question}/$id');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 204) {
        _questions.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateQuestion(
    int id,
    String token, {
    String? subject,
    int? fieldId,
    String? question,
  }) async {
    if (subject == null && question == null && fieldId == null) {
      return;
    }
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.question}/$id');
    try {
      final String b = json.encode(
        {
          if (question != null) 'question': question,
          if (subject != null) 'subject': subject,
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
        /*    final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        final colo = extractedData['data']['updatedData'];
        final fieldIndex = questions.indexWhere((field) => field.id == id);
 */
        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> addQuestion(
    String subject,
    int fieldId,
    String question,
    String token,
  ) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.question}');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'subject': subject,
            'question': question,
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
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> answerQuestion(
    String answer,
    int questionId,
    String token,
  ) async {
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.question}/$questionId');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'answer': answer,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 201) {
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> fetchAndSetQuestions(
    String token,
    int pageNum, {
    bool? isRefresh,
    int? fieldId,
  }) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _questions = [];
    }
    if (pages.contains(pageNum)) {
      return;
    }

    pages.add(pageNum);

    final offest = questions.length;
    final field = fieldId != null ? '&fieldId=$fieldId' : '';

    if (offest == _total && _total != 0) {
      return;
    }
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.questionGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$field');
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

        List<Question> loadedQuestions = [];

        for (var question in data) {
          if (question['id'] != null && question['subject'] != null) {
            loadedQuestions.add(Question(
              id: question['id'],
              subject: question['subject'],
              question: question['question'],
              createdAt: question['createdAt'],
              fieldNameAr: question['fieldNameAr'],
              fieldNameEn: question['fieldNameEn'],
              userName: question['userName'],
              userProfileImageUrl: question['userProfileImageUrl'],
            ));
          }
        }

        //      if (pages.contains(pageNum)) return;

        _questions.addAll(loadedQuestions);
        if (loadedQuestions.isEmpty) pages.remove(pageNum);

        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> toggleFavoriteStatus(
      String token, QuestionFullData question) async {
    final oldStatus = question.isFavorite;
    question.isFavorite = !question.isFavorite;

    notifyListeners();

    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.userFavorites}?${APIs.questionId}=${question.id}');

    try {
      final http.Response response;
      if (question.isFavorite) {
        response = await http.post(url, headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

        if (response.statusCode == 201) {
          if (!question.isFavorite) {
            _favoriteQuestions
                .removeWhere((element) => element.id == question.id);
          }
          notifyListeners();
        } else {
          question.isFavorite = oldStatus;
        }
      } else {
        response = await http.patch(url, headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

        if (response.statusCode == 200) {
          if (!question.isFavorite) {
            _favoriteQuestions
                .removeWhere((element) => element.id == question.id);
          }

          notifyListeners();
        } else {
          question.isFavorite = oldStatus;
        }
      }

      notifyListeners();
    } catch (error) {
      question.isFavorite = oldStatus;
    }
  }

  Future<QuestionFullData> fetchAndSetQuestionData(
    String token,
    int id,
    int? userId,
  ) async {
    final user = userId != null ? '?userId=$userId' : '';
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.questionGet}/$id$user');

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

        final question = extractedData;

        if (question['id'] != null &&
            question['userId'] != null &&
            question['userName'] != null &&
            question['userPhone'] != null &&
            question['userEmail'] != null &&
            question['subject'] != null &&
            question['question'] != null &&
            question['createdAt'] != null &&
            question['fieldNameAr'] != null &&
            question['fieldNameEn'] != null) {
          return QuestionFullData(
            id: question['id'],
            userId: question['userId'],
            userName: question['userName'],
            userEmail: question['userEmail'],
            userPhone: question['userPhone'],
            userProfileImageUrl: question['userProfileImageUrl'],
            subject: question['subject'],
            question: question['question'],
            createdAt: question['createdAt'],
            fieldId: question['fieldId'],
            fieldNameAr: question['fieldNameAr'],
            fieldNameEn: question['fieldNameEn'],
            isFavorite: question['isFavorite'] != null
                ? question['isFavorite'] != 'null'
                    ? true
                    : false
                : false,
          );
        } else {
          throw HttpException('error');
        }

        //      if (pages.contains(pageNum)) return;

      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> search(
    String token,
    String name,
    int pageNum, {
    bool? isRefresh,
    int? fieldId,
  }) async {
    if (isRefresh != null && isRefresh) {
      pagesSearched = [];

      _searched = [];
    }
    if (searched.isEmpty) {
      pagesSearched = [];
    }

    if (searched.isNotEmpty && pagesSearched.contains(pageNum)) {
      return;
    }

    final search = name != '' ? '&subject=$name' : '';
    final offest = searched.length;
    final field = fieldId != null ? '&fieldId=$fieldId' : '';

    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.questionGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$field$search');

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

        List<Question> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;
        _totalSearched = extractedData['total'] ?? _totalSearched;

        for (var question in data) {
          if (question['id'] != null && question['subject'] != null) {
            loadedItems.add(Question(
              id: question['id'],
              subject: question['subject'],
              question: question['question'],
              createdAt: question['createdAt'],
              fieldNameAr: question['fieldNameAr'],
              fieldNameEn: question['fieldNameEn'],
              userName: question['userName'],
              userProfileImageUrl: question['userProfileImageUrl'],
            ));
          }
        }

        if (pagesSearched.contains(pageNum)) return;

        _searched.addAll(loadedItems);
        notifyListeners();

        if (loadedItems.isNotEmpty) {
          pagesSearched.add(pageNum);
        }
        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> getFavoriteQuestions(int pageNum, String token, int? userId,
      {int? fieldId, bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pagesFav = [];

      _favoriteQuestions = [];
    }

    if (pagesFav.isNotEmpty && pagesFav.contains(pageNum)) {
      return;
    }

    pagesFav.add(pageNum);

    final offest = favoriteQuestions.length;

    if (offest == _totalFav && _totalFav != 0) {
      return;
    }

    const favorite = '&isFavorite=${true}';
    final field = fieldId != null ? '&fieldId=$fieldId' : '';
    final user = userId != null ? '&userId=$userId' : '';

    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.questionGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest$field$favorite$user');

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

        _totalFav = extractedData['total'] ?? _totalFav;

        List<Question> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var question in data) {
          if (question['id'] != null && question['subject'] != null) {
            loadedItems.add(Question(
              id: question['id'],
              subject: question['subject'],
              question: question['question'],
              createdAt: question['createdAt'],
              fieldNameAr: question['fieldNameAr'],
              fieldNameEn: question['fieldNameEn'],
              userName: question['userName'],
              userProfileImageUrl: question['userProfileImageUrl'],
            ));
          }
        }

        if (loadedItems.isNotEmpty) {
          _favoriteQuestions.addAll(loadedItems);
        } else {
          pagesFav.remove(pageNum);
        }

        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
