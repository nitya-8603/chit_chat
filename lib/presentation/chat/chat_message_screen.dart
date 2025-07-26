import 'package:chit_chat/data/models/chat_message_model.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/logic/cubits/chat/chat_cubit.dart';
import 'package:chit_chat/logic/cubits/chat/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverName;
  final String receiverId;
  const ChatMessageScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit;
  bool _isComposing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChanged);
  }

  Future<void> handleSendMessage() async {
    final messageText = messageController.text.trim();
    messageController.clear();
    await _chatCubit.sendMessage(
      content: messageText,
      receiverId: widget.receiverId,
    );
  }

  void _onTextChanged() {
    final isComposing = messageController.text.isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
    if (isComposing) {
      _chatCubit.startTyping();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
    _chatCubit.leaveChat();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(widget.receiverName[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName),
                BlocBuilder<ChatCubit, ChatState>(
                  bloc: _chatCubit,
                  builder: (context, state) {
                    if (state.isReceiverTyping) {
                      return Row(
                        children: [
                          Container(margin: const EdgeInsets.only(right: 4)),
                          Text(
                            "typing",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      );
                    }
                    if (state.isReceiverOnline) {
                      return const Text(
                        "Online",
                        style: TextStyle(fontSize: 14, color: Colors.green),
                      );
                    }
                    if (state.receiverLastSeen != null) {
                      final lastSeen = state.receiverLastSeen!.toDate();
                      return Text(
                        "last seen at ${DateFormat('h:mm a').format(lastSeen)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [Icon(Icons.more_vert)],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        bloc: _chatCubit,
        builder: (context, state) {
          if (state.status == chatStatus.loading)
            return Center(child: CircularProgressIndicator());
          if (state.status == chatStatus.error) {
            return Center(child: Text(state.error ?? 'something went wrong!'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderId == _chatCubit.currentUserId;

                    return MessageBubble(message: message, isMe: isMe);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.emoji_emotions),
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: handleSendMessage,
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isMe
              ? Theme.of(context).primaryColor.withOpacity(0.7)
              : Theme.of(context).primaryColor.withOpacity(0.1),
        ),
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 20,
              ),
            ),
            Row(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.timestamp.toDate()),
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
                if (isMe)
                  Icon(
                    Icons.done_all_rounded,
                    color: message.status == MessageStatus.read
                        ? Colors.indigo
                        : Colors.grey,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
