import 'package:flutter/material.dart';

class AdminChatScreen extends StatelessWidget {
  const AdminChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Juan Dela Cruz",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),

              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _msgBubble("Good evening po!"),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: _msgBubble("Good evening! How may I help you?"),
                ),
              ],
            ),
          ),

          _inputBar(purple),
        ],
      ),
    );
  }

  Widget _msgBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    );
  }

  Widget _inputBar(Color purple) {
    return Container(
      padding: const EdgeInsets.all(12),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Message",
                filled: true,
                fillColor: const Color(0xFFF6F2FF),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 24,
            backgroundColor: purple,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
