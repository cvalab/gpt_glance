import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../app_states.dart';
import '../chat_repository.dart';

class DrawerWidgets extends StatefulWidget {
  const DrawerWidgets({
    super.key,
    required this.parentHeight,
    required this.db,
    required this.toggleMenu,
  });
  final double parentHeight;
  final Database db;
  final VoidCallback toggleMenu;

  @override
  State<DrawerWidgets> createState() => _MyDrawerWidgets();
}

class _MyDrawerWidgets extends State<DrawerWidgets> {
  late ChatRepository chatRep;

  @override
  void initState() {
    super.initState();
    chatRep = ChatRepository(widget.db);
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chatList = await chatRep.getChats();
    Provider.of<LoadChats>(context, listen: false)
        .updateListOfChats(listOfChats: chatList.reversed.toList());
  }

  Future<void> _openSettings() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          title: Text(
            'Settings',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: Text(
            'Some settings',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _renameChat(int chatId, String currentName) async {
    final TextEditingController controller = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          title: Text('Rename Chat', style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          content: TextField(
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
            cursorColor: Theme.of(context).colorScheme.primary,
            controller: controller,
            decoration: InputDecoration(
              hintText: 'New chat name',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newName = controller.text;
                if (newName.isNotEmpty) {
                  await chatRep.renameChat(chatId, newName);
                  await _loadChats();
                  Provider.of<LoadChatMessages>(context,
                      listen: false)
                      .transferLoadingData(
                    chatId: chatId,
                    chatName: newName,
                    messages: [],
                    isRenamed: 1,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteChat(int chatId) async {
    await chatRep.deleteChat(chatId);
    Provider.of<LoadChatMessages>(context,
        listen: false)
        .transferLoadingData(
      chatId: 0,
      chatName: '',
      messages: [],
      isRenamed: 0,
    );
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadChats>(builder: (context, appState, child) {
      final listOfChats = appState.listOfChats;
      return Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        width: (MediaQuery.of(context).size.width * 0.85 <= 330
            ? MediaQuery.of(context).size.width * 0.85
            : 330),
        height: widget.parentHeight,
        child: Column(
          children: [
            // header + settings
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ChatGPT client',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_rounded),
                    style: ButtonStyle(
                      iconColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary),
                      iconSize: MaterialStateProperty.all(30),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 2,
              height: 0,
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width * 0.85 <= 320
                  ? MediaQuery.of(context).size.width * 0.85
                  : 320),
              child: TextButton(
                onPressed: () {
                  Provider.of<LoadChatMessages>(context, listen: false)
                      .transferLoadingData(
                    chatId: 0,
                    chatName: '',
                    messages: [],
                    isRenamed: 0,
                  );
                  widget.toggleMenu();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Add a new chat',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Flexible(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  widget.toggleMenu();
                                  Provider.of<LoadChatMessages>(context,
                                      listen: false)
                                      .transferLoadingData(
                                    chatId: listOfChats[index]['chat_id'],
                                    chatName: listOfChats[index]['name'],
                                    messages: [],
                                    isRenamed: listOfChats[index]['isRenamed'],
                                  );
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero),
                                  backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                  ),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  title: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          listOfChats[index]['name'],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontSize: 18,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          showModalBottomSheet<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Wrap(
                                                children: <Widget>[
                                                  ListTile(
                                                    leading: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary,),
                                                    title: Text('Rename Chat', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _renameChat(listOfChats[index]['chat_id'], listOfChats[index]['name']);
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.secondary,),
                                                    title: Text('Delete Chat', style: TextStyle(color: Theme.of(context).colorScheme.secondary),),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _deleteChat(listOfChats[index]['chat_id']);
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.more_vert_sharp),
                                        style: ButtonStyle(
                                          iconColor: MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                          iconSize:
                                          MaterialStateProperty.all(30),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (index < listOfChats.length - 1)
                                Divider(
                                  color: Theme.of(context).colorScheme.outline,
                                  thickness: 1,
                                  height: 10,
                                ),
                            ],
                          ),
                        );
                      },
                      childCount: listOfChats.length,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              thickness: 2,
              height: 0,
              indent: 10,
              endIndent: 10,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 80,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '    It will be smt',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
