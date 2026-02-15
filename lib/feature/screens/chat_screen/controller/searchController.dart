import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/const/keys.dart';

class ChatSearchController extends GetxController {
  final searchController = TextEditingController();

  final isLoading = false.obs;
  final results = <UserModel>[].obs;
  final error = RxnString();

  Timer? _debounce;

  void onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      search(q);
    });
  }

  Future<void> search(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      results.clear();
      error.value = null;
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      // Username prefix search (case-sensitive unless you store usernameLower)
      final snap = await FirebaseFirestore.instance
          .collection(MyKeys.userCollection)
          .orderBy('username')
          .startAt([q])
          .endAt(['$q\uf8ff'])
          .limit(20)
          .get();

      results.value = snap.docs.map((d) => UserModel.fromSnapshot(d)).toList();
    } catch (e) {
      error.value = "Search error: $e";
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
