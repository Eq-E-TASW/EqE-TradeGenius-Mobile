import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trading_app/pages/CustomAppBar.dart';
import 'package:trading_app/config.dart'; // Para apiBaseUrl

class ChatbotPage extends StatefulWidget {
  static const String routename = '/chatbot';

  const ChatbotPage({super.key});

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages(); // Carga los mensajes iniciales al iniciar la página
  }

  Future<void> fetchMessages() async {
    final url = '$apiBaseUrl/api/chatbot/messages';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // Decodificar en UTF-8
        setState(() {
          _messages = List<Map<String, String>>.from(
            data['messages'].map<Map<String, String>>((msg) => {
              'sender': msg['sender'].toString(),
              'message': msg['message'].toString(),
            }),
          );
        });
      } else {
        print('Error al obtener mensajes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener mensajes: $e');
    }
  }

  Future<void> sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    // Añade el mensaje del usuario localmente
    setState(() {
      _messages.add({'sender': 'User', 'message': message});
    });

    _controller.clear();

    final url = '$apiBaseUrl/api/chatbot/send-message';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)); // Decodificar en UTF-8
        setState(() {
          _messages = List<Map<String, String>>.from(
            data['messages'].map<Map<String, String>>((msg) => {
              'sender': msg['sender'].toString(),
              'message': msg['message'].toString(),
            }),
          );
        });
      } else {
        print('Error al enviar mensaje: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al enviar mensaje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'TRADEGENIUS'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Área de chat
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Align(
                      alignment: msg['sender'] == 'User'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ChatBubble(msg),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Campo de entrada
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF20344C)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Map<String, String> msg;
  const ChatBubble(this.msg, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUser = msg['sender'] == 'User';

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: isUser ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        msg['message']!,
        style: TextStyle(fontSize: 16, color: isUser ? Colors.white : Colors.black),
      ),
    );
  }
}
