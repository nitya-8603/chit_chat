import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video }

enum MessageStatus { sent, read }

class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final Timestamp timestamp;
  final List<String> readBy;

  ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    required this.timestamp,
    required this.readBy,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      chatRoomId: data['chatRoomId'] as String,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      content: data['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: data['timestamp'] as Timestamp,
      readBy: List<String>.from(data['readBy']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'status': status,
      'timestamp': timestamp,
      'readBy': readBy,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    MessageStatus? status,
    Timestamp? timestamp,
    List<String>? readby,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      readBy: readBy ?? this.readBy,
    );
  }
}
