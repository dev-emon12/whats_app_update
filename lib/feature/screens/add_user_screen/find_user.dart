import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/backend/find_user/find_user_controller.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/const/image.dart';
import 'package:whats_app/utiles/theme/const/sizes.dart';

class FindUser extends StatelessWidget {
  const FindUser({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FindUserController());

    return Scaffold(
      // appbar
      appBar: MyAppbar(
        title: Text(
          "Find user",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadAllAndFilter,
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.group_add_rounded)),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 0.4,
                  color: Mycolors.success,
                ),
                SizedBox(height: 12),
                Text(controller.status.value),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // USERS ON WHATSAPP
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  "Contacts on WhatsApp (${controller.registeredUsers.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              if (controller.registeredUsers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(controller.status.value),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.registeredUsers.length,
                  separatorBuilder: (_, __) => SizedBox(height: Mysize.sm),
                  itemBuilder: (context, index) {
                    final users = controller.registeredUsers[index];
                    final name = users.username.isEmpty
                        ? "Unknown"
                        : users.username;

                    return ListTile(
                      onTap: () {
                        Get.to(() => ChattingScreen(), arguments: users);
                      },
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: users.profilePicture.isNotEmpty
                            ? NetworkImage(users.profilePicture)
                            : AssetImage(MyImage.onProfileScreen)
                                  as ImageProvider,
                      ),
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        users.about,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),

              SizedBox(height: 16),
              Divider(height: 1),

              //ALL CONTACTS LIST
              Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  "All contacts (${controller.contacts.length})",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              if (controller.contacts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text("No contacts found"),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.contacts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final contact = controller.contacts[index];
                    final name = contact.displayName.isEmpty
                        ? "Unknown"
                        : contact.displayName;
                    final phone = controller.firstPhone(contact);
                    final isReg = controller.isRegisteredContact(contact);

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(phone.isEmpty ? "No phone number" : phone),
                      trailing: isReg ? Text("Registered") : SizedBox(),
                      onTap: isReg
                          ? () {
                              final user = controller.matchedUser(contact);
                              if (user != null) {
                                Get.to(() => ChattingScreen(), arguments: user);
                              }
                            }
                          : null,
                    );
                  },
                ),

              SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
