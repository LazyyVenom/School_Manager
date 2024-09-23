import 'package:cloud_firestore/cloud_firestore.dart';

Stream<int> getNewMessageCountStream(String userEmail) async* {
    Set<String> uniqueSenders = {};

    // Listen for changes in the chat_rooms collection
    await for (var snapshot
        in FirebaseFirestore.instance.collection('chat_rooms').snapshots()) {
      uniqueSenders.clear(); // Clear the previous senders

      for (var doc in snapshot.docs) {
        String chatRoomId = doc.id;

        if (chatRoomId.contains(userEmail)) {
          // Access the messages array in this chat room document
          var messages = doc['messages'] as List<dynamic>?;

          if (messages != null && messages.isNotEmpty) {
            var lastMessage = messages.last;

            if (lastMessage['is_new'] == true &&
                lastMessage['receiverEmail'] == userEmail) {
              uniqueSenders.add(lastMessage['senderEmail']);
            }
          }
        }
      }

      // Yield the count of unique senders
      yield uniqueSenders.length;
    }
  }