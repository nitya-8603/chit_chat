import 'package:chit_chat/data/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum chatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final chatStatus status;
  final String? error;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessageModel> messages;
  final bool isReceiverTyping;
  final bool isReceiverOnline;
  final Timestamp? receiverLastSeen;
  final bool hasMoreMessages;
  final bool isLoadingMore;
  final bool isUserBlocked;
  final bool amIBlocked;

  const ChatState({
    this.isReceiverTyping = false,
    this.isReceiverOnline = false,
    this.receiverLastSeen,
    this.hasMoreMessages = false,
    this.isLoadingMore = false,
    this.isUserBlocked = false,
    this.amIBlocked = false,
    this.status = chatStatus.initial,
    this.error,
    this.messages = const [],
    this.receiverId,
    this.chatRoomId,
  });
  ChatState copyWith({
    chatStatus? status,
    String? error,
    List<ChatMessageModel>? messages,
    String? receiverId,
    String? chatRoomId,
    bool? isReceiverTyping,
    bool? isReceiverOnline,
    Timestamp? receiverLastSeen,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    bool? isUserBlocked,
    bool? amIBlocked,
  }) {
    return ChatState(
      status: status ?? this.status,
      error: error ?? this.error,
      messages: messages ?? this.messages,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isReceiverTyping: isReceiverTyping ?? this.isReceiverTyping,
      isReceiverOnline: isReceiverOnline ?? this.isReceiverOnline,
      receiverLastSeen: receiverLastSeen ?? this.receiverLastSeen,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.hasMoreMessages,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      amIBlocked: amIBlocked ?? this.amIBlocked,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
    status,
    error,
    receiverId,
    messages,
    chatRoomId,
    isReceiverTyping,
    isReceiverOnline,
    receiverLastSeen,
    hasMoreMessages,
    isUserBlocked,
    amIBlocked,
    isLoadingMore,
  ];
}
