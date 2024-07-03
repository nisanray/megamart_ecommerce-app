import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:megamart/views/customers/nav_screens/account_screen.dart';
import 'package:megamart/views/customers/nav_screens/cart_screen.dart';
import 'package:megamart/views/customers/nav_screens/category_screen.dart';
import 'package:megamart/views/customers/nav_screens/home_screen.dart';
import 'package:megamart/views/customers/nav_screens/search_screen.dart';
import 'package:megamart/views/customers/nav_screens/store_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentPage = "Home";
  late Widget _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = HomeScreen();
  }

  void screenSelector(String route) {
    setState(() {
      switch (route) {
        case HomeScreen.routeName:
          _selectedItem = HomeScreen();
          _currentPage = "Home";
          break;
        case CategoryScreen.routeName:
          _selectedItem = CategoryScreen();
          _currentPage = "Categories";
          break;
        case CartScreen.routeName:
          _selectedItem = CartScreen(onContinueShopping: screenSelector);
          _currentPage = "Cart";
          break;
        case AccountScreen.routeName:
          _selectedItem = AccountScreen();
          _currentPage = "Account";
          break;
        case StoreScreen.routeName:
          _selectedItem = StoreScreen();
          _currentPage = "Store";
          break;
        case SearchScreen.routeName:
          _selectedItem = SearchScreen();
          _currentPage = "Search";
          break;
        default:
          _selectedItem = HomeScreen();
          _currentPage = "Home";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _pages.keys.toList().indexOf(_currentPage),
          onTap: (index) {
            screenSelector(_pages[_pages.keys.toList()[index]]!);
          },
          unselectedItemColor: Colors.deepPurpleAccent.shade400,
          selectedItemColor: Colors.amberAccent.shade700,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
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
              icon: Icon(CupertinoIcons.search),
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

  final Map<String, String> _pages = {
    "Home": HomeScreen.routeName,
    "Categories": CategoryScreen.routeName,
    "Store": StoreScreen.routeName,
    "Cart": CartScreen.routeName,
    "Search": SearchScreen.routeName,
    "Account": AccountScreen.routeName,
  };
}
