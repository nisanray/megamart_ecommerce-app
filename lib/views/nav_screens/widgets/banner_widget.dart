import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

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
            return CachedNetworkImage(fit: BoxFit.cover,
              imageUrl: _bannerImage[index],
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Shimmer(
                    duration: const Duration(seconds: 3), //Default value
                    interval: const Duration(seconds: 5), //Default value: Duration(seconds: 0)
                    color: Colors.white, //Default value
                    colorOpacity: 0, //Default value
                    enabled: true, //Default value
                    direction: const ShimmerDirection.fromLTRB(),  //Default Value
                    child: Container(
                      color: Colors.white,
                    ),
                  ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }
}
