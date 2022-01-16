import 'package:auto_size_text/auto_size_text.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/model/wishlist.dart';
import 'package:e_shop_app/providers/product_provider.dart';
import 'package:e_shop_app/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserWishlistProductCardWidget extends StatefulWidget {
  final WishListModel itemModel;
  final BuildContext context;

  const UserWishlistProductCardWidget({
    Key? key,
    required this.itemModel,
    required this.context,
  }) : super(key: key);

  @override
  State<UserWishlistProductCardWidget> createState() =>
      _UserWishlistProductCardWidgetState();
}

class _UserWishlistProductCardWidgetState
    extends State<UserWishlistProductCardWidget> {
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
        ItemModel itemModel = ItemModel(
            title: widget.itemModel.title,
            shortInfo: widget.itemModel.shortInfo,
            publishedDate: widget.itemModel.publishedDate,
            thumbnailUrl: widget.itemModel.thumbnailUrl,
            longDescription: widget.itemModel.longDescription,
            status: widget.itemModel.status,
            price: widget.itemModel.price);
        Route route = MaterialPageRoute(
            builder: (c) => ProductDetailsScreen(
                  itemModel: itemModel,
                  productId: widget.itemModel.productId,
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
                          ItemModel itemModel = ItemModel(
                              title: widget.itemModel.title,
                              shortInfo: widget.itemModel.shortInfo,
                              publishedDate: widget.itemModel.publishedDate,
                              thumbnailUrl: widget.itemModel.thumbnailUrl,
                              longDescription: widget.itemModel.longDescription,
                              status: widget.itemModel.status,
                              price: widget.itemModel.price);
                          data.favouriteUpdate(
                              userId!,
                              Provider.of<ProductProvider>(context,
                                      listen: false)
                                  .wishListModel
                                  .where((element) =>
                                      element.productId ==
                                      widget.itemModel.productId)
                                  .isNotEmpty,
                              itemModel,
                              widget.itemModel.productId);
                        },
                        icon: Icon(
                          Icons.favorite,
                          color: data.wishListModel
                                  .where((element) =>
                                      element.productId ==
                                      widget.itemModel.productId)
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
