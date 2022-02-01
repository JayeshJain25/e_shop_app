import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/model/admin_user_orders_model.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/loading_widget.dart';
import 'package:e_shop_app/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text("Product"),
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
              pinned: true,
              floating: true,
              bottom: const TabBar(
                tabs: [
                  Tab(
                      child: Text(
                    'pending',
                    style: TextStyle(fontSize: 20),
                  )),
                  Tab(
                    child: Text(
                      'completed',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where("paymentDetails", whereIn: [
                  "Cash on Delivery",
                  "Online Payment Completed"
                ]).snapshots(),
                builder: (c, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) {
                            AdminUserOrdersModel orders =
                                AdminUserOrdersModel.fromJson(
                                    snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>);
                            return OrderCardWidget(
                              orderID: snapshot.data!.docs[index].id,
                              orderLength: orders.productIDs.length,
                              productIds: orders.productIDs,
                              type: "userAdminOrder",
                            );
                          })
                      : const SizedBox();
                }),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where("paymentDetails", whereIn: [
                  "Cash on Delivery Completed",
                  "Online Payment Done"
                ]).snapshots(),
                builder: (c, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) {
                            AdminUserOrdersModel orders =
                                AdminUserOrdersModel.fromJson(
                                    snapshot.data!.docs[index].data()!
                                        as Map<String, dynamic>);
                            return OrderCardWidget(
                              orderID: snapshot.data!.docs[index].id,
                              orderLength: orders.productIDs.length,
                              productIds: orders.productIDs,
                              type: "userAdminOrder",
                            );
                          })
                      : const SizedBox();
                }),
          ],
        ),
      )),
    );
  }
}
