import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/wishlist.dart';
import 'package:e_shop_app/providers/cart_provider.dart';
import 'package:e_shop_app/screens/address_screen.dart';
import 'package:e_shop_app/widgets/cart_product_card.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/loading_widget.dart';
import 'package:e_shop_app/widgets/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<String>? cartList = [];
  double totalAmount = 0;
  String? userId = '1';
  Future<void> userData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      userId = prefs.getString(EcommerceApp.userUID);
      cartList = prefs.getStringList(EcommerceApp.userCartList);
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
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
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
          "E_shop",
          style: TextStyle(
              fontSize: 25.0,
              color: kBackgroundColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final SharedPreferences prefs = await _prefs;
          if (prefs.getStringList(EcommerceApp.userCartList)!.isEmpty) {
            Fluttertoast.showToast(msg: "your Cart is empty.");
          } else {
            Route route = MaterialPageRoute(
                builder: (c) => AddressScreen(totalAmount: totalAmount));
            Navigator.push(context, route);
          }
        },
        label: const Text("Check Out"),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.navigate_next),
      ),
      drawer: const MyDrawer(),
      body: CustomScrollView(
        slivers: [
          cartList == null
              ? SliverToBoxAdapter(
                  child: Container(),
                )
              : SliverToBoxAdapter(
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, c) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: cartList!.isEmpty
                              ? Container()
                              : Text(
                                  "Total Price: ₹ ${cartProvider.totalAmount.toString()}",
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                        ),
                      );
                    },
                  ),
                ),
          userId == "1"
              ? const SliverToBoxAdapter(child: CircularProgressIndicator())
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(userId)
                      .collection("cart")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: circularProgress(),
                        ),
                      );
                    } else {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            WishListModel model = WishListModel.fromJson(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>);

                            if (index == 0) {
                              totalAmount = 0;
                              totalAmount = model.price + totalAmount;
                            } else {
                              totalAmount = model.price + totalAmount;
                            }

                            if (snapshot.data!.docs.length - 1 == index) {
                              WidgetsBinding.instance!
                                  .addPostFrameCallback((t) {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .display(totalAmount);
                              });
                            }

                            return cartProductCard(
                                snapshot.data!.docs[index].id,
                                model.productId,
                                userId!,
                                model,
                                context,
                                width);
                          },
                          childCount:
                              snapshot.hasData ? snapshot.data!.docs.length : 0,
                        ),
                      );
                    }
                  },
                ),
        ],
      ),
    );
  }
}
