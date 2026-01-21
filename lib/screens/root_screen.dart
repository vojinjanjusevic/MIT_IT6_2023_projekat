import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_listings_screen.dart';
import 'profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    MyListingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.directions_car), label: 'Oglasi'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Moji oglasi'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}