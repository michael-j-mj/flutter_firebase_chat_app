import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    String newMessage = _textController.text;
    debugPrint('new message ' + newMessage);
    if (newMessage.trim().isEmpty) {
      return;
    }
    //send to firebase
    final user = FirebaseAuth.instance.currentUser!;
    FocusScope.of(context).unfocus();
    _textController.text = '';
    final userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    debugPrint(userInfo.data()!.keys.toString());
    FirebaseFirestore.instance.collection('chat').add({
      'text': newMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userInfo.data()?["username"] ?? "",
      'userImage': userInfo.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15, left: 15, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _textController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: const InputDecoration(labelText: "Send a Message"),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submitMessage,
              icon: const Icon(Icons.send)),
        ],
      ),
    );
  }
}
