import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../app_states.dart';
import '../chat_repository.dart';
import '../message_repository.dart';
import 'app_bar_widgets.dart';
import 'input_menu_widgets.dart';

class ChatWidgets extends StatefulWidget {
  const ChatWidgets({
    super.key,
    required this.isDark,
    required this.changeAppTheme,
    required this.toggleMenuCallback,
    required this.bottomInset,
    required this.topPadding,
    required this.db,
  });

  final VoidCallback changeAppTheme;
  final bool isDark;
  final double bottomInset;
  final double topPadding;
  final VoidCallback toggleMenuCallback;
  final Database db;

  @override
  State<ChatWidgets> createState() => _ChatWidgets();
}

class _ChatWidgets extends State<ChatWidgets> {
  late ChatRepository chatRep;
  late MessageRepository messageRep;
  List<Map<String, dynamic>> messages = [];
  int chatId = -1;
  String chatName = '';

  @override
  void initState() {
    super.initState();
    messageRep = MessageRepository(widget.db);
    chatRep = ChatRepository(widget.db);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<LoadChatMessages>(context);
    chatId = appState.chatId;
    chatName = appState.chatName;
    messages = appState.messages;
    if (chatId != 0) {
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    final messageList = await messageRep.getMessages(chatId);
    setState(() {
      messages = messageList;
    });
  }

  Future<void> submitUserMessage(String message) async {
    if (chatName != '') {
      await messageRep.addMessage(
          chatId: chatId, message: message, isBot: false);
      await _loadMessages();
    } else {
      const String name = '---test name---';
      final int id = await chatRep.createChat(name);
      await messageRep.addMessage(chatId: id, message: message, isBot: false);
      final chatList = await chatRep.getChats();
      final List<Map<String, dynamic>> listOfChats = chatList.reversed.toList();
      if (mounted) {
        Provider.of<LoadChats>(context, listen: false)
            .updateListOfChats(listOfChats: listOfChats);
        Provider.of<LoadChatMessages>(context, listen: false)
            .transferLoadingData(
          chatId: id,
          chatName: name,
          messages: messages,
        );
        if (chatId != 0) {
          await _loadMessages();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadChatMessages>(
      builder: (context, appState, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              widget.bottomInset -
              widget.topPadding,
          child: Column(
            children: [
              AppBarWidget(
                isDark: widget.isDark,
                changeAppTheme: widget.changeAppTheme,
                toggleMenuCallback: widget.toggleMenuCallback,
                chatName: chatName,
              ),
              Flexible(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ListTile(
                            title: Text(
                              'You',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                messages[index]['text'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            minVerticalPadding: 10,
                          );
                        },
                        childCount: messages.length,
                      ),
                    ),
                  ],
                ),
              ),
              InputMenuWidgets(
                parentWidth: MediaQuery.of(context).size.width,
                submitUserMessage: submitUserMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}
