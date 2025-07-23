import 'package:chit_chat/core/common/utils/ui_utils.dart';
import 'package:chit_chat/data/repositories/contact_repository.dart';
import 'package:chit_chat/data/services/service_locator.dart';
import 'package:chit_chat/logic/cubits/auth/auth_cubit.dart';
import 'package:chit_chat/presentation/chat/chat_message_screen.dart';
import 'package:chit_chat/presentation/screens/auth/login_screen.dart';
import 'package:chit_chat/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _contactRepository = getIt<ContactRepository>();
  }

  void _showContactsList(BuildContext context) async {
    final hasPermission = await _contactRepository.requestContactsPermission();
    if (!hasPermission) {
      UiUtils.showSnackBar(context, message: 'Contact Permission Denied!');
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return const Center(child: Text("No contacts found"));
                    }
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            child: Text(contact["name"][0].toUpperCase()),
                          ),
                          title: Text(contact["name"]),
                          onTap: () {
                            getIt<AppRouter>().push(
                              ChatMessageScreen(
                                receiverId: contact['id'],
                                receiverName: contact['name'],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          InkWell(
            onTap: () async {
              await getIt<AuthCubit>().signOut();
              getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
            },
            child: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Center(child: Text('user is authenticated')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactsList(context),
        child: Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
