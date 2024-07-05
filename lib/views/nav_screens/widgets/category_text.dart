import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../category_products_page.dart';

class CategoryText extends StatefulWidget {
  @override
  _CategoryTextState createState() => _CategoryTextState();
}

class _CategoryTextState extends State<CategoryText> {
  final ScrollController _scrollController = ScrollController();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('categories').get();
      setState(() {
        _categories = querySnapshot.docs;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Categories",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _categories.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      var category = _categories[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ActionChip(
                          label: Text(
                            category['name'],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.deepPurpleAccent.shade700,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryProductsPage(category: category),
                              ),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Calculate the scroll position
                    double maxWidth = _scrollController.position.maxScrollExtent;
                    double currentPosition = _scrollController.position.pixels;
                    double newOffset = currentPosition + MediaQuery.of(context).size.width * 0.75; // Adjust the scroll distance as needed
                    if (newOffset > maxWidth) {
                      newOffset = maxWidth;
                    }
                    // Scroll to the new position
                    _scrollController.animateTo(newOffset,
                        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
