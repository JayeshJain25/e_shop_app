import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/cart_model.dart';
import 'package:e_shop_app/providers/cart_provider.dart';
import 'package:e_shop_app/screens/home_screen.dart';
import 'package:e_shop_app/screens/user_orders.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPaymentScreen extends StatefulWidget {
  final String addressId;
  final double totalAmount;
  final List<CartModel> productCount;
  final String buyType;

  const OrderPaymentScreen(
      {Key? key,
      required this.addressId,
      required this.totalAmount,
      required this.productCount,
      required this.buyType})
      : super(key: key);

  @override
  State<OrderPaymentScreen> createState() => _OrderPaymentScreenState();
}

class _OrderPaymentScreenState extends State<OrderPaymentScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? userId = '';
  String? email = '';
  String? name = '';
  bool fetchedData = false;

  List<String>? cartList = [];
  late Razorpay razorpay;
  var msg;
  bool cashOnDelivery = true;
  String paymentOption = 'onlinePayment';

  Future<void> userData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      userId = prefs.getString(EcommerceApp.userUID);
      email = prefs.getString(EcommerceApp.userEmail);

      name = prefs.getString(EcommerceApp.userName);
      cartList = prefs.getStringList(EcommerceApp.userCartList);
    });
  }

  List count = [];

  @override
  void initState() {
    super.initState();
    userData();
    widget.productCount.forEach((e) {
      count.add({
        "title": e.title,
        "shortInfo": e.shortInfo,
        "publishedDate": e.publishedDate,
        "thumbnailUrl": e.thumbnailUrl,
        "longDescription": e.longDescription,
        "status": e.status,
        "price": e.price,
        "productId": e.productId,
        "itemCount": e.itemCount
      });
    });

    FirebaseFirestore.instance.collection("admins").get().then((snapshot) {
      for (var result in snapshot.docs) {
        cashOnDelivery = result.data()["cashOnDelivery"];
        setState(() {
          fetchedData = true;
        });
      }
    });
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
                child: Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/shop-app-16b5b.appspot.com/o/cash.png?alt=media&token=7cac504a-127c-4a9c-8a50-553311c8f5c6"),
              ),
              const SizedBox(
                height: 10.0,
              ),
              if (fetchedData)
                Column(
                  children: [
                    ListTile(
                      leading: Radio<String>(
                        value: 'cashOnDelivery',
                        groupValue: paymentOption,
                        onChanged: (value) {
                          cashOnDelivery
                              ? setState(() {
                                  paymentOption = value!;
                                })
                              : null;
                        },
                      ),
                      title: const Text('Cash On Delivery'),
                    ),
                    ListTile(
                      leading: Radio<String>(
                        value: 'onlinePayment',
                        groupValue: paymentOption,
                        onChanged: (value) {
                          setState(() {
                            paymentOption = value!;
                          });
                        },
                      ),
                      title: const Text('Online Payment'),
                    ),
                  ],
                ),
              const SizedBox(
                height: 25,
              ),
              TextButton(
                onPressed: () {
                  paymentOption == "cashOnDelivery"
                      ? addOrderDetails(widget.buyType)
                      : openCheckout();
                },
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

  addOrderDetails(String buyType) {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    writeOrderDetailsForUser({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": userId,
      EcommerceApp.productData: count,
      EcommerceApp.paymentDetails: paymentOption == "cashOnDelivery"
          ? "Cash on Delivery"
          : "Online Payment Completed",
      EcommerceApp.orderTime: time,
      EcommerceApp.isSuccess: true,
    });

    writeOrderDetailsForAdmin({
      EcommerceApp.addressID: widget.addressId,
      EcommerceApp.totalAmount: widget.totalAmount,
      "orderBy": userId,
      EcommerceApp.productData: count,
      EcommerceApp.paymentDetails: paymentOption == "cashOnDelivery"
          ? "Cash on Delivery"
          : "Online Payment Completed",
      EcommerceApp.orderTime: time,
      EcommerceApp.isSuccess: true,
      "orderId": userId! + time,
    }).whenComplete(() => {emptyCartNow(buyType)});
  }

  emptyCartNow(String buyType) {
    if (buyType == "cart") {
      Provider.of<CartProvider>(context, listen: false)
          .clearCartItem(userId!)
          .then((value) async {
        final SharedPreferences prefs = await _prefs;
        prefs.setStringList(EcommerceApp.userCartList, []);
      });
    }

    Fluttertoast.showToast(
        msg: "Congratulations, your Order has been placed successfully.");

    Route route = MaterialPageRoute(builder: (c) => const UserOrders());
    Navigator.of(context).pushAndRemoveUntil(
        route, (Route<dynamic> route) => route is HomeScreen);
  }

  Future writeOrderDetailsForUser(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(EcommerceApp.collectionUser)
        .doc(userId)
        .collection(EcommerceApp.collectionOrders)
        .doc(userId! + data['orderTime'])
        .set(data);
  }

  Future writeOrderDetailsForAdmin(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(EcommerceApp.collectionOrders)
        .doc(userId! + data['orderTime'])
        .set(data);
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_9M5fXCl1SstMHP",
      "amount": widget.totalAmount * 100, // Convert Paisa to Rupees
      "name": name,
      "description": "Product Payment Screen",
      "timeout": "180",
      "theme.color": "#03be03",
      "currency": "INR",
      "prefill": {"email": email},
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Pament success");
    msg = "SUCCESS: " + response.paymentId!;
    showToast(msg);
    addOrderDetails(widget.buyType);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message!,
        timeInSecForIosWeb: 4);
    print(response.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!, timeInSecForIosWeb: 4);
    print(response.toString());
  }

  showToast(msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.withOpacity(0.1),
      textColor: Colors.black54,
    );
  }
}
