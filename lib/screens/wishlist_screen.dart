import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/model/wishlist.dart';
import 'package:e_shop_app/providers/product_provider.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/user_home_product_card_widget.dart';
import 'package:e_shop_app/widgets/user_wishlist_product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? userId = '1';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        title: Text(
          "WishList",
          style: GoogleFonts.roboto(fontSize: 30.0, color: kBackgroundColor),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("wishlist")
            .orderBy("publishedDate", descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          return (snap.connectionState == ConnectionState.waiting)
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: snap.data!.docs.length,
                    itemBuilder: (context, index) {
                      WishListModel model = WishListModel.fromJson(
                          snap.data!.docs[index].data()!
                              as Map<String, dynamic>);

                      return UserWishlistProductCardWidget(
                        itemModel: model,
                        context: context,
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
