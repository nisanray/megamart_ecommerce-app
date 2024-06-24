import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;


  Future<String> _uploadProfilePictureToStorage(Uint8List? image) async {
    if (image == null) {
      throw Exception('Image data is null.');
    }

    String contentType = 'image/jpeg'; // Default content type for images

    // Determine the content type based on image data
    if (image.length >= 2 && image[0] == 0xFF && image[1] == 0xD8) {
      contentType = 'image/jpeg'; // JPEG image
    } else if (image.length >= 4 &&
        image[0] == 0x89 &&
        image[1] == 0x50 &&
        image[2] == 0x4E &&
        image[3] == 0x47) {
      contentType = 'image/png'; // PNG image
    } else if (image.length >= 6 &&
        image[0] == 0x47 &&
        image[1] == 0x49 &&
        image[2] == 0x46 &&
        image[3] == 0x38 &&
        (image[4] == 0x37 || image[4] == 0x39) &&
        image[5] == 0x61) {
      contentType = 'image/gif'; // GIF image
    } else {
      // If you have other image types to handle, add conditions here
      // Otherwise, fallback to a default content type
    }

    Reference ref = _storage.ref().child('profilePicture').child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(image, SettableMetadata(contentType: contentType));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }



  Future<String> signupCustomer(String email, String fullName, String phoneNumber, String password,Uint8List image) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && fullName.isNotEmpty && phoneNumber.isNotEmpty && password.isNotEmpty && image!= null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        String profilePictureUrl = await _uploadProfilePictureToStorage(image);
        await _firestore.collection('customers').doc(cred.user!.uid).set({
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'customerId': cred.user!.uid,
          'address': "",
          'profilePicture' : profilePictureUrl
        });

        res = 'Success';
      } else {
        res = 'Fill up all the fields';
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            res = 'This email address is already in use.';
            break;
          case 'invalid-email':
            res = 'This email address is invalid.';
            break;
          case 'weak-password':
            res = 'The password provided is too weak.';
            break;
          default:
            res = e.message ?? 'An unknown error occurred';
            break;
        }
      } else {
        res = e.toString();
      }
    }
    return res;
  }


  Future<String> loginCustomers(String email,String password) async{
  String res = 'Some error has occurred';
  try{
    if(email.isNotEmpty && password.isNotEmpty){
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = 'Success';
    }else{
      res = 'Fill up all the fields';
    }
  }
  catch(e){
    if(e is FirebaseAuthException){
      switch (e.code){
        case 'user-not-found':
          res = 'No user found with the email';
          break;

        case 'wrong-password':
          res = 'Wrong password provided.';
          break;

        default:
          res = e.message ?? 'An unknown error occured';
          break;
      }
    }
    else{
      res = e.toString();
    }
  }
  return res;
  }
}
