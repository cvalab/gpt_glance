import 'package:flutter/material.dart';
import 'dart:core';
import 'package:sqflite/sqflite.dart';
import 'package:chat_gpt_client_app/chat_repository.dart';
import 'package:provider/provider.dart';
import 'package:chat_gpt_client_app/app_states.dart';

class DrawerWidgets extends StatefulWidget {
  final double parentHeight;
  final Database db;
  final VoidCallback toggleMenu;

  const DrawerWidgets({
    super.key,
    required this.parentHeight,
    required this.db,
    required this.toggleMenu,
  });

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

  Future<void> _addChat() async {
    final chatNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Chat'),
          content: TextField(
            controller: chatNameController,
            decoration: const InputDecoration(hintText: 'Chat Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (chatNameController.text.isNotEmpty) {
                  String chatName = chatNameController.text;
                  Navigator.of(context).pop();
                  await chatRep.createChat(chatName);
                  _loadChats();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
            //header + settings
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ChatGPT-4 client',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
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
                  Provider.of<LoadChatMessages>(context, listen: false).transferLoadingData(
                    chatId: -1,
                    chatName: '',
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      "Add a new chat",
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
                                      vertical: 0, horizontal: 10),
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
                                        onPressed: () {},
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
