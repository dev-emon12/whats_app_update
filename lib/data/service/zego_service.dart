import 'package:flutter/material.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoService {
  ZegoService._();
  static final ZegoService instance = ZegoService._();

  final authRepo = AuthenticationRepository.instance;
  bool _inited = false;
  bool get isInited => _inited;

  Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
    required String userId,
    required String userName,
  }) async {
    final safeId = userId.trim();
    if (safeId.isEmpty) {
      debugPrint(" ZEGO init blocked: userId empty");
      return;
    }

    String safeName = userName.trim();
    if (safeName.isEmpty) {
      safeName = (await authRepo.getSafeUserNameFromFirestore(safeId)).trim();
    }
    if (safeName.isEmpty) safeName = "Guest";

    if (_inited) return;
    _inited = true;

    ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    try {
      await ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 1791254756,
        appSign:
            "6d100a52da23818ae74db2848a4e1dc0d91f09cf1842555b040626051b51ca93",
        userID: safeId,
        userName: safeName,
        plugins: [ZegoUIKitSignalingPlugin()],
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
      );

      debugPrint(" ZEGO Invitation Service init OK: $safeId / $safeName");
    } catch (e) {
      _inited = false;
      debugPrint(" ZEGO init failed: $e");
    }
  }

  void uninit() {
    try {
      ZegoUIKitPrebuiltCallInvitationService().uninit();
    } catch (_) {}
    _inited = false;
  }
}
