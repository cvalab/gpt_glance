import 'package:flutter/material.dart';

class LoadChatMessages extends ChangeNotifier {
  int _chatId = 0;
  String _chatName = '';
  List<Map<String, dynamic>> _messages = [];

  int get chatId => _chatId;

  String get chatName => _chatName;

  List<Map<String, dynamic>> get messages => _messages;

  void transferLoadingData({
    required int chatId,
    required String chatName,
    required List<Map<String, dynamic>> messages,
  }) {
    _chatName = chatName;
    _chatId = chatId;
    _messages = messages;
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
