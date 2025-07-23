import 'package:chit_chat/data/models/chat_room_model.dart';
import 'package:chit_chat/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends baseRepository {
  CollectionReference get _chatRooms =>
      firebaseFirestore.collection('chatRooms');
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
}
