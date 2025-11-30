import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:whats_app/utiles/const/Apis.dart';
import 'package:whats_app/utiles/const/keys.dart';

class cloudinaryServices extends GetxController {
  static cloudinaryServices get instance => Get.find();

  final _dio = dio.Dio();

  // update  picture in cloudinary
  Future<dio.Response> uploadImage(File image, String folderName) async {
    try {
      String api = MyApiUrls.uploadApi(MyKeys.cloudName);

      final formData = dio.FormData.fromMap({
        'upload_preset': MyKeys.uploadPreset,
        'folder': folderName,
        "file": await dio.MultipartFile.fromFile(
          image.path,
          filename: image.path.split("/").last,
        ),
      });

      dio.Response response = await _dio.post(api, data: formData);

      return response;
    } catch (e) {
      throw 'Failed to upload profile picture. Please try again';
    }
  }

  // Delete picture form cloudinary
  Future<dio.Response> deleteImage(String publicId) async {
    try {
      String api = MyApiUrls.deleteApi(MyKeys.cloudName);

      int timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

      String signatureBase =
          'public_id=$publicId&timestamp=$timestamp${MyKeys.apiSecret}';
      String signature = sha1.convert(utf8.encode(signatureBase)).toString();

      final formData = dio.FormData.fromMap({
        'public_id': publicId,
        'api_key': MyKeys.apiKey,
        'timestamp': timestamp,
        'signature': signature,
      });

      dio.Response response = await _dio.post(api, data: formData);

      return response;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }
}
