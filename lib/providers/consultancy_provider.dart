// ignore_for_file: use_rethrow_when_possible

import 'dart:convert';
import 'dart:io';

import '../models/apis.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/consultancy.dart';
import '../models/mesaage.dart';

class ConsultancyProvider with ChangeNotifier {
  List<Message> _messages = [];
  List<MessageFullData> _unseenMessages = [];
  List<Consultancy> _consultancies = [];

  List<int> pages = [];
  List<int> unseenMessagespages = [];
  List<int> consultanciesPages = [];
  List<int> pagesSearched = [];

  int _total = 0;
  int _consultanciesTotal = 0;
  int _unseenMessagesTotal = 0;

  final int _limit = 15;
  final int _messagesLimit = 100;

  int get limit => _limit;

  int get total => _total;

  int get consultanciesTotal => _consultanciesTotal;

  int get unseenMessagesTotal => _unseenMessagesTotal;

  List<Message> get messages {
    return [..._messages];
  }

  List<MessageFullData> get unseenMessages {
    return [..._unseenMessages];
  }

  List<Consultancy> get consultancies {
    return [..._consultancies];
  }

  clearUnseenMessages() {
    _unseenMessages = [];
    notifyListeners();
  }

  Future<int> getConsultancyByUserId(
    String token,
    int userId,
  ) async {
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.consultancyGet}/$userId');
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

        final data = extractedData['consultancy'] as Map<String, dynamic>?;

        return data == null ? -1 : data['id'];
      } else if (response.statusCode == 400) {
        return -1;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<Consultancy>> fetchAndSetConsultancy(String token, int pageNum,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      consultanciesPages = [];
      _consultancies = [];
    }
    if (pageNum == 0 && consultancies.isNotEmpty) {
      return consultancies;
    }

    if (consultanciesPages.contains(pageNum)) {
      return consultancies;
    }

    final offest = consultancies.length;
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.consultancyGet}?${APIs.limit}=$_limit&${APIs.offset}=$offest');
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

        _consultanciesTotal = extractedData['total'] ?? _consultanciesTotal;

        List<Consultancy> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var item in data) {
          if (item['id'] != null &&
              item['firstUserId'] != null &&
              item['secondUserId'] != null &&
              item['createdAt'] != null &&
              item['firstUserName'] != null &&
              item['firstUserPhone'] != null &&
              item['firstUserEmail'] != null &&
              item['secondUserName'] != null &&
              item['secondUserPhone'] != null &&
              item['secondUserEmail'] != null) {
            loadedItems.add(Consultancy(
              id: item['id'],
              firstUserId: item['firstUserId'],
              secondUserId: item['secondUserId'],
              createdAt: item['createdAt'],
              firstUserName: item['firstUserName'],
              firstUserPhone: item['firstUserPhone'],
              firstUserEmail: item['firstUserEmail'],
              secondUserName: item['secondUserName'],
              secondUserPhone: item['secondUserPhone'],
              secondUserEmail: item['secondUserEmail'],
              firstUserProfileImageUrl: item['firstUserProfileImageUrl'],
              secondUserProfileImageUrl: item['secondUserProfileImageUrl'],
            ));
          }
        }

        if (consultanciesPages.contains(pageNum)) {
          return consultancies;
        }

        _consultancies.addAll(loadedItems);

        consultanciesPages.add(pageNum);

        notifyListeners();

        return consultancies;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<List<MessageFullData>> fetchAndSetUnseenMessages(
      String token, int pageNum,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      unseenMessagespages = [];
      _unseenMessages = [];
    }
    if (pageNum == 0 && unseenMessages.isNotEmpty) {
      return unseenMessages;
    }

    if (unseenMessagespages.contains(pageNum)) {
      return unseenMessages;
    }

    final offest = unseenMessages.length;
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.unseenMessagesGet}?${APIs.limit}=$_messagesLimit&${APIs.offset}=$offest');
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

        _unseenMessagesTotal = extractedData['total'] ?? _unseenMessagesTotal;

        List<MessageFullData> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var item in data) {
          if (item['id'] != null &&
              item['senderId'] != null &&
              item['consultancyId'] != null &&
              item['createdAt'] != null &&
              item['content'] != null) {
            loadedItems.add(MessageFullData(
              id: item['id'],
              senderId: item['senderId'],
              consultancyId: item['consultancyId'],
              createdAt: item['createdAt'],
              seenAt: item['seenAt'],
              content: item['content'],
              name: item['name'],
              phone: item['phone'],
              email: item['email'],
              senderUserProfileImageUrl: item['senderUserProfileImageUrl'],
            ));
          }
        }

        if (unseenMessagespages.contains(pageNum)) {
          return _unseenMessages;
        }

        _unseenMessages.addAll(loadedItems);

        unseenMessagespages.add(pageNum);

        notifyListeners();

        return _unseenMessages;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<Message>> fetchAndSetMessages(
      String token, int pageNum, int consultancyId,
      {bool? isRefresh}) async {
    if (isRefresh != null && isRefresh) {
      pages = [];
      _messages = [];
    }
    if (pageNum == 0 && messages.isNotEmpty) {
      return messages;
    }

    if (pages.contains(pageNum)) {
      return messages;
    }

    final offest = messages.length;
    final consultancy = '&consultancyId=$consultancyId';
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.messagesGet}?${APIs.limit}=$_messagesLimit&${APIs.offset}=$offest$consultancy');
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

        List<Message> loadedItems = [];

        final data = extractedData['data'] as List<dynamic>;

        for (var item in data) {
          if (item['id'] != null &&
              item['senderId'] != null &&
              item['consultancyId'] != null &&
              item['createdAt'] != null &&
              item['content'] != null) {
            loadedItems.add(Message(
              id: item['id'],
              senderId: item['senderId'],
              consultancyId: item['consultancyId'],
              createdAt: item['createdAt'],
              seenAt: item['seenAt'],
              content: item['content'],
            ));
          }
        }

        if (pages.contains(pageNum)) {
          return messages;
        }

        _messages.addAll(loadedItems);

        pages.add(pageNum);

        notifyListeners();

        return messages;
      } else {
        throw const HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }
}
