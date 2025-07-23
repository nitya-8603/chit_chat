import 'package:chit_chat/data/repositories/chat_repository.dart';
import 'package:chit_chat/logic/cubits/chat/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;

  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  }) : _chatRepository = chatRepository,
       super(const ChatState());

  void enterChat(String receiverId) async {
    emit(state.copyWith(status: chatStatus.loading));
    try {
      final chatRoom = await _chatRepository.getOrCreateChatRoom(
        currentUserId,
        receiverId,
      );
      emit(
        state.copyWith(
          chatRoomId: chatRoom.id,
          receiverId: receiverId,
          status: chatStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: chatStatus.error,
          error: "Failed to create Chat Room $e",
        ),
      );
    }
  }
}
