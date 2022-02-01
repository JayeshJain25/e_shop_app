import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/screens/cart_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarForsearch extends StatefulWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;

  AppBarForsearch({Key? key, required this.bottom}) : super(key: key);

  @override
  State<AppBarForsearch> createState() => _AppBarForsearchState();

  @override
  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}

class _AppBarForsearchState extends State<AppBarForsearch> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? userId = '';

  Future<void> userData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
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
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kPrimaryColor, kPrimaryColor],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
      ),
      centerTitle: true,
      title: const Text(
        "Search Product",
        style: TextStyle(
            fontSize: 25.0,
            color: kBackgroundColor,
            fontWeight: FontWeight.bold),
      ),
      bottom: widget.bottom,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart,
                color: kBackgroundColor,
              ),
              onPressed: () {
                Route route =
                    MaterialPageRoute(builder: (c) => const CartScreen());
                Navigator.pushReplacement(context, route);
              },
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .doc(userId)
                    .collection("cart")
                    .snapshots(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    return Positioned(
                      top: 3.0,
                      bottom: 4.0,
                      left: 4.0,
                      child: Text(
                        (snap.data!.docs.length).toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                })
          ],
        ),
      ],
    );
  }
}
