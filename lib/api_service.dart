import 'package:dart_openai/dart_openai.dart';

class ChatGptApiService {
  ChatGptApiService({required String apiKey}) {
    OpenAI.apiKey = apiKey;
  }

  Future<String> sendMessage(String message) async {
    final response = await OpenAI.instance.chat.create(
      model: 'gpt-3.5-turbo',
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: message,
        ),
      ],
    );
    return response.choices.first.message.content;
  }
}
