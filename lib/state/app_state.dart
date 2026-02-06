import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../data/mock_users.dart';
import '../models/ice_user.dart';

class AppState extends ChangeNotifier {
  static const _kPrefsStarted = 'started';
  static const _kPrefsSelectedUser = 'selectedUser';
  static const _kPrefsLastChatDraft = 'lastChatDraft';

  final List<IceUser> users = List<IceUser>.from(MockUsers);

  bool started = false;
  IceUser? selected;
  String chatDraft = '';

  bool isOnline = true;

  IceUser get me => users.firstWhere((u) => u.isMe);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    started = prefs.getBool(_kPrefsStarted) ?? false;

    final sel = prefs.getString(_kPrefsSelectedUser);
    if (sel != null) {
      final obj = jsonDecode(sel) as Map<String, dynamic>;
      selected = users.firstWhere((u) => u.id == (obj['id'] as int), orElse: () => users.first);
      if (selected?.isMe == true) selected = null;
    }

    chatDraft = prefs.getString(_kPrefsLastChatDraft) ?? '';

    // Online/offline listener
    final connectivity = Connectivity();
    final res = await connectivity.checkConnectivity();
    isOnline = res != ConnectivityResult.none;
    connectivity.onConnectivityChanged.listen((r) {
      final online = r != ConnectivityResult.none;
      if (online != isOnline) {
        isOnline = online;
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<void> start() async {
    started = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefsStarted, true);
  }

  Future<void> selectUser(IceUser? user) async {
    selected = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_kPrefsSelectedUser);
    } else {
      await prefs.setString(_kPrefsSelectedUser, jsonEncode(user.toJson()));
    }
  }

  Future<void> setChatDraft(String val) async {
    chatDraft = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsLastChatDraft, val);
  }
}
