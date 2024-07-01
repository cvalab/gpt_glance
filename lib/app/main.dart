import 'dart:io';
import 'package:chat_gpt_client_app/app_states.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_themes.dart';
import 'chat_widgets.dart';
import 'drawer_widgets.dart';

import 'package:chat_gpt_client_app/database.dart';
import 'package:provider/provider.dart';

void main() async {
  if (isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  final database = await ChatDatabase.instance.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadChatMessages()),
        ChangeNotifierProvider(create: (_) => LoadChats()),
      ],
      child: MyApp(
        db: database,
      ),
    ),
  );
}

bool isDesktop() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

class MyApp extends StatefulWidget {
  final Database db;

  const MyApp({super.key, required this.db});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDark;

  void changeAppTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = !isDark;
      prefs.setBool('isDark', isDark);
    });
  }

  // bool appTheme = true;
  // void changeAppTheme() {
  //   setState(() {
  //     appTheme = appTheme == true ? false : true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: loadSnapshot(),
        builder: (context, snapshot) {
          isDark = snapshot.data ?? false;
          return MaterialApp(
            title: 'GPT client',
            theme: ThemeData(
              colorScheme: AppThemes.getColorScheme(appTheme: isDark),
              useMaterial3: true,
            ),
            home: HomePage(
              changeAppTheme: changeAppTheme,
              isDark: isDark,
              db: widget.db,
            ),
          );
        });
  }

  Future<bool>? loadSnapshot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDark') ?? false;
  }
}

class HomePage extends StatefulWidget {
  final Database db;
  final VoidCallback changeAppTheme;
  final bool isDark;

  const HomePage(
      {super.key,
      required this.changeAppTheme,
      required this.isDark,
      required this.db});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMenuOpen = false;

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    double topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: _isMenuOpen
                    ? (MediaQuery.of(context).size.width * 0.87 <= 350
                        ? MediaQuery.of(context).size.width * 0.87
                        : 350)
                    : 0,
                child: ChatWidgets(
                  changeAppTheme: widget.changeAppTheme,
                  isDark: widget.isDark,
                  toggleMenuCallback: _toggleMenu,
                  bottomInset: bottomInset,
                  topPadding: topPadding,
                  db: widget.db,
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: _isMenuOpen
                    ? 0
                    : -1 *
                        (MediaQuery.of(context).size.width * 0.87 <= 350
                            ? MediaQuery.of(context).size.width * 0.87
                            : 350),
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < 0 &&
                        _isMenuOpen) {
                      _toggleMenu();
                    }
                  },
                  child: DrawerWidgets(
                    parentHeight: MediaQuery.of(context).size.height,
                    db: widget.db,
                    toggleMenu: _toggleMenu,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
