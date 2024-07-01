import 'dart:core';
import 'package:flutter/material.dart';

class AppBarWidget extends StatefulWidget {

  const AppBarWidget({
    super.key,
    required this.isDark,
    required this.changeAppTheme,
    required this.toggleMenuCallback,
    required this.chatName,
  });
  final VoidCallback changeAppTheme;
  final bool isDark;
  final VoidCallback toggleMenuCallback;
  final String chatName;

  @override
  State<AppBarWidget> createState() => _AppBarState();
}

class _AppBarState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: widget.toggleMenuCallback,
            color: Theme.of(context).colorScheme.primary,
            iconSize: 31,
            icon: Icon(
              Icons.menu_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Flexible(
            child: Text(
                widget.chatName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.changeAppTheme,
            icon: widget.isDark
                ? const Icon(Icons.dark_mode_outlined)
                : const Icon(Icons.light_mode_outlined),
            style: ButtonStyle(
              iconColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.primary),
              iconSize: MaterialStateProperty.all(30),
            ),
          ),
        ],
      ),
    );
  }
}
