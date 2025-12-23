import 'dart:async';
import 'package:get/get.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';

class ReSendOtpController extends GetxController {
  static ReSendOtpController get instance => Get.find();

  final RxInt remainingsec = 0.obs;
  final RxBool isResend = false.obs;
  Timer? _timer;

  AuthenticationRepository controller = Get.put(AuthenticationRepository());

  // start countdown
  void startCountdown(int seconds) {
    _timer?.cancel();
    remainingsec.value = seconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingsec.value <= 1) {
        _timer?.cancel();
        remainingsec.value = 0;
      } else {
        remainingsec.value--;
      }
    });
  }

  // Call when resend button is tapped
  Future<void> resendOtp(Future<void> Function() resendFn, int seconds) async {
    try {
      if (remainingsec.value != 0 || isResend.value) return;
      isResend.value = true;
      await controller.resendOtp();
      startCountdown(seconds);
    } catch (e) {
      Get.snackbar(
        'Something Went Wrong',
        "Please try again",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isResend.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
