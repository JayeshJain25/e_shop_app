import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/providers/product_provider.dart';
import 'package:e_shop_app/screens/cart_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/loading_widget.dart';
import 'package:e_shop_app/widgets/my_drawer.dart';
import 'package:e_shop_app/widgets/search_box.dart';
import 'package:e_shop_app/widgets/user_home_product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    userData().then((value) {
      Provider.of<ProductProvider>(context, listen: false)
          .getFavourite(userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "E-Shop App",
          style: GoogleFonts.roboto(fontSize: 30.0, color: kBackgroundColor),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () {
                  Route route =
                      MaterialPageRoute(builder: (c) => const CartScreen());
                  Navigator.push(context, route);
                },
              ),
              Positioned(
                child: Stack(
                  children: [
                    const Icon(
                      Icons.brightness_1,
                      size: 20.0,
                      color: kPrimaryColor,
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
              ),
            ],
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: const HomeMainScreen(),
    );
  }
}

class HomeMainScreen extends StatelessWidget {
  const HomeMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(delegate: SearchBoxDelegate()),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("items")
              .orderBy("publishedDate", descending: true)
              .snapshots(),
          builder: (context, dataSnapshot) {
            return !dataSnapshot.hasData
                ? SliverToBoxAdapter(
                    child: Center(
                      child: circularProgress(),
                    ),
                  )
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, index) {
                        ItemModel model = ItemModel.fromJson(
                            dataSnapshot.data!.docs[index].data()!
                                as Map<String, dynamic>);
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: UserHomeProductCardWidget(
                              itemModel: model,
                              context: context,
                              productId: dataSnapshot.data!.docs[index].id),
                        );
                      },
                      childCount: dataSnapshot.data!.docs.length,
                    ),
                  );
          },
        ),
      ],
    );
  }
}
