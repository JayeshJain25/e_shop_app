import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/providers/cart_provider.dart';
import 'package:e_shop_app/screens/user_orders.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPaymentScreen extends StatefulWidget {
  final String addressId;
  final double totalAmount;

  const OrderPaymentScreen({
    Key? key,
    required this.addressId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? userId = '';
  List<String>? cartList = [];

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
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
            begin: FractionalOffset(0.0, 0.0),
            end: FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset("assets/images/cash.png"),
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextButton(
                onPressed: () => addOrderDetails(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  textStyle: const TextStyle(color: Colors.white),
                  padding: const EdgeInsets.all(8.0),
                ),
                child: const Text(
                  "Place Order",
                  style: TextStyle(fontSize: 30.0, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  addOrderDetails() {
    writeOrderDetailsForHistory({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": userId,
      EcommerceApp.productID: cartList,
      EcommerceApp.paymentDetails: "Cash on Delivery Completed",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    });

    writeOrderDetailsForUser({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": userId,
      EcommerceApp.productID: cartList,
      EcommerceApp.paymentDetails: "Cash on Delivery",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    });

    writeOrderDetailsForAdmin({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": userId,
      EcommerceApp.productID: cartList,
      EcommerceApp.paymentDetails: "Cash on Delivery",
      EcommerceApp.orderTime: DateTime.now().millisecondsSinceEpoch.toString(),
      EcommerceApp.isSuccess: true,
    }).whenComplete(() => {emptyCartNow()});
  }

  emptyCartNow() {
    Provider.of<CartProvider>(context, listen: false)
        .clearCartItem(userId!)
        .then((value) async {
      final SharedPreferences prefs = await _prefs;
      prefs.setStringList(EcommerceApp.userCartList, []);
    });

    Fluttertoast.showToast(
        msg: "Congratulations, your Order has been placed successfully.");

    Route route = MaterialPageRoute(builder: (c) => const UserOrders());
    Navigator.pushReplacement(context, route);
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(EcommerceApp.collectionUser)
        .doc(userId)
        .collection(EcommerceApp.collectionOrders)
        .doc(userId! + data['orderTime'])
        .set(data);
  }

  Future writeOrderDetailsForHistory(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(EcommerceApp.collectionUser)
        .doc(userId)
        .collection(EcommerceApp.collectionHistory)
        .doc(userId! + data['orderTime'])
        .set(data);
  }

  Future writeOrderDetailsForAdmin(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(EcommerceApp.collectionOrders)
        .doc(userId! + data['orderTime'])
        .set(data);
  }
}
