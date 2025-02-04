import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputMenuWidgets extends StatefulWidget {
  const InputMenuWidgets({
    super.key,
    required this.parentWidth,
    required this.submitUserMessage,
  });

  final double parentWidth;
  final Future<void> Function(String) submitUserMessage;

  @override
  State<InputMenuWidgets> createState() => _InputMenuWidgets();
}

class _InputMenuWidgets extends State<InputMenuWidgets> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_textFieldWasUpdated);
  }

  @override
  void dispose() {
    _textEditingController
      ..removeListener(_textFieldWasUpdated)
      ..dispose();
    super.dispose();
  }

  void _textFieldWasUpdated() {
    setState(() {});
  }

  Future<void> _sendMessage() async {
    final message = _textEditingController.text.trim();
    _textEditingController.clear();
    if (message.isNotEmpty) {
      await widget.submitUserMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.enter): const SendIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SendIntent: SendAction(_textEditingController, _sendMessage),
        },
        child: Builder(builder: (context) {
          return Container(
            width: widget.parentWidth,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    cursorColor: Theme.of(context).colorScheme.primary,
                    controller: _textEditingController,
                    textInputAction: TextInputAction.newline,
                    maxLines: 6,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Your message',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                IconButton(
                  onPressed: Actions.handler<SendIntent>(context, const SendIntent()),
                  icon: const Icon(Icons.arrow_upward),
                  iconSize: 30,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                          (states) => _textEditingController.text.isNotEmpty
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                    shape: MaterialStateProperty.resolveWith(
                          (states) => const CircleBorder(),
                    ),
                    iconColor: MaterialStateProperty.resolveWith(
                          (states) => Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class SendIntent extends Intent {
  const SendIntent();
}

class SendAction extends Action<SendIntent> {
  SendAction(this.controller, this.sendMessage);

  final TextEditingController controller;
  final Future<void> Function() sendMessage;

  @override
  Object? invoke(covariant SendIntent intent) {
    if (controller.text.isNotEmpty) {
      sendMessage();
    }
    return null;
  }
}
