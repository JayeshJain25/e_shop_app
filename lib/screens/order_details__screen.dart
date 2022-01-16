import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/address.dart';
import 'package:e_shop_app/screens/address_screen.dart';
import 'package:e_shop_app/screens/user_orders_history.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/loading_widget.dart';
import 'package:e_shop_app/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getOrderId = "";

class OrderDetailsScreen extends StatefulWidget {
  final String orderID;
  final String type;

  const OrderDetailsScreen(
      {Key? key, required this.orderID, required this.type})
      : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
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
    getOrderId = widget.orderID;
    return Scaffold(
      appBar: AppBar(
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
          "My Orders",
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection(EcommerceApp.collectionUser)
              .doc(userId)
              .collection(EcommerceApp.collectionOrders)
              .doc(widget.orderID)
              .get(),
          builder: (c, snapshot) {
            Map dataMap = {};
            if (snapshot.hasData) {
              dataMap = snapshot.data!.data() as Map<String, dynamic>;
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  StatusBanner(
                    status: dataMap[EcommerceApp.isSuccess],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "₹ " + dataMap[EcommerceApp.totalAmount].toString(),
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Order ID: " + getOrderId),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "Ordered at: " +
                          DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(dataMap["orderTime"]))),
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 16.0),
                    ),
                  ),
                  const Divider(
                    height: 2.0,
                  ),
                  // FutureBuilder<QuerySnapshot>(
                  //   future:
                  //       FirebaseFirestore.instance.collection("items").get(),
                  //   builder: (c, dataSnapshot) {
                  //     return dataSnapshot.hasData
                  //         ? OrderCardWidget(
                  //             itemCount: dataSnapshot.data!.docs.length,
                  //             data: dataSnapshot.data!.docs,
                  //             orderID: widget.orderID,
                  //             orderLength: dataMap["productIDs"].length,
                  //             productIds:
                  //                 List<String>.from(dataMap["productIDs"]),
                  //           )
                  //         : Center(
                  //             child: circularProgress(),
                  //           );
                  //   },
                  // ),
                  const Divider(
                    height: 2.0,
                  ),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection(EcommerceApp.collectionUser)
                        .doc(userId)
                        .collection(EcommerceApp.subCollectionAddress)
                        .doc(dataMap[EcommerceApp.addressID])
                        .get(),
                    builder: (c, snap) {
                      return snap.hasData
                          ? ShippingDetails(
                              model: AddressModel.fromJson(
                                  snap.data!.data() as Map<String, dynamic>),
                            )
                          : Center(
                              child: circularProgress(),
                            );
                    },
                  ),
                ],
              );
            } else {
              return Center(
                child: circularProgress(),
              );
            }
          },
        ),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  final bool status;

  const StatusBanner({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData iconData;

    status ? iconData = Icons.done : iconData = Icons.cancel;
    status ? msg = "Successful" : msg = "UnSuccessful";

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Order Placed " + msg,
            style: const TextStyle(color: kBackgroundColor),
          ),
          const SizedBox(
            width: 5.0,
          ),
          CircleAvatar(
            radius: 8.0,
            backgroundColor: Colors.grey,
            child: Center(
              child: Icon(
                iconData,
                color: kBackgroundColor,
                size: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShippingDetails extends StatelessWidget {
  final AddressModel model;

  const ShippingDetails({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20.0,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Text(
            "Shipment Details:",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 5.0),
          width: screenWidth,
          child: Table(
            children: [
              TableRow(children: [
                const KeyText(
                  msg: "Name",
                ),
                Text(model.name),
              ]),
              TableRow(children: [
                const KeyText(
                  msg: "Phone Number",
                ),
                Text(model.phoneNumber),
              ]),
              TableRow(children: [
                const KeyText(
                  msg: "Flat Number",
                ),
                Text(model.flatNumber),
              ]),
              TableRow(children: [
                const KeyText(
                  msg: "City",
                ),
                Text(model.city),
              ]),
              TableRow(children: [
                const KeyText(
                  msg: "State",
                ),
                Text(model.state),
              ]),
              TableRow(children: [
                const KeyText(
                  msg: "Pin Code",
                ),
                Text(model.pincode),
              ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: () {
                confirmedUserOrderReceived(context, getOrderId);
              },
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor],
                    begin: FractionalOffset(0.0, 0.0),
                    end: FractionalOffset(1.0, 0.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp,
                  ),
                ),
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                child: const Center(
                  child: Text(
                    "Confirmed || Items Received",
                    style: TextStyle(
                      color: kBackgroundColor,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  confirmedUserOrderReceived(BuildContext context, String mOrderId) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    String? userId = '';

    final SharedPreferences prefs = await _prefs;

    userId = prefs.getString(EcommerceApp.userUID);

    FirebaseFirestore.instance
        .collection(EcommerceApp.collectionUser)
        .doc(userId)
        .collection(EcommerceApp.collectionOrders)
        .doc(mOrderId)
        .delete();

    Fluttertoast.showToast(msg: "Order has been Received. Confirmed.")
        .whenComplete(() {
      Route route =
          MaterialPageRoute(builder: (c) => const UserOrdersHistory());
      Navigator.pushReplacement(context, route);
    });
  }
}
