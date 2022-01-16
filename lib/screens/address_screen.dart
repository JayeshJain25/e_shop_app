import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/address.dart';
import 'package:e_shop_app/providers/change_address.dart';
import 'package:e_shop_app/screens/add_address_screen.dart';
import 'package:e_shop_app/screens/order_payment_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/loading_widget.dart';
import 'package:e_shop_app/widgets/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressScreen extends StatefulWidget {
  final double totalAmount;
  const AddressScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
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
    return SafeArea(
      child: Scaffold(
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
            "E_shop",
            style: TextStyle(
                fontSize: 25.0,
                color: kBackgroundColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Select Address",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            Consumer<AddressChanger>(builder: (context, address, c) {
              return Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(EcommerceApp.collectionUser)
                      .doc(userId)
                      .collection(EcommerceApp.subCollectionAddress)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return !snapshot.hasData
                        ? Center(
                            child: circularProgress(),
                          )
                        : snapshot.data!.docs.isEmpty
                            ? noAddressCard()
                            : ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return AddressCard(
                                    currentIndex: address.count,
                                    value: index,
                                    addressId: snapshot.data!.docs[index].id,
                                    totalAmount: widget.totalAmount,
                                    model: AddressModel.fromJson(
                                        snapshot.data!.docs[index].data()!
                                            as Map<String, dynamic>),
                                  );
                                },
                              );
                  },
                ),
              );
            }),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Add New Address"),
          backgroundColor: kPrimaryColor,
          icon: const Icon(Icons.add_location),
          onPressed: () {
            Route route = MaterialPageRoute(
                builder: (c) => AddAddress(
                      userId: userId!,
                      totalAmount: widget.totalAmount,
                    ));
            Navigator.pushReplacement(context, route);
          },
        ),
      ),
    );
  }

  noAddressCard() {
    return Card(
      color: kPrimaryColor.withOpacity(0.5),
      child: Container(
        height: 100.0,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_location,
              color: kBackgroundColor,
            ),
            Text("No shipment address has been saved.",
                textAlign: TextAlign.center),
            Text(
              "Please add your shipment Address so that we can deliver product.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatefulWidget {
  final AddressModel model;
  final String addressId;
  final double totalAmount;
  final int currentIndex;
  final int value;

  const AddressCard(
      {Key? key,
      required this.model,
      required this.currentIndex,
      required this.addressId,
      required this.totalAmount,
      required this.value})
      : super(key: key);

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Provider.of<AddressChanger>(context, listen: false)
            .displayResult(widget.value);
      },
      child: Card(
        color: kPrimaryColor.withOpacity(0.4),
        child: Column(
          children: [
            Row(
              children: [
                Radio(
                  groupValue: widget.currentIndex,
                  value: widget.value,
                  activeColor: kPrimaryColor,
                  onChanged: (val) {
                    Provider.of<AddressChanger>(context, listen: false)
                        .displayResult(int.parse(val.toString()));
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      width: screenWidth * 0.8,
                      child: Table(
                        children: [
                          TableRow(children: [
                            const KeyText(
                              msg: "Name",
                            ),
                            Text(widget.model.name),
                          ]),
                          TableRow(children: [
                            const KeyText(
                              msg: "Phone Number",
                            ),
                            Text(widget.model.phoneNumber),
                          ]),
                          TableRow(children: [
                            const KeyText(
                              msg: "Flat Number",
                            ),
                            Text(widget.model.flatNumber),
                          ]),
                          TableRow(children: [
                            const KeyText(
                              msg: "City",
                            ),
                            Text(widget.model.city),
                          ]),
                          TableRow(children: [
                            const KeyText(
                              msg: "State",
                            ),
                            Text(widget.model.state),
                          ]),
                          TableRow(children: [
                            const KeyText(
                              msg: "Pin Code",
                            ),
                            Text(widget.model.pincode),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            widget.value == Provider.of<AddressChanger>(context).count
                ? WideButton(
                    message: "Proceed",
                    onPressed: () {
                      Route route = MaterialPageRoute(
                          builder: (c) => OrderPaymentScreen(
                                addressId: widget.addressId,
                                totalAmount: widget.totalAmount,
                              ));
                      Navigator.push(context, route);
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class KeyText extends StatelessWidget {
  final String msg;

  const KeyText({Key? key, required this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
