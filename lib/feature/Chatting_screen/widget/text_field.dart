import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/authentication/backend/chatController/ChatController.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class Text_filed extends GetView<ChatController> {
  const Text_filed({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyHelperFunction.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          // TEXT FIELD
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: TextFormField(
                maxLines: null,
                controller: controller.textController,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Mycolors.light : Mycolors.black,
                ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: isDark ? Mycolors.light : Mycolors.dark,
                    ),
                  ),
                  suffixIcon: Obx(() {
                    final bool empty = controller.message.value.isEmpty;

                    return SizedBox(
                      width: empty ? 100 : 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // CAMERA BUTTON
                          if (empty)
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {},
                              icon: Icon(
                                Icons.camera_alt,
                                color: isDark ? Mycolors.light : Mycolors.dark,
                              ),
                            ),

                          //IMAGE BUTTON
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                            icon: Icon(
                              Icons.image_rounded,
                              color: isDark ? Mycolors.light : Mycolors.dark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  hintText: "Message...",
                  hintMaxLines: 1,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1000),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(146, 78, 75, 75),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // SEND BUTTON
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Obx(
              () => GestureDetector(
                onTap: controller.isSending.value
                    ? null
                    : () {
                        controller.sendMessage();
                      },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isSending.value
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
