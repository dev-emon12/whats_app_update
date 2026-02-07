import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_app/common/widget/chatting_app_bar/chatting_app_bar.dart';
import 'package:whats_app/feature/Chatting_screen/widget/message_card.dart';
import 'package:whats_app/feature/Chatting_screen/widget/text_field.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/authentication/backend/chatController/ChatController.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class ChattingScreen extends StatelessWidget {
  const ChattingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);
    final UserModel otherUser = Get.arguments as UserModel;
    Get.put(UserController());
    final chatC = Get.put(ChatController(otherUser));
    final allMessage = Messagerepository.GetAllMessage(otherUser);

    final userStream = FirebaseFirestore.instance
        .collection(MyKeys.userCollection)
        .doc(otherUser.id)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        UserModel liveUser;
        if (!snapshot.hasData || !snapshot.data!.exists) {
          liveUser = otherUser;
        } else {
          liveUser = UserModel.fromSnapshot(snapshot.data!);
        }

        final statusText = UserController.instance.buildOnlineStatusText(
          context: context,
          isOnline: liveUser.isOnline,
          lastActive: liveUser.lastActive,
        );

        return Obx(
          () => Scaffold(
            appBar: ChatAppBar(
              name: liveUser.username,
              subtitle: statusText,
              avatarImage: liveUser.profilePicture.isNotEmpty
                  ? NetworkImage(liveUser.profilePicture)
                  : AssetImage(MyImage.onProfileScreen),
              otherUser: otherUser,

              isSelecting: chatC.isSelecting.value,
              isSelectedImage: chatC.selectedIsImage,
              onCancelSelection: chatC.clearSelection,

              // Edit button
              onEditTap: () async {
                await chatC.editChat();
              },

              // copy button
              onCopyTap: () async {
                await chatC.copyText();
              },

              // delete button
              onDeleteTap: () async {
                final msg = chatC.selectedMessage.value;
                if (msg == null) return;

                final String myId = FirebaseAuth.instance.currentUser!.uid;
                final String fromId = (msg['fromId'] ?? '').toString().trim();

                if (fromId == myId) {
                  showModalBottomSheet(
                    context: Get.context!,
                    builder: (ctx) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text("Delete for me"),
                              onTap: () async {
                                Navigator.pop(ctx);
                                await chatC.deleteForMe();
                              },
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.delete_forever,
                                color: Colors.redAccent,
                              ),
                              title: Text("Delete for everyone"),
                              onTap: () async {
                                Navigator.pop(ctx);
                                await chatC.deleteForEveryone(msg);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  await chatC.deleteForMe();
                }
              },

              // download button
              onDownloadTap: () async {
                await chatC.downloadImageFromChat();
              },
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: allMessage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text("Say hi 👋, no messages yet"),
                          );
                        }

                        final messages = snapshot.data!.docs;
                        final myId = FirebaseAuth.instance.currentUser!.uid;

                        return ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final doc = messages[index];
                            final msg = doc.data();

                            final fromId = msg['fromId'];
                            final toId = msg['toId'];
                            final read = msg['read'] ?? '';

                            if (toId == myId &&
                                fromId != myId &&
                                read.isEmpty) {
                              Messagerepository.markMessageAsRead(
                                otherUser.id,
                                doc.id,
                              );
                            }
                            return MessageCard(
                              message: msg,
                              isSelected: chatC.selectedDocId.value == doc.id,
                              onLongPress: () {
                                chatC.selectMessage(
                                  msg: {...msg, 'docId': doc.id},
                                  docId: doc.id,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // bottom input
                  Text_filed(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
