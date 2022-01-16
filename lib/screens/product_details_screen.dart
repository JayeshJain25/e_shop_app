import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/providers/cart_provider.dart';
import 'package:e_shop_app/providers/product_provider.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ItemModel itemModel;
  final String productId;
  const ProductDetailsScreen(
      {Key? key, required this.itemModel, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Product Detail",
            style: GoogleFonts.roboto(
              color: kBackgroundColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<ProductProvider>(builder: (ctx, data, _) {
              return IconButton(
                  onPressed: () {
                    data.favouriteUpdate(
                        userId!,
                        Provider.of<ProductProvider>(context, listen: false)
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
          backgroundColor: kPrimaryColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              CarouselSlider.builder(
                itemCount: widget.itemModel.thumbnailUrl.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) =>
                        SizedBox(
                  height: 300.0,
                  width: width * 0.8,
                  child: Center(
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(
                                      widget.itemModel.thumbnailUrl[itemIndex]),
                                  fit: BoxFit.cover)),
                        )),
                  ),
                ),
                options: CarouselOptions(
                  height: 300,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.itemModel.title,
                        style: boldTextStyle,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        widget.itemModel.longDescription,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "₹ " + widget.itemModel.price.toString(),
                        style: boldTextStyle,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      final SharedPreferences prefs = await _prefs;
                      if (cartList != null) {
                        if (cartList!.contains(widget.productId)) {
                          Fluttertoast.showToast(
                              msg: "Item is already in Cart.");
                        } else {
                          Provider.of<CartProvider>(context, listen: false)
                              .addCardItem(
                                  userId!, widget.itemModel, widget.productId)
                              .then((value) {
                            cartList!.add(widget.productId);
                            prefs.setStringList(
                                EcommerceApp.userCartList, cartList!);
                          });
                        }
                      } else {
                        cartList = [];
                        Provider.of<CartProvider>(context, listen: false)
                            .addCardItem(
                                userId!, widget.itemModel, widget.productId)
                            .then((value) {
                          cartList!.add(widget.productId);
                          prefs.setStringList(
                              EcommerceApp.userCartList, cartList!);
                        });
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
                      width: MediaQuery.of(context).size.width - 40.0,
                      height: 50.0,
                      child: const Center(
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(color: kBackgroundColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const boldTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const largeTextStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
