import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'auth/role_selection.dart';
import 'owner/owner_home.dart';
import 'owner/my_houses.dart';
import 'owner/bookings.dart';
import 'owner/add_house.dart';
import 'visitor/visitor_home.dart';
import 'visitor/browse_houses.dart';
import 'visitor/house_details.dart';
import 'visitor/my_bookings.dart';
import 'visitor/book.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/selectRole': (context) => const RoleSelectionScreen(),
  '/ownerHome': (context) => const OwnerHome(),
  '/myHouses': (context) => const MyHousesScreen(),
  '/addHouse': (context) => const AddHouseScreen(),

  // Pass ownerId dynamically via route arguments
  '/bookings': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final ownerId = args?['ownerId'] ?? '';
    return OwnerBookingsScreen(ownerId: ownerId);
  },

  '/visitorHome': (context) => const VisitorHome(),
  '/browse_houses': (context) => BrowseHousesPage(),
  '/houseDetail': (context) => const HouseDetailsScreen(),
  '/myBookings': (context) => const MyBookingsScreen(),
  '/book': (context) => const BookScreen(),
};
