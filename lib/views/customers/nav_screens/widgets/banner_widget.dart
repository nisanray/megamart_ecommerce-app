import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatefulWidget {
  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final _firestore = FirebaseFirestore.instance;

  final List<String> _bannerImage = [];
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> getBanners() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('banners').get();
      List<String> images = querySnapshot.docs.map((doc) => doc['image'] as String).toList();
      setState(() {
        _bannerImage.addAll(images);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getBanners();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container();
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: PageView.builder(
          itemCount: _bannerImage.length,
          itemBuilder: (context, index) {
            return Image.network(_bannerImage[index],fit: BoxFit.cover,);
          },
        ),
      ),
    );
  }
}
