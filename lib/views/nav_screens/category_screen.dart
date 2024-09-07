import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_products_page.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  static const routeName = '/categories';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories found.'));
          }

          var categories = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsPage(
                        category: category as QueryDocumentSnapshot<Map<String, dynamic>>,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.blue.shade100,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      if (category['categoryImageUrl'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            category['categoryImageUrl'],
                            height: 100,
                            // width: double.infinity,
                            // fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        category['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      // Text(
                      //   category['description'],
                      //   style: const TextStyle(fontSize: 14),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
