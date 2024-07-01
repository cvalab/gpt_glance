import 'package:flutter/material.dart';

class LoadChatMessages extends ChangeNotifier {
  int _chatId = 0;
  String _chatName = '';

  int get chatId => _chatId;
  String get chatName => _chatName;

  void transferLoadingData({required int chatId, required String chatName}) {
    _chatName = chatName;
    _chatId = chatId;
    notifyListeners();
  }
}

class LoadChats extends ChangeNotifier{
  List<Map<String, dynamic>> _listOfChats = [];

  List<Map<String, dynamic>> get listOfChats => _listOfChats;

  void updateListOfChats({required List<Map<String, dynamic>> listOfChats}){
    _listOfChats = listOfChats;
    notifyListeners();
  }
}
