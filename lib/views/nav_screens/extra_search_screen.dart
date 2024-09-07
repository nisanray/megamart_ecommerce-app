import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main_screen.dart';
import '../product/product_detail_page.dart';
// import 'main_screen.dart'; // Import the MainScreen
import 'widgets/search_input_widget.dart'; // Import the SearchInputWidget

class ExtraSearchScreen extends StatefulWidget {
  // static const routeName = '/search';
  final String searchQuery;

  const ExtraSearchScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<ExtraSearchScreen> {
  late int _selectedIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIndex = 4; // Set the index for SearchScreen
    _searchController.text = widget.searchQuery.trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
    );
  }
  void _navigateToSearchScreen(BuildContext context, String query) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraSearchScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String trimmedQuery = _searchController.text.trim().toLowerCase();

    return Scaffold(
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
                  onSubmitted: () => _navigateToSearchScreen(context, _searchController.text),
                ),
              ),
            ),
            expandedHeight: 100,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder<QuerySnapshot>(
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

                    // Filter products based on the search query
                    products = products.where((product) {
                      var productName = product['fixedFields']
                          .firstWhere((field) => field['fieldName'] == 'Product Name')['value']
                          .toLowerCase()
                          .trim();
                      return productName.contains(trimmedQuery);
                    }).toList();

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
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.blueGrey,
        selectedItemColor: Colors.blueAccent.shade700,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: "Categories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Store",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
