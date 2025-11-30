import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/data/service/cloudinary_service.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/utiles/const/keys.dart';
import 'package:whats_app/utiles/exception/firebase_auth_exceptions.dart';
import 'package:whats_app/utiles/exception/firebase_exceptions.dart';
import 'package:whats_app/utiles/exception/formate_exceptions.dart';
import 'package:whats_app/utiles/exception/platform_exceptions.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final _Db = FirebaseFirestore.instance;

  final _coludnaryServcies = Get.put(cloudinaryServices());
  final _authenticationRepository = Get.put(AuthenticationRepository());

  // Sent user details to Db
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _Db.collection(
        MyKeys.userCollection,
      ).doc(user.id).set(user.toJson());
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong.Please try again";
    }
  }

  // update user profile picture form cloudinary
  Future<dio.Response> updateProfilePicture(File image) async {
    try {
      dio.Response response = await _coludnaryServcies.uploadImage(
        image,
        MyKeys.profileFolder,
      );
      return response;
    } catch (e) {
      throw "Failed to upload profile picture. Please try again";
    }
  }

  //  // Delete profile picture form cloudinary
  Future<dio.Response> deleteProfilePicture(String publicId) async {
    try {
      dio.Response response = await _coludnaryServcies.deleteImage(publicId);
      return response;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  // update user details in single field to Db
  Future<void> updateSingleField(Map<String, dynamic> map) async {
    try {
      final uid = AuthenticationRepository.instance.currentUser!.uid;

      await _Db.collection(
        MyKeys.userCollection,
      ).doc(uid).set(map, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong.Please try again";
    }
  }

  // Future<void> debugPrintCurrentUserDoc() async {
  //   try {
  //     final uid = AuthenticationRepository.instance.currentUser!.uid;

  //     final doc =
  //         await _Db.collection(MyKeys.userCollection) // "user"
  //             .doc(uid)
  //             .get();

  //     print("📝 Firestore doc for $uid: ${doc.data()}");
  //   } catch (e) {
  //     print("❌ Error reading user doc: $e");
  //   }
  // }
}
