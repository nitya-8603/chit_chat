import 'package:chit_chat/data/models/chat_message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(widget.receiverName[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiverName),
                  Text(
                    'Online',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [Icon(Icons.more_vert)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: ChatMessageModel(
                    id: "12345678945",
                    chatRoomId: "12345678",
                    senderId: "1254945626",
                    receiverId: "265484561",
                    content: "hello!",
                    timestamp: Timestamp.now(),
                    readBy: [],
                    status: MessageStatus.read,
                  ),
                  isMe: true,
                );
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
                Icon(Icons.send, color: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ],
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
                  '4:54AM',
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
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
