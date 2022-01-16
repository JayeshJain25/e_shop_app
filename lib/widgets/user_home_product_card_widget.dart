import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/providers/product_provider.dart';
import 'package:e_shop_app/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHomeProductCardWidget extends StatefulWidget {
  final ItemModel itemModel;
  final BuildContext context;
  final String productId;

  const UserHomeProductCardWidget(
      {Key? key,
      required this.itemModel,
      required this.context,
      required this.productId})
      : super(key: key);

  @override
  State<UserHomeProductCardWidget> createState() =>
      _UserHomeProductCardWidgetState();
}

class _UserHomeProductCardWidgetState extends State<UserHomeProductCardWidget> {
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: () {
        Route route = MaterialPageRoute(
            builder: (c) => ProductDetailsScreen(
                  itemModel: widget.itemModel,
                  productId: widget.productId,
                ));
        Navigator.push(context, route);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.itemModel.thumbnailUrl[0],
                height: 80,
                width: width,
                fit: BoxFit.contain,
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    widget.itemModel.title,
                    maxLines: 1,
                    style: GoogleFonts.rubik(fontSize: 18),
                  ),
                  Consumer<ProductProvider>(builder: (ctx, data, _) {
                    return IconButton(
                        onPressed: () {
                          data.favouriteUpdate(
                              userId!,
                              Provider.of<ProductProvider>(context,
                                      listen: false)
                                  .wishListModel
                                  .where((element) =>
                                      element.productId == widget.productId)
                                  .isNotEmpty,
                              widget.itemModel,
                              widget.productId);
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: data.wishListModel
                                  .where((element) =>
                                      element.productId == widget.productId)
                                  .isNotEmpty
                              ? Colors.amberAccent
                              : Colors.grey,
                        ));
                  })
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              AutoSizeText(
                "\u20B9 ${widget.itemModel.price}",
                maxLines: 1,
                style: GoogleFonts.nunito(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
