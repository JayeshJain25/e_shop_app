import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_shop_app/Admin/admin_order_details_screen.dart';
import 'package:e_shop_app/model/cart_model.dart';
import 'package:e_shop_app/screens/order_details__screen.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class OrderCardWidget extends StatefulWidget {
  final String orderID;
  final int orderLength;
  final List<CartModel> productIds;
  final String type;

  const OrderCardWidget(
      {Key? key,
      required this.orderID,
      required this.orderLength,
      required this.productIds,
      required this.type})
      : super(key: key);

  @override
  State<OrderCardWidget> createState() => _OrderCardWidgetState();
}

class _OrderCardWidgetState extends State<OrderCardWidget> {
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.type != "history") {
          Route route;
          if (widget.type == "userAdminOrder") {
            route = MaterialPageRoute(
                builder: (c) => AdminOrderDetailsScreen(
                      orderID: widget.orderID,
                      type: widget.type,
                    ));
          } else {
            route = MaterialPageRoute(
                builder: (c) => OrderDetailsScreen(
                      orderID: widget.orderID,
                      type: widget.type,
                    ));
          }

          Navigator.push(context, route);
        }
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
        height: widget.orderLength * 190.0,
        child: ListView.builder(
          itemCount: widget.orderLength,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (c, index) {
            return sourceOrderInfo(widget.productIds[index], context,
                widget.productIds[index].itemCount);
          },
        ),
      ),
    );
  }
}

Widget sourceOrderInfo(CartModel model, BuildContext context, int count) {
  double width = MediaQuery.of(context).size.width;

  return Container(
    color: Colors.grey[100],
    height: 170.0,
    width: width,
    child: Row(
      children: [
        CachedNetworkImage(
          imageUrl: model.thumbnailUrl[0],
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
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
                              (model.price * model.itemCount).toString(),
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
                              r"Quantity: ",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              count.toString(),
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
