import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/appbar/MyAppBar.dart';
import 'package:whats_app/feature/authentication/backend/find_user/find_user_controller.dart';

class FindUser extends StatelessWidget {
  const FindUser({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FindUserController());

    return Scaffold(
      appBar: MyAppbar(
        title: Text(
          "Find user",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        showBackArrow: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.findUsersFromContacts,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(controller.status.value),
              ],
            ),
          );
        }

        if (controller.users.isEmpty) {
          return Center(child: Text(controller.status.value));
        }

        return ListView.separated(
          itemCount: controller.users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final u = controller.users[index];
            final name = (u["name"] ?? u["fullName"] ?? "Unknown").toString();
            final phone = (u["phone"] ?? "").toString();

            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(name),
              subtitle: Text(phone),
              onTap: () {
                // TODO: open chat screen
                // Get.to(() => ChattingScreen(), arguments: UserModel.fromMap(u));
              },
            );
          },
        );
      }),
    );
  }
}
