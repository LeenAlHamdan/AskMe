// ignore_for_file: use_rethrow_when_possible

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../models/http_exception.dart';
import '../models/apis.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/user.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _token = '';
  int? _userId;

  List<int> pages = [];
  final List<User> _specialists = [];

  //final int _limit = 10;

  final int _total = 0;

  int get total => _total;

  List<User> get designers => _specialists;

  int userRole = 1;
  int specialistRole = 2;
  int adminRole = 3;

  User _currentUser = User(
    id: -1,
    email: '',
    fullName: '',
    password: '',
    profileImageUrl: null,
    phone: '',
    role: 1, //userRole
    isSpecialist: false,
  );

  int? get userId {
    return _userId;
  }

  User get currentUser {
    return _currentUser;
  }

  String get token {
    return _token;
  }

  void signOut() async {
    _currentUser = User(
      id: -1,
      email: '',
      password: '',
      fullName: '',
      phone: '',
      profileImageUrl: null,
      role: userRole,
      isSpecialist: false,
    );
    _token = '';
    _userId = -1;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  bool userIsSignd() {
    return _token != '';
  }

  bool isAdmin() {
    return _currentUser.role == adminRole;
  }

  bool isUser() {
    return _currentUser.role == userRole;
  }

  bool isSpecialist() {
    return _currentUser.isSpecialist;
  }

  Future<void> addUser(User user) async {
    _currentUser = User(
      id: _userId!,
      email: user.email,
      password: user.password,
      fullName: user.fullName,
      profileImageUrl: user.profileImageUrl,
      phone: user.phone,
      role: user.role,
      isSpecialist: user.isSpecialist,
    );
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.signIn}');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'emailOrPhone': email,
            'password': password,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 477) {
        throw HttpException('EMAIL_NOT_FOUND');
      } else if (response.statusCode == 401) {
        throw HttpException('INVALID_PASSWORD');
      } else if (response.statusCode >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['token'];
      _userId = responseData['user']['id'];
      _currentUser = User(
        email: responseData['user']['email'],
        fullName: responseData['user']['name'],
        id: _userId!,
        password: password,
        profileImageUrl: responseData['user']['profileImageUrl'],
        phone: responseData['user']['phone'],
        role: responseData['user']['role'],
        isSpecialist: responseData['user']['isSpecialist'] ?? false,
      );

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'fullName': _currentUser.fullName,
          'role': _currentUser.role,
          'email': _currentUser.email,
          'profileImageUrl': _currentUser.profileImageUrl,
          'phone': _currentUser.phone,
          'isSpecialist': _currentUser.isSpecialist,
        },
      );
      prefs.setString('userData', userData);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    var url = Uri.parse('${APIs.host}/${APIs.environment}/${APIs.signUp}');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'name': name,
            'phone': phone,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        _token = responseData['token'];
        _userId = responseData['user']['id'];
        _currentUser = User(
          email: responseData['user']['email'],
          fullName: responseData['user']['name'],
          id: _userId!,
          password: password,
          phone: responseData['user']['phone'],
          profileImageUrl: responseData['user']['profileImageUrl'],
          role: responseData['user']['role'],
          isSpecialist: responseData['user']['isSpecialist'] ?? false,
        );

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId,
            'fullName': _currentUser.fullName,
            'role': _currentUser.role,
            'email': _currentUser.email,
            'profileImageUrl': _currentUser.profileImageUrl,
            'phone': _currentUser.phone,
            'isSpecialist': _currentUser.isSpecialist,
          },
        );
        prefs.setString('userData', userData);

        notifyListeners();
      } else if (response.statusCode == 412) {
        throw HttpException('EMAIL_OR_PHONE_EXISTS');
      } else if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      } else if (response.statusCode >= 400) {
        throw HttpException('ERROR');
      } else {
        throw HttpException('ERROR');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> restPasswordWithCode(
      String email, String newPassword, String code) async {
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.restPasswordWithCode}?code=$code');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'emailOrPhone': email,
            'newPassword': newPassword,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 477) {
        throw HttpException('EMAIL_NOT_FOUND');
      } else if (response.statusCode == 400) {
        throw HttpException('INVAILD_CODE');
      } else if (response.statusCode >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    var url =
        Uri.parse('${APIs.host}/${APIs.environment}/${APIs.changePassword}');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'oldPassword': oldPassword,
            'newPassword': newPassword,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 401) {
        throw HttpException('INVALID_PASSWORD');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> requestPasswordCode(
    String email,
  ) async {
    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.requestPasswordCode}');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'emailOrPhone': email,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 477) {
        throw HttpException('EMAIL_NOT_FOUND');
      } else if (response.statusCode >= 400) {
        throw HttpException('ERROR');
      }

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(File file) async {
    final prefs = await SharedPreferences.getInstance();

    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.user}/${APIs.profileImage}');

    try {
      var request = http.MultipartRequest('PATCH', url)
        ..files.add(await http.MultipartFile.fromPath('profileImage', file.path,
            contentType: MediaType('application', 'x-tar')))
        ..headers.addAll({
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $_token',
        });

      http.Response response =
          await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final user = json.decode(response.body) as Map<String, dynamic>;

        _currentUser.profileImageUrl = user['url'];

        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId!,
            'fullName': _currentUser.fullName,
            'role': _currentUser.role,
            'email': _currentUser.email,
            'profileImageUrl': _currentUser.profileImageUrl,
            'phone': _currentUser.phone,
            'isSpecialist': _currentUser.isSpecialist,
          },
        );
        prefs.setString('userData', userData);

        notifyListeners();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();

    var url = Uri.parse(
        '${APIs.host}/${APIs.environment}/${APIs.user}/${APIs.profileData}');

    String email = _currentUser.email;
    String? profileImageUrl = _currentUser.profileImageUrl;
    int role = _currentUser.role;
    String fullName = _currentUser.fullName;
    String phone = _currentUser.phone;
    var isSpecialist = _currentUser.isSpecialist;
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        email = responseData['email'] ?? email;
        profileImageUrl = responseData['profileImageUrl'] ?? profileImageUrl;
        role = responseData['role'] ?? role;
        fullName = responseData['name'] ?? fullName;
        phone = responseData['phone'] ?? phone;
        isSpecialist = responseData['isSpecialist'] ?? isSpecialist;

        final userData = json.encode(
          {
            'token': _token,
            'userId': _userId!,
            'fullName': _currentUser.fullName,
            'role': _currentUser.role,
            'email': _currentUser.email,
            'profileImageUrl': _currentUser.profileImageUrl,
            'phone': _currentUser.phone,
            'isSpecialist': _currentUser.isSpecialist,
          },
        );
        prefs.setString('userData', userData);

        _currentUser = User(
            email: email,
            fullName: fullName,
            profileImageUrl: profileImageUrl,
            id: _userId!,
            role: role,
            phone: phone,
            isSpecialist: isSpecialist,
            password: '');

        notifyListeners();
      } else if (response.statusCode == 401) {
        signOut();
      } else {
        throw HttpException('error');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      _token = '';
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    String email = extractedUserData['email'];
    String fullName = extractedUserData['fullName'];
    int role = extractedUserData['role'].toString() == 'SuperAdmin'
        ? adminRole
        : extractedUserData['role'].toString() == 'User'
            ? userRole
            : extractedUserData['role'];
    String profileImageUrl = extractedUserData['profileImageUrl'];
    var phone = extractedUserData['phone'] ?? '';
    var isSpecialist = extractedUserData['isSpecialist'] ?? false;

    _currentUser = User(
        email: email,
        fullName: fullName,
        profileImageUrl: profileImageUrl,
        id: _userId!,
        role: role,
        phone: phone,
        isSpecialist: isSpecialist,
        password: '');

    notifyListeners();
    //await fetchProfile();

    return true;
  }
}
