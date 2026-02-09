import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/authentication/backend/chat_list_controller/chatListController.dart';
import 'package:whats_app/feature/screens/chat_screen/widgets/user_profile_dialog.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChatScreenChatList extends StatelessWidget {
  const ChatScreenChatList({super.key});

  Future<List<UserModel>> _fetchUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    const chunkSize = 10;
    final List<UserModel> out = [];

    for (int i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
        i,
        (i + chunkSize > ids.length) ? ids.length : i + chunkSize,
      );

      final snap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      out.addAll(snap.docs.map((d) => UserModel.fromSnapshot(d)));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);
    final String myId = FirebaseAuth.instance.currentUser!.uid;
    final chatListController = Get.put(ChatListController());

    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(MyKeys.chatCollection)
            .where('participants', arrayContains: myId)
            .snapshots(),
        builder: (context, chatSnap) {
          if (chatSnap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Mycolors.success,
              ),
            );
          }

          if (!chatSnap.hasData || chatSnap.data!.docs.isEmpty) {
            return const Center(child: Text("No chats"));
          }

          // collect accounts
          final List<String> partnerIds = [];
          for (final d in chatSnap.data!.docs) {
            final data = d.data();
            final parts = (data['participants'] ?? []) as List<dynamic>;
            for (final p in parts) {
              final id = p.toString();
              if (id.isNotEmpty && id != myId) partnerIds.add(id);
            }
          }

          final seen = <String>{};
          final uniquePartnerIds = partnerIds
              .where((id) => seen.add(id))
              .toList();

          if (uniquePartnerIds.isEmpty) {
            return const Center(child: Text("No message..."));
          }

          // deleted chats
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(MyKeys.userCollection)
                .doc(myId)
                .collection('deleted_chats')
                .snapshots(),
            builder: (context, deletedSnap) {
              final deletedIds = deletedSnap.hasData
                  ? deletedSnap.data!.docs.map((e) => e.id).toSet()
                  : <String>{};

              final filteredIds = uniquePartnerIds
                  .where((id) => !deletedIds.contains(id))
                  .toList();

              if (filteredIds.isEmpty) {
                return const Center(child: Text("No message..."));
              }

              return FutureBuilder<List<UserModel>>(
                future: _fetchUsersByIds(filteredIds),
                builder: (context, usersSnap) {
                  if (!usersSnap.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Mycolors.success,
                      ),
                    );
                  }

                  final map = {for (final u in usersSnap.data!) u.id: u};
                  final users = filteredIds
                      .map((id) => map[id])
                      .whereType<UserModel>()
                      .toList();

                  if (users.isEmpty) {
                    return Center(child: Text("No message..."));
                  }

                  return ListView.separated(
                    separatorBuilder: (_, __) =>
                        SizedBox(height: Mysize.spaceBtwInputFields),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: Messagerepository.GetLastMessage(user),
                        builder: (context, lastSnap) {
                          String subtitleText = user.about;
                          String timeText = '';
                          FontWeight nameWeight = FontWeight.normal;

                          if (lastSnap.hasData &&
                              lastSnap.data!.docs.isNotEmpty) {
                            final data = lastSnap.data!.docs.first.data();

                            final String msg = data['msg'] ?? '';
                            final dynamic sentTime = data['sent'];
                            final String read = data['read'] ?? '';
                            final String toId = data['toId'] ?? '';
                            final String type = data['type'] ?? 'text';

                            final Map<String, dynamic> deletedBy =
                                Map<String, dynamic>.from(
                                  data['deletedBy'] ?? const {},
                                );

                            final bool isDeletedForMe = deletedBy[myId] == true;

                            if (isDeletedForMe) {
                              subtitleText = user.about;
                            } else {
                              if (type == 'image') {
                                subtitleText = "📸 Image";
                              } else {
                                subtitleText = msg;
                              }
                            }

                            timeText = Messagerepository.getLastMessageTime(
                              context: context,
                              time: sentTime,
                            );

                            if (toId == myId && read.isEmpty) {
                              nameWeight = FontWeight.bold;
                            }
                          }

                          return StreamBuilder<
                            QuerySnapshot<Map<String, dynamic>>
                          >(
                            stream: Messagerepository.getUnreadMessage(user),
                            builder: (context, unreadSnap) {
                              final unreadCount =
                                  unreadSnap.data?.docs.length ?? 0;
                              final hasUnread = unreadCount > 0;

                              return ListTile(
                                onLongPress: () {
                                  chatListController.selectUser(user);
                                },
                                onTap: () => Get.to(
                                  () => ChattingScreen(),
                                  arguments: user,
                                ),
                                leading: GestureDetector(
                                  onTap: () => showUesrDialog(context, user),
                                  child: Hero(
                                    tag: user.id,
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundImage:
                                          user.profilePicture.isNotEmpty
                                          ? NetworkImage(user.profilePicture)
                                          : AssetImage(MyImage.onProfileScreen)
                                                as ImageProvider,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .copyWith(
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : nameWeight,
                                        color: isDark
                                            ? Mycolors.borderPrimary
                                            : Mycolors.textPrimary,
                                      ),
                                ),
                                subtitle: Text(
                                  subtitleText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        fontWeight: hasUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(timeText),
                                    if (hasUnread)
                                      Container(
                                        margin: EdgeInsets.only(top: 6),
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Mycolors.success,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unreadCount.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
