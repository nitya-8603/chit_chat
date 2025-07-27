import 'dart:io';

import 'package:chit_chat/data/models/chat_message_model.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/logic/cubits/chat/chat_cubit.dart';
import 'package:chit_chat/logic/cubits/chat/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
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
  final _scrollController = ScrollController();
  List<ChatMessageModel> _previousMessages = [];
  bool _isComposing = false;
  bool _showEmoji = false;

  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    print("recervier id ${widget.receiverId}");
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChanged);
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  Future<void> _handleSendMessage() async {
    final messageText = messageController.text.trim();
    messageController.clear();
    await _chatCubit.sendMessage(
      content: messageText,
      receiverId: widget.receiverId,
    );
  }

  void _onScroll() {
    //load more messages when reaching to top

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _chatCubit.loadMoreMessages();
    }
  }

  void _onTextChanged() {
    final isComposing = messageController.text.isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
      if (isComposing) {
        _chatCubit.startTyping();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _hasNewMessages(List<ChatMessageModel> messages) {
    if (messages.length != _previousMessages.length) {
      _scrollToBottom();
      _previousMessages = messages;
    }
  }

  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastSeenDate = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);

    final timeFormat = DateFormat('h:mm a'); // e.g., 5:30 PM

    if (lastSeenDate == today) {
      return "Last seen today at ${timeFormat.format(lastSeen)}";
    } else if (lastSeenDate == yesterday) {
      return "Last seen yesterday at ${timeFormat.format(lastSeen)}";
    } else {
      final dateFormat = DateFormat('d MMM'); // e.g., 25 Jul
      return "Last seen on ${dateFormat.format(lastSeen)} at ${timeFormat.format(lastSeen)}";
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    _chatCubit.leaveChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
              child: Text(
                widget.receiverName[0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
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
                          Text(
                            "typing...",
                            style: TextStyle(
                              fontSize: 12,
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
                        "${formatLastSeen(lastSeen)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            bloc: _chatCubit,
            builder: (context, state) {
              if (state.isUserBlocked) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton.icon(
                    onPressed: () => _chatCubit.unBlockUser(widget.receiverId),
                    label: const Text(
                      "Unblock",
                      style: TextStyle(color: Colors.green),
                    ),
                    icon: const Icon(Icons.block, color: Colors.green),
                  ),
                );
              }
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == "block") {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 20),
                            children: [
                              TextSpan(text: "Are you sure you want to block"),
                              TextSpan(
                                text: ' ${widget.receiverName}?',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              "Block",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _chatCubit.blockUser(widget.receiverId);
                    }
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem(
                    value: 'block',
                    child: Text("Block User"),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          _hasNewMessages(state.messages);
        },
        bloc: _chatCubit,
        builder: (context, state) {
          if (state.status == chatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == chatStatus.error) {
            Center(child: Text(state.error ?? "Something went wrong"));
          }
          return Column(
            children: [
              if (state.amIBlocked)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.withOpacity(0.1),
                  child: Text(
                    "You have been blocked by ${widget.receiverName}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (state.isUserBlocked)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.withOpacity(0.1),
                  child: Text(
                    "This user has been blocked by you!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];

                    final isMe = message.senderId == _chatCubit.currentUserId;
                    return MessageBubble(message: message, isMe: isMe);
                  },
                ),
              ),
              if (!state.amIBlocked && !state.isUserBlocked)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showEmoji = !_showEmoji;
                                if (_showEmoji) {
                                  FocusScope.of(context).unfocus();
                                }
                              });
                            },
                            icon: const Icon(Icons.emoji_emotions_outlined),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onTap: () {
                                if (_showEmoji) {
                                  setState(() {
                                    _showEmoji = false;
                                  });
                                }
                              },
                              controller: messageController,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Type a message",
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
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
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isComposing ? _handleSendMessage : null,
                            icon: Icon(
                              Icons.send,
                              color: _isComposing
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (_showEmoji)
                        SizedBox(
                          height: 250,
                          child: EmojiPicker(
                            textEditingController: messageController,
                            onEmojiSelected: (category, emoji) {
                              messageController
                                ..text += emoji.emoji
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(
                                    offset: messageController.text.length,
                                  ),
                                );
                              setState(() {
                                _isComposing =
                                    messageController.text.isNotEmpty;
                              });
                            },
                            config: Config(
                              height: 250,
                              emojiViewConfig: EmojiViewConfig(
                                columns: 7,
                                emojiSizeMax:
                                    32.0 * (Platform.isIOS ? 1.30 : 1.0),
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                gridPadding: EdgeInsets.zero,
                                backgroundColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                loadingIndicator: const SizedBox.shrink(),
                              ),
                              categoryViewConfig: const CategoryViewConfig(
                                initCategory: Category.RECENT,
                              ),
                              bottomActionBarConfig: BottomActionBarConfig(
                                enabled: true,
                                backgroundColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                buttonColor: Theme.of(context).primaryColor,
                              ),
                              skinToneConfig: const SkinToneConfig(
                                enabled: true,
                                dialogBackgroundColor: Colors.white,
                                indicatorColor: Colors.grey,
                              ),
                              searchViewConfig: SearchViewConfig(
                                backgroundColor: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                buttonIconColor: Theme.of(context).primaryColor,
                              ),
                            ),
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
  // final bool showTime;
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    // required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isMe ? 64 : 8,
          right: isMe ? 8 : 64,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.timestamp.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: isMe ? Colors.white : Colors.grey,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: message.status == MessageStatus.read
                        ? Colors.red
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
