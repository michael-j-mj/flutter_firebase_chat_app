import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Messages found."));
        }
        if (snapshot.hasData) {
          final loadedMessages = snapshot.data!.docs;
          return ListView.builder(
            itemCount: loadedMessages.length,
            itemBuilder: (context, index) {
              return Text(loadedMessages[index].data()["text"]);
            },
          );
        }
        return Center(
          child: Text("SOMETHING WENT WRONG..."),
        );
      },
    );
  }
}
