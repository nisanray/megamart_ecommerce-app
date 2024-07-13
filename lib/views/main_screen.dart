import 'package:flutter/material.dart';
import 'package:megamart/views/nav_screens/account_screen.dart';
import 'package:megamart/views/nav_screens/cart_screen.dart';
import 'package:megamart/views/nav_screens/category_screen.dart';
import 'package:megamart/views/nav_screens/home_screen.dart';
import 'package:megamart/views/nav_screens/search_screen.dart';
import 'package:megamart/views/nav_screens/store_screen.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<MainScreenState> mainScreenKey = GlobalKey<MainScreenState>();

  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  MainScreenState createState() => MainScreenState();

  void navigateToCategoryScreen() {
    mainScreenKey.currentState?.navigateToCategoryScreen();
  }
}

class MainScreenState extends State<MainScreen> {
  late Widget _selectedItem;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _setSelectedItem(_selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _setSelectedItem(index);
    });
  }

  void _setSelectedItem(int index) {
    switch (index) {
      case 0:
        _selectedItem = const HomeScreen();
        break;
      case 1:
        _selectedItem = const CategoryScreen();
        break;
      case 2:
        _selectedItem = const StoreScreen();
        break;
      case 3:
        _selectedItem = const CartScreen();
        break;
      case 4:
        _selectedItem = const SearchScreen(searchQuery: ''); // Ensure empty query for initial load
        break;
      case 5:
        _selectedItem = const AccountScreen();
        break;
      default:
        _selectedItem = const HomeScreen();
    }
  }

  void _handleContinueShopping(String routeName) {
    print('Continue shopping action triggered for route: $routeName');
  }

  void navigateToCategoryScreen() {
    setState(() {
      _selectedIndex = 1; // Index for CategoryScreen
      _setSelectedItem(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          unselectedItemColor: Colors.deepPurpleAccent.shade400,
          selectedItemColor: Colors.amberAccent.shade700,
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
        body: _selectedItem,
      ),
    );
  }
}
