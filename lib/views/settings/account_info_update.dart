import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _imageFile;
  String _fullName = '';
  String _phoneNumber = '';
  String _address = '';
  DateTime? _dateOfBirth;
  String _linkedin = '';
  String _twitter = '';
  String _facebook = '';
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    // Fetch current user's data
    fetchUserData();
  }

  void fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await _firestore.collection('customers').doc(user.uid).get();
      if (snapshot.exists) {
        setState(() {
          _fullName = snapshot['fullName'];
          _phoneNumber = snapshot['phoneNumber'];
          _address = snapshot['address'] ?? '';
          _linkedin = snapshot['profile']['socialMedia']['linkedin'] ?? '';
          _twitter = snapshot['profile']['socialMedia']['twitter'] ?? '';
          _facebook = snapshot['profile']['socialMedia']['facebook'] ?? '';
          _profilePictureUrl = snapshot['profile']['profilePicture'] ?? '';
          Timestamp dobTimestamp = snapshot['profile']['dateOfBirth'];
          _dateOfBirth = dobTimestamp.toDate();
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String profilePictureUrl = '';
        if (_imageFile != null) {
          profilePictureUrl = await _uploadProfilePictureToStorage(_imageFile!.readAsBytesSync());
        }

        await _firestore.collection('customers').doc(user.uid).update({
          'fullName': _fullName,
          'phoneNumber': _phoneNumber,
          'address': _address,
          'profile.dateOfBirth': _dateOfBirth,
          'profile.socialMedia.linkedin': _linkedin,
          'profile.socialMedia.twitter': _twitter,
          'profile.socialMedia.facebook': _facebook,
          if (profilePictureUrl.isNotEmpty) 'profile.profilePicture': profilePictureUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    }
  }

  Future<String> _uploadProfilePictureToStorage(Uint8List image) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _uploadImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : (_profilePictureUrl.isNotEmpty
                      ? NetworkImage(_profilePictureUrl)
                      : AssetImage('assets/default_profile.png') as ImageProvider),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _fullName,
              decoration: InputDecoration(labelText: 'Full Name'),
              onChanged: (value) => _fullName = value,
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _phoneNumber,
              decoration: InputDecoration(labelText: 'Phone Number'),
              onChanged: (value) => _phoneNumber = value,
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _address,
              decoration: InputDecoration(labelText: 'Address'),
              onChanged: (value) => _address = value,
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(_dateOfBirth != null ? 'Date of Birth: ${_dateOfBirth!.toLocal()}'.split(' ')[0] : 'Date of Birth'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _dateOfBirth ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null && pickedDate != _dateOfBirth) {
                  setState(() {
                    _dateOfBirth = pickedDate;
                  });
                }
              },
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _linkedin,
              decoration: InputDecoration(labelText: 'LinkedIn'),
              onChanged: (value) => _linkedin = value,
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _twitter,
              decoration: InputDecoration(labelText: 'Twitter'),
              onChanged: (value) => _twitter = value,
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: _facebook,
              decoration: InputDecoration(labelText: 'Facebook'),
              onChanged: (value) => _facebook = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
