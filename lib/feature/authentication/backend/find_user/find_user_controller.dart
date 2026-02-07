import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whats_app/utiles/const/keys.dart';

class FindUserController extends GetxController {
  static FindUserController get instace => Get.find();

  final RxBool loading = false.obs;
  final RxString status = "Finding users from your contacts…".obs;
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    findUsersFromContacts();
  }

  Future<void> findUsersFromContacts() async {
    loading.value = true;
    users.clear();
    status.value = "Requesting contacts permission…";

    final perm = await Permission.contacts.request();
    if (!perm.isGranted) {
      loading.value = false;
      status.value = "Contacts permission denied";
      return;
    }

    status.value = "Reading contacts…";
    final contacts = await FlutterContacts.getContacts(withProperties: true);

    final Set<String> phones = {};
    for (final c in contacts) {
      for (final p in c.phones) {
        final phone = _normalizePhone(p.number);
        if (phone.isNotEmpty) phones.add(phone);
      }
    }

    if (phones.isEmpty) {
      loading.value = false;
      status.value = "No phone numbers found";
      return;
    }

    status.value = "Finding users on WhatsApp clone…";

    const int chunkSize = 10;
    final phoneList = phones.toList();

    for (int i = 0; i < phoneList.length; i += chunkSize) {
      final chunk = phoneList.sublist(
        i,
        (i + chunkSize > phoneList.length) ? phoneList.length : i + chunkSize,
      );

      final snap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .where("phone", whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        data["uid"] = doc.id;
        users.add(data);
      }
    }

    loading.value = false;
    status.value = users.isEmpty
        ? "No contacts are using this app"
        : "Users found";
  }

  String _normalizePhone(String phone) {
    var s = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return s;
  }
}
