import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/screens/calls_screen/controller/CallByNumberController.dart';
import 'package:whats_app/feature/screens/calls_screen/widget/callBottomSheetContent.dart';
import 'package:whats_app/utiles/theme/helpers/helper_function.dart';

class CallBottomSheetHelper {
  static void open() {
    final controller = Get.put(CallByNumberController(), tag: "call_by_number");

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (_) {
        final isDark = MyHelperFunction.isDarkMode(Get.context!);

        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.40,
          maxChildSize: 0.85,
          builder: (ctx, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF111315) : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16,
                ),
                child: CallBottomSheetContent(controller: controller),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (Get.isRegistered<CallByNumberController>(tag: "call_by_number")) {
        Get.delete<CallByNumberController>(tag: "call_by_number");
      }
    });
  }
}
