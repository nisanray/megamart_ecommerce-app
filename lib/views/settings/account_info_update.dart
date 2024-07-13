import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megamart/utils/location/location_picker.dart';

class AccountInformationView extends StatefulWidget {
  const AccountInformationView({super.key});

  @override
  _AccountInformationViewState createState() => _AccountInformationViewState();
}

class _AccountInformationViewState extends State<AccountInformationView> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactPhoneController = TextEditingController();

  Uint8List? _profileImage;
  bool _isLoading = false;

  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  String? _selectedArea;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserProfile();
  }

  Future<void> _loadCurrentUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('customers').doc(user.uid).get();
      setState(() {
        _emailController.text = userDoc['email'];
        _fullNameController.text = userDoc['fullName'];
        _phoneNumberController.text = userDoc['phoneNumber'];
        _addressController.text = userDoc['address'];
        _bioController.text = userDoc['profile']['bio'];
        _genderController.text = userDoc['profile']['gender'];
        _linkedinController.text = userDoc['profile']['socialMedia']['linkedin'];
        _twitterController.text = userDoc['profile']['socialMedia']['twitter'];
        _facebookController.text = userDoc['profile']['socialMedia']['facebook'];
        _emergencyContactNameController.text = userDoc['profile']['emergencyContact']['name'];
        _emergencyContactPhoneController.text = userDoc['profile']['emergencyContact']['phone'];

        // Set location fields if available
        if (userDoc['address'] != null) {
          _selectedDivision = userDoc['address']['division'];
          _selectedDistrict = userDoc['address']['district'];
          _selectedUpazila = userDoc['address']['upazila'];
          _selectedArea = userDoc['address']['area'];
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          String? profilePictureUrl;
          if (_profileImage != null) {
            profilePictureUrl = await _uploadProfilePictureToStorage(_profileImage!);
          }

          await _firestore.collection('customers').doc(user.uid).update({
            'email': _emailController.text,
            'fullName': _fullNameController.text,
            'phoneNumber': _phoneNumberController.text,
            'address': {
              'division': _selectedDivision,
              'district': _selectedDistrict,
              'upazila': _selectedUpazila,
              'area': _selectedArea,
            },
            'profile.profilePicture': profilePictureUrl ?? FieldValue.delete(),
            'profile.bio': _bioController.text,
            'profile.gender': _genderController.text,
            'profile.socialMedia.linkedin': _linkedinController.text,
            'profile.socialMedia.twitter': _twitterController.text,
            'profile.socialMedia.facebook': _facebookController.text,
            'profile.emergencyContact.name': _emergencyContactNameController.text,
            'profile.emergencyContact.phone': _emergencyContactPhoneController.text,
            'updatedAt': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadProfilePictureToStorage(Uint8List image) async {
    String contentType = 'image/jpeg';

    if (image.length >= 2 && image[0] == 0xFF && image[1] == 0xD8) {
      contentType = 'image/jpeg';
    } else if (image.length >= 4 &&
        image[0] == 0x89 &&
        image[1] == 0x50 &&
        image[2] == 0x4E &&
        image[3] == 0x47) {
      contentType = 'image/png';
    } else if (image.length >= 6 &&
        image[0] == 0x47 &&
        image[1] == 0x49 &&
        image[2] == 0x46 &&
        image[3] == 0x38 &&
        (image[4] == 0x37 || image[4] == 0x39) &&
        image[5] == 0x61) {
      contentType = 'image/gif';
    }

    Reference ref = FirebaseStorage.instance.ref().child('profilePicture').child(_auth.currentUser!.uid);
    UploadTask uploadTask = ref.putData(image, SettableMetadata(contentType: contentType));
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() async {
        _profileImage = Uint8List.fromList(await image.readAsBytes());
      });
    }
  }

  void _updateLocation(String? division, String? district, String? upazila, String? area) {
    setState(() {
      _selectedDivision = division;
      _selectedDistrict = district;
      _selectedUpazila = upazila;
      _selectedArea = area;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Information'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              LocationPicker(
                onLocationChanged: _updateLocation,
                initialDivision: _selectedDivision,
                initialDistrict: _selectedDistrict,
                initialUpazila: _selectedUpazila,
                initialArea: _selectedArea,
              ),
              // TextFormField(
              //   controller: _addressController,
              //   decoration: InputDecoration(labelText: 'Address'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your address';
              //     }
              //     return null;
              //   },
              // ),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn'),
              ),
              TextFormField(
                controller: _twitterController,
                decoration: const InputDecoration(labelText: 'Twitter'),
              ),
              TextFormField(
                controller: _facebookController,
                decoration: const InputDecoration(labelText: 'Facebook'),
              ),
              TextFormField(
                controller: _emergencyContactNameController,
                decoration: const InputDecoration(labelText: 'Emergency Contact Name'),
              ),
              TextFormField(
                controller: _emergencyContactPhoneController,
                decoration: const InputDecoration(labelText: 'Emergency Contact Phone'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _pickImage,
                child: const Text('Pick Profile Image'),
              ),
              if (_profileImage != null)
                Image.memory(_profileImage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
