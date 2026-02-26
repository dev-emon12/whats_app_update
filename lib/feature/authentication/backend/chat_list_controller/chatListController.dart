import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:whats_app/data/repository/user/UserRepository.dart';
import 'package:whats_app/feature/Chatting_screen/chatting_screen.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/const/keys.dart';

class ChatListController extends GetxController {
  final RxBool isSelecting = false.obs;
  final Rxn<UserModel> selectedUser = Rxn<UserModel>();

  final chatUsers = <UserModel>[].obs;

  final userRepo = Get.put(UserRepository());

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
    isSelecting.value = true;
  }

  void clearSelection() {
    selectedUser.value = null;
    isSelecting.value = false;
  }

  // Load users
  void loadUsers() {
    final myId = FirebaseAuth.instance.currentUser!.uid;

    userRepo.getAllUsersStream().listen((snapshot) async {
      //  get deleted chat ids
      final deletedSnap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .doc(myId)
          .collection('deleted_chats')
          .get();

      final deletedIds = deletedSnap.docs.map((e) => e.id).toSet();

      //  visible users
      final users = snapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .where((user) => user.id != myId && !deletedIds.contains(user.id))
          .toList();

      chatUsers.value = users;
    });
  }

  //Delete chat permanently
  Future<void> deleteChat() async {
    final user = selectedUser.value;
    if (user == null) return;

    final myId = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .doc(myId)
          .collection('deleted_chats')
          .doc(user.id)
          .set({'deletedAt': FieldValue.serverTimestamp()});

      chatUsers.removeWhere((u) => u.id == user.id);

      clearSelection();
      Get.snackbar("Deleted", "Chat deleted successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete chat");
    }
  }

  // get chat user id
  static Stream<List<String>> getMyChatUserIds(String myId) {
    return FirebaseFirestore.instance
        .collection(MyKeys.chatCollection)
        .where('participants', arrayContains: myId)
        .snapshots()
        .map((snap) {
          final ids = <String>{};
          for (final doc in snap.docs) {
            final data = doc.data();
            final parts = (data['participants'] ?? []) as List;
            for (final p in parts) {
              final pid = p.toString();
              if (pid.isNotEmpty && pid != myId) ids.add(pid);
            }
          }
          return ids.toList();
        });
  }
}
