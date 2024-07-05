import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../api_service.dart';
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
  int chatId = 0;
  String chatName = '';
  bool isChatRenamed = false;

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
    isChatRenamed = appState.isRenamed;
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
      const String name = ' ';
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
          isRenamed: 0,
        );
        if (chatId != 0) {
          await _loadMessages();
        }
      }
    }

    final chatGptApiService =
        Provider.of<ChatGptApiService>(context, listen: false);
    try {
      final response = await chatGptApiService.sendMessage(message);
      await messageRep.addMessage(
          chatId: chatId, message: response, isBot: true);
      await _loadMessages();

      if (isChatRenamed) {
        final newChatNameResponse = await chatGptApiService.sendMessage(
            "Please suggest an interesting name for chat by it's first message. "
            "Don't forget about wight spaces between words, and write it as a small sentence. "
            'WRITE ONLY NEW CHAT NAME AND NOTHING MORE. Message: <<$message>>');
        final newChatName = newChatNameResponse.trim();
        await chatRep.renameChat(chatId, newChatName);
        chatName = newChatName;
        Provider.of<LoadChatMessages>(context, listen: false)
            .transferLoadingData(
          chatId: chatId,
          chatName: newChatName,
          messages: messages,
          isRenamed: 1,
        );

        final chatList = await chatRep.getChats();
        final List<Map<String, dynamic>> listOfChats =
            chatList.reversed.toList();
        Provider.of<LoadChats>(context, listen: false)
            .updateListOfChats(listOfChats: listOfChats);
      }
    } on Exception catch (e) {
      print('Error: $e');
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
                          return Align(
                            alignment: messages[index]['is_bot'] == 0
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left:
                                    messages[index]['is_bot'] == 0 ? 40.0 : 5.0,
                                right:
                                    messages[index]['is_bot'] == 1 ? 40.0 : 5.0,
                              ),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.85,
                                ),
                                child: Card(
                                  color: messages[index]['is_bot'] == 0
                                      ? Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .tertiaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          messages[index]['text'],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          messages[index]['time'],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
