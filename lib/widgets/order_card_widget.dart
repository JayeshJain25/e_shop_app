import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/screens/order_details__screen.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

class OrderCardWidget extends StatelessWidget {
  final int itemCount;
  final List<DocumentSnapshot> data;
  final String orderID;
  final int orderLength;
  final List<String> productIds;
  final String type;
  

  const OrderCardWidget(
      {Key? key,
      required this.itemCount,
      required this.data,
      required this.orderID,
      required this.orderLength,
      required this.productIds,
      required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Route route;

        route = MaterialPageRoute(
            builder: (c) => OrderDetailsScreen(
                  orderID: orderID,
                  type: type,
                ));

        Navigator.push(context, route);
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
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.all(10.0),
        height: orderLength * 190.0,
        child: ListView.builder(
          itemCount: itemCount,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (c, index) {
            ItemModel model =
                ItemModel.fromJson(data[index].data() as Map<String, dynamic>);
            return productIds.contains(data[index].id)
                ? sourceOrderInfo(model, context)
                : Container();
          },
        ),
      ),
    );
  }
}

Widget sourceOrderInfo(ItemModel model, BuildContext context) {
  double width = MediaQuery.of(context).size.width;

  return Container(
    color: Colors.grey[100],
    height: 170.0,
    width: width,
    child: Row(
      children: [
        Image.network(
          model.thumbnailUrl[0],
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      model.title,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Text(
                      model.shortInfo,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Row(
                          children: [
                            const Text(
                              r"Total Price: ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                            const Text(
                              "₹ ",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16.0),
                            ),
                            Text(
                              (model.price).toString(),
                              style: const TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Flexible(
                child: Container(),
              ),
              const Divider(
                height: 5.0,
                color: kPrimaryColor,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
