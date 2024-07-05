import 'package:flutter/material.dart';

class LoadChatMessages extends ChangeNotifier {
  int _chatId = 0;
  String _chatName = '';
  List<Map<String, dynamic>> _messages = [];
  bool _isRenamed = false;

  int get chatId => _chatId;

  String get chatName => _chatName;

  List<Map<String, dynamic>> get messages => _messages;

  bool get isRenamed => _isRenamed;

  void transferLoadingData({
    required int chatId,
    required String chatName,
    required List<Map<String, dynamic>> messages,
    required int isRenamed,
  }) {
    _chatName = chatName;
    _chatId = chatId;
    _messages = messages;
    _isRenamed = (isRenamed == 0);
    notifyListeners();
  }
}

class LoadChats extends ChangeNotifier {
  List<Map<String, dynamic>> _listOfChats = [];

  List<Map<String, dynamic>> get listOfChats => _listOfChats;

  void updateListOfChats({required List<Map<String, dynamic>> listOfChats}) {
    _listOfChats = listOfChats;
    notifyListeners();
  }
}
