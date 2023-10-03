import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vku_connectx/models/user.dart' as model;
import 'package:vku_connectx/resources/storage_methods.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
    await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty &&
          file != null) {
        // Kiểm tra địa chỉ email có đúng đuôi "@vku.udn.vn" hay không
        if (email.endsWith("@vku.udn.vn")) {
          // Đúng địa chỉ email, tiến hành đăng ký
          UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          String photoUrl =
          await StorageMethods().uploadImageToStorage('profilePics', file, false);

          model.User user = model.User(
            username: username,
            uid: cred.user!.uid,
            photoUrl: photoUrl,
            email: email,
            bio: bio,
            followers: [],
            following: [],

          );

          // Thêm người dùng vào cơ sở dữ liệu của bạn
          await _firestore
              .collection("users")
              .doc(cred.user!.uid)
              .set(user.toJson());

          res = "success";
        } else {
         // res = "Vui lòng sử dụng địa chỉ email có đuôi @vku.udn.vn";
         Fluttertoast.showToast(
             msg: "Vui lòng sử dụng địa chỉ email có đuôi @vku.udn.vn",
             toastLength: Toast.LENGTH_SHORT,
             gravity: ToastGravity.CENTER,
             timeInSecForIosWeb: 1,
             backgroundColor: Colors.red,
             textColor: Colors.white,
             fontSize: 16.0
         );
        }
      } else {
        res = "Vui lòng nhập đầy đủ thông tin";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
