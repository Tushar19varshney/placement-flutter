import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:placement/resources/endpoints.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:placement/resources/strings.dart';

class AuthService {
  static final  AuthService _auth = AuthService.internal();

  factory AuthService() => _auth;

  AuthService.internal() {
    initState();
  }

  void initState() { 
    _openEncryptedBox();
  }
  var _box;
  Future<int> signInWithEmailPassword(Map<String,String> data) async {
    var jsonData;
    try{
      print(EndPoints.HOST+EndPoints.LOGIN);
      var res = await http.post(
        EndPoints.HOST+EndPoints.LOGIN,
        body: data
      );
      if(res.statusCode == 200) {
        jsonData = json.decode(res.body);
        _encrypt(jsonData["access"], jsonData["refresh"]);
        print(jsonData["access"]);
        print(jsonData["refresh"]);
        return 0;
      }
      return null;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  bool authStateListener() {
    return !(_box.get('token', defaultValue: '') == '');
  }

  dynamic logOut() {
    _box.delete(Strings.AUTH_BOX);
    return "Logged Out";
  }

  _encrypt(String access, String refresh) {
    _box.put('access', access);
    _box.put('refresh', refresh);
    print("Saved!!");
  }

  _openEncryptedBox() async {
      await Hive.initFlutter();
      await Hive.openBox(Strings.AUTH_BOX);
      _box = Hive.box(Strings.AUTH_BOX);
  }
}