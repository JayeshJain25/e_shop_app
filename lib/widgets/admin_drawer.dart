import 'package:e_shop_app/Admin/admin_settings.dart';
import 'package:e_shop_app/Admin/user_product_screen.dart';
import 'package:e_shop_app/authentication/authenticate_screen.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/screens/add_address_screen.dart';
import 'package:e_shop_app/screens/cart_screen.dart';
import 'package:e_shop_app/screens/home_screen.dart';
import 'package:e_shop_app/screens/user_orders.dart';
import 'package:e_shop_app/screens/user_orders_history.dart';
import 'package:e_shop_app/screens/wishlist_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'colors.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? userName = '';
  String? profileImg =
      'https://thumbs.dreamstime.com/b/default-avatar-profile-flat-icon-social-media-user-vector-portrait-unknown-human-image-default-avatar-profile-flat-icon-184330869.jpg';
  String? userId = "1";

  void userData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      userName = prefs.getString(EcommerceApp.userName);
      profileImg = prefs.getString(EcommerceApp.userAvatarUrl);
      userId = prefs.getString(EcommerceApp.userUID);
    });
  }

  @override
  void initState() {
    super.initState();
    userData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(5.0),
          bottomRight: Radius.circular(5.0),
        ),
      ),
      width: width / 1.4,
      child: ListView(
        children: [
          const SizedBox(
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: Container(
              padding: const EdgeInsets.only(top: 1.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kPrimaryColor],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.reorder,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Orders",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              const UserProductScreen(),
                        ),
                        (route) =>
                            true, //if you want to disable back feature set to false
                      );
                    },
                  ),
                  const Divider(
                    height: 10.0,
                    color: kBackgroundColor,
                    thickness: 6.0,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Settings",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () async {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              const AdminSettings(),
                        ),
                        (route) =>
                            true, //if you want to disable back feature set to false
                      );
                    },
                  ),
                  const Divider(
                    height: 10.0,
                    color: kBackgroundColor,
                    thickness: 6.0,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.exit_to_app,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () async {
                      final Future<SharedPreferences> _prefs =
                          SharedPreferences.getInstance();

                      final SharedPreferences prefs = await _prefs;
                      prefs.setBool("adminLogined", false);
                      Route route = MaterialPageRoute(
                          builder: (c) => const SplashScreen());
                      Navigator.pushReplacement(context, route);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}
