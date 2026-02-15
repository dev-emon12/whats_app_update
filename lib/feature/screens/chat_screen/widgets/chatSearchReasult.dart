import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/screens/chat_screen/controller/searchController.dart';

class ChatSearchResults extends StatelessWidget {
  const ChatSearchResults({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatSearchController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.error.value != null) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(controller.error.value!),
        );
      }

      if (controller.results.isEmpty) {
        return const SizedBox.shrink();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = controller.results[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (user.profilePicture.isNotEmpty)
                  ? NetworkImage(user.profilePicture)
                  : null,
              child: (user.profilePicture.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user.username),
            subtitle: Text(user.phoneNumber),
            onTap: () {
              Get.to(ChattingScreen(), arguments: user);
            },
          );
        },
      );
    });
  }
}
