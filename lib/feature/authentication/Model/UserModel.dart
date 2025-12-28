import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  String phoneNumber;
  String about;
  String username;
  String email;
  String profilePicture;
  String createdAt;
  bool isOnline;
  String pushToken;
  String lastActive;
  String publicId;
  String links;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.profilePicture,
    required this.about,
    required this.createdAt,
    required this.isOnline,
    required this.pushToken,
    required this.lastActive,
    this.publicId = '',
    required this.links,
  });

  /// Function to get the full name
  String get fullName => username;

  /// static function to create an empty user model
  static UserModel empty() => UserModel(
    id: "",
    username: "",
    email: "",
    phoneNumber: "",
    profilePicture: "",
    about: "Hi, there I'm using WhatsApp.",
    createdAt: "",
    isOnline: true,
    pushToken: "",
    lastActive: "",
    publicId: "",
    links: "Add Links",
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'about': about,
      'createdAt': createdAt,
      'isOnline': isOnline,
      'pushToken': pushToken,
      'lastActive': lastActive,
      'publicId': publicId,
      'links': links,
    };
  }

  factory UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) return UserModel.empty();

    String readTime(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Timestamp) {
        return value.millisecondsSinceEpoch.toString();
      }
      return '';
    }

    return UserModel(
      id: document.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      about: data['about'] ?? "Hi, there I'm using WhatsApp",
      createdAt: readTime(data['createdAt']),
      isOnline: data['isOnline'] ?? false,
      pushToken: data['pushToken'] ?? '',
      lastActive: readTime(data['lastActive']),
      publicId: data['publicId'] ?? '',
      links: data['links'] ?? '',
    );
  }
}
