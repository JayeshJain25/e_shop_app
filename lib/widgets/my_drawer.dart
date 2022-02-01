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

import 'colors.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
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
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: Container(
              padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
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
                  Material(
                    borderRadius: const BorderRadius.all(Radius.circular(80.0)),
                    elevation: 8.0,
                    child: SizedBox(
                      height: 120.0,
                      width: 120.0,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          profileImg ??
                              "https://thumbs.dreamstime.com/b/default-avatar-profile-flat-icon-social-media-user-vector-portrait-unknown-human-image-default-avatar-profile-flat-icon-184330869.jpg",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    userName!.split(" ")[0].toCapitalized(),
                    style: const TextStyle(
                      color: kBackgroundColor,
                      fontSize: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 12.0,
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
                      Icons.home,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Home",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const HomeScreen(),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
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
                      Icons.reorder,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "My Orders",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const UserOrders(),
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
                      Icons.history,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "History",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) =>
                              const UserOrdersHistory(),
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
                      Icons.shopping_cart,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "My Cart",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => const CartScreen(),
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
                      Icons.favorite,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Wishlist",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Route route = MaterialPageRoute(
                          builder: (c) => const WishListScreen());
                      Navigator.push(context, route);
                    },
                  ),
                  const Divider(
                    height: 10.0,
                    color: kBackgroundColor,
                    thickness: 6.0,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.add_location,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Add New Address",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => AddAddress(
                            productCount: const [],
                            totalAmount: 0,
                            userId: userId!,
                            type: "no",
                            buyType: "",
                          ),
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
                      Icons.contact_mail,
                      color: kBackgroundColor,
                    ),
                    title: const Text(
                      "Contact",
                      style: TextStyle(color: kBackgroundColor),
                    ),
                    onTap: () async {
                      final Uri params = Uri(
                        scheme: 'mailto',
                        path: 'email@example.com',
                        query: 'subject=App Feedback&body=App Version 3.23',
                      );

                      var url = params.toString();
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
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
                    onTap: () {
                      FirebaseAuth.instance.signOut().then((c) {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) =>
                                const AuthenticateScreen(),
                          ),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      });
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
