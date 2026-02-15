import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/common/widget/ZegoCallBtn/ZegoCallBtn.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/screens/calls_screen/controller/CallByNumberController.dart';
import 'package:whats_app/feature/screens/calls_screen/widget/callAction.dart';
import 'package:whats_app/feature/screens/calls_screen/widget/userPreviewCard.dart';
import 'package:whats_app/utiles/theme/const/colors.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class CallBottomSheetContent extends StatelessWidget {
  const CallBottomSheetContent({super.key, required this.controller});

  final CallByNumberController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = MyHelperFunction.isDarkMode(context);

    final bgCard = isDark ? const Color(0xFF171A1D) : const Color(0xFFF6F7F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF101418);
    final textSecondary = isDark ? Colors.white70 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black12,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.dialpad_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Find user",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close_rounded, color: textSecondary),
            ),
          ],
        ),

        SizedBox(height: 14),

        // Input card
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone number",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: "Enter phone number...",
                  hintStyle: TextStyle(color: textSecondary),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: Icon(Icons.phone_rounded, color: textSecondary),
                ),
                onSubmitted: (_) => controller.searchUser(),
              ),
              SizedBox(height: 12),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.searchUser,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color.fromARGB(255, 2, 173, 65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              color: isDark ? Mycolors.light : Mycolors.dark,
                            ),
                          )
                        : Text(
                            "Find user",
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14),

        // Error
        Obx(() {
          final error = controller.errorText.value;
          if (error == null) return SizedBox.shrink();

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red.withOpacity(0.12)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.red.withOpacity(0.25)
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.red.shade400),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(
                          color: isDark
                              ? Colors.red.shade200
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
            ],
          );
        }),

        // Found user
        Obx(() {
          final user = controller.foundUser.value;
          if (user == null) return SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.off(ChattingScreen(), arguments: user),
                child: UserPreviewCard(user: user),
              ),
              SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: PremiumCallAction(
                      title: "Audio Call",
                      subtitle: "Crystal voice",
                      icon: Icons.call_rounded,
                      child: ZegoCallInvitationButton(
                        otherUser: user,
                        isVideo: false,
                        icon: Icons.call,
                        text: "audio",
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: PremiumCallAction(
                      title: "Video Call",
                      subtitle: "HD video",
                      icon: Icons.videocam_rounded,
                      child: ZegoCallInvitationButton(
                        otherUser: user,
                        isVideo: true,
                        icon: Icons.videocam,
                        text: "video",
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Text(
                "Tip: Make sure the other user is online for faster connection.",
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),

        SizedBox(height: 18),
      ],
    );
  }
}
