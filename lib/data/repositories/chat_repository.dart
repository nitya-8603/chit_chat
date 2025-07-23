import 'package:chit_chat/data/models/chat_message_model.dart';
import 'package:chit_chat/data/models/chat_room_model.dart';
import 'package:chit_chat/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends baseRepository {
  CollectionReference get _chatRooms =>
      firebaseFirestore.collection('chatRooms');

  CollectionReference getChatRoomMessages(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).collection('messages');
  }

  Future<ChatRoomModel> getOrCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join('_');
    final roomDoc = await _chatRooms.doc(roomId).get();

    if (roomDoc.exists) {
      return ChatRoomModel.fromFirestore(roomDoc);
    }
    final currentUserData =
        (await firebaseFirestore.collection('users').doc(currentUserId).get())
                .data()
            as Map<String, dynamic>;

    final otherUserData =
        (await firebaseFirestore.collection('users').doc(otherUserId).get())
                .data()
            as Map<String, dynamic>;

    final participantsName = {
      currentUserId: currentUserData['fullname']?.toString() ?? "",
      otherUserId: otherUserData['fullname']?.toString() ?? "",
    };

    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantsName: participantsName,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );
    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String chatRoomId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final batch = firebaseFirestore.batch();
    final messageRef = getChatRoomMessages(chatRoomId);
    final messageDoc = messageRef.doc();
    final message = ChatMessageModel(
      id: messageDoc.id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      timestamp: Timestamp.now(),
      readBy: [senderId],
    );
    batch.set(messageDoc, message.toMap());
    batch.update(_chatRooms.doc(chatRoomId), {
      'lastMessage': content,
      'lastMessageSenderId': senderId,
      'lastMessageTime': message.timestamp,
    });
  }
}
