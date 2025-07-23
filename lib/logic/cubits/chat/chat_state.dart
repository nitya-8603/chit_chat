import 'package:equatable/equatable.dart';

enum chatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final chatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;

  const ChatState({
    this.status = chatStatus.initial,
    this.error,
    this.receiverId,
    this.chatRoomId,
  });
  ChatState copyWith({
    chatStatus? status,
    String? error,
    String? receiverId,
    String? chatRoomId,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error ?? this.error,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [status, error, receiverId, chatRoomId];
}
