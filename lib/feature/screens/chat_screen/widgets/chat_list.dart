import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/screens/chat_screen/widgets/user_profile_dialog.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class chat_screen_chat_list extends StatelessWidget {
  const chat_screen_chat_list({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserRepository());
    final isDark = MyHelperFunction.isDarkMode(context);
    final String myId = FirebaseAuth.instance.currentUser!.uid;

    return Expanded(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs
              .map((doc) => UserModel.fromSnapshot(doc))
              .toList();

          return ListView.separated(
            separatorBuilder: (context, index) =>
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

                  if (lastSnap.hasData && lastSnap.data!.docs.isNotEmpty) {
                    final lastDoc = lastSnap.data!.docs.first;
                    final data = lastDoc.data();

                    final String msg = (data['msg'] ?? '').toString();
                    final dynamic sentTime = data['sent'];
                    final String read = (data['read'] ?? '').toString();
                    final String toId = (data['toId'] ?? '').toString();
                    final String type = (data['type'] ?? 'text').toString();

                    //  show proper preview based on message type
                    if (type == 'image') {
                      subtitleText = "📸 Image";
                    } else if (type == 'call') {
                      subtitleText = "📞 Call";
                    } else {
                      subtitleText = msg;
                    }

                    timeText = Messagerepository.getLastMessageTime(
                      context: context,
                      time: sentTime,
                    );

                    final bool isUnread = (toId == myId) && read.isEmpty;
                    nameWeight = isUnread ? FontWeight.bold : FontWeight.normal;
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: Messagerepository.getUnreadMessage(user),
                    builder: (context, unreadSnap) {
                      int unreadCount = 0;
                      if (unreadSnap.hasData && unreadSnap.data != null) {
                        unreadCount = unreadSnap.data!.docs.length;
                      }

                      final bool hasUnread = unreadCount > 0;

                      final FontWeight effectiveNameWeight = hasUnread
                          ? FontWeight.bold
                          : nameWeight;

                      final FontWeight subtitleWeight = hasUnread
                          ? FontWeight.bold
                          : FontWeight.normal;

                      final FontWeight timeWeight = hasUnread
                          ? FontWeight.bold
                          : FontWeight.normal;

                      return ListTile(
                        onTap: () =>
                            Get.to(() => ChattingScreen(), arguments: user),
                        leading: GestureDetector(
                          onTap: () => showUesrDialog(context, user),
                          child: Hero(
                            tag: user.id,
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: user.profilePicture.isNotEmpty
                                  ? NetworkImage(user.profilePicture)
                                  : const AssetImage(MyImage.onProfileScreen),
                            ),
                          ),
                        ),
                        title: Text(
                          user.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: isDark
                                    ? Mycolors.borderPrimary
                                    : Mycolors.textPrimary,
                                fontWeight: effectiveNameWeight,
                              ),
                        ),
                        subtitle: Text(
                          subtitleText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: isDark
                                    ? Mycolors.borderPrimary
                                    : Mycolors.textPrimary,
                                fontWeight: subtitleWeight,
                              ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeText,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: isDark
                                        ? Mycolors.borderPrimary
                                        : Mycolors.textPrimary,
                                    fontWeight: timeWeight,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            if (hasUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: const BoxDecoration(
                                  color: Mycolors.success,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
