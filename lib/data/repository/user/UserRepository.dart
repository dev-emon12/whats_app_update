import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:whats_app/data/repository/authentication_repo/AuthenticationRepo.dart';
import 'package:whats_app/data/service/cloudinary_service.dart';
import 'package:whats_app/feature/authentication/Model/UserModel.dart';
import 'package:whats_app/feature/authentication/backend/MessageRepo/MessageRepository.dart';
import 'package:whats_app/feature/personalization/controller/UserController.dart';
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
  static User get user => FirebaseAuth.instance.currentUser!;
  static late UserModel me;
  final _MessageRepo = Get.put(Messagerepository());

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
      await _Db.collection(
        MyKeys.userCollection,
      ).doc(AuthenticationRepository.instance.currentUser!.uid).update(map);
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again";
    }
  }

  // Get my User Id
  Stream<DocumentSnapshot<Map<String, dynamic>>> getMYUserId() {
    try {
      final uid = AuthenticationRepository.instance.currentUser!.uid;

      return _Db.collection(MyKeys.userCollection).doc(uid).snapshots();
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again.";
    }
  }

  // Get all User
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
    List<String> userIds,
  ) {
    try {
      if (userIds.isEmpty) {
        return const Stream.empty();
      }

      return _Db.collection(
        MyKeys.userCollection,
      ).where('id', whereIn: userIds).snapshots();
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again.";
    }
  }

  // getSelfInfo
  Future<void> getSelfInfo() async {
    try {
      final uid = AuthenticationRepository.instance.currentUser!.uid;

      final doc = await _Db.collection(MyKeys.userCollection).doc(uid).get();

      if (doc.exists && doc.data() != null) {
        me = UserModel.fromSnapshot(doc);

        Messagerepository.me = me;
        await _MessageRepo.getFirebaseMessageToken();
        await UserController.instance.updateActiveStatus(true);
      } else {
        await UserController.instance.saveUserRecord();
        await getSelfInfo();
      }
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw "Something went wrong. Please try again.";
    }
  }

  // get All Users Stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersStream() {
    return _Db.collection(MyKeys.userCollection).snapshots();
  }

  // get User By Id
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _Db.collection("users").doc(uid).get();
      // print("The user : $doc");

      if (!doc.exists) return null;

      return UserModel.fromSnapshot(doc);
    } catch (e) {
      debugPrint(" getUserById error: $e");
      return null;
    }
  }

  // Future<void> syncAuthDisplayName(String username) async {
  //   final u = FirebaseAuth.instance.currentUser;
  //   if (u == null) return;

  //   final name = username.trim();
  //   if (name.isEmpty) return;

  //   await u.updateDisplayName(name);
  //   await u.reload();
  // }
}
