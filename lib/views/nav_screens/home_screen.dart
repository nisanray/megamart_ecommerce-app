import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megamart/views/nav_screens/widgets/banner_widget.dart';
import 'package:megamart/views/nav_screens/widgets/category_text.dart';
import 'package:megamart/views/nav_screens/widgets/search_input_widget.dart';
import '../product/product_detail_page.dart';
import 'search_screen.dart'; // Import the SearchScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToSearchScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(searchQuery: _searchQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: SearchInputWidget(
                    controller: _searchController,
                    onSubmitted: () => _navigateToSearchScreen(context),
                  ),
                ),
              ),
              expandedHeight: 100,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const BannerWidget(),
                  const CategoryText(),
                  const SizedBox(height: 20),
                  _buildRandomProducts(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomProducts(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        var products = snapshot.data!.docs;
        products.shuffle(); // Shuffle the list to show random products

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            var productName = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Product Name')['value'];
            var productPrice = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Regular Price')['value'];
            var productImageUrl = product['fixedFields']
                .firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(product: product),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: productImageUrl.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.network(
                          productImageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.fitHeight,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          },
                        ),
                      )
                          : Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.grey,
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        productName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$$productPrice',
                        style: const TextStyle(color: Colors.green, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
