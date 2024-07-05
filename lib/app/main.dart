import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../api_service.dart';
import '../app_states.dart';
import '../database.dart';
import '../env/env.dart';
import 'app_themes.dart';
import 'chat_widgets.dart';
import 'drawer_widgets.dart';

void main() async {
  if (isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  final database = await ChatDatabase.instance.database;

  const apiKey = Env.apiKey;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoadChats()),
        ChangeNotifierProvider(create: (_) => LoadChatMessages()),
        Provider(create: (_) => ChatGptApiService(apiKey: apiKey)),
      ],
      child: MyApp(db: database),
    ),
  );
}

bool isDesktop() {
  return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.db});
  final Database db;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDark;

  Future<void> changeAppTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = !isDark;
      prefs.setBool('isDark', isDark);
    });
  }

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
      },
    );
  }

  Future<bool>? loadSnapshot() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDark') ?? false;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.changeAppTheme,
    required this.isDark,
    required this.db,
  });

  final Database db;
  final VoidCallback changeAppTheme;
  final bool isDark;

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
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double topPadding = MediaQuery.of(context).viewPadding.top;

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
                  if (details.velocity.pixelsPerSecond.dx < 0 && _isMenuOpen) {
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
      ),
    );
  }
}
