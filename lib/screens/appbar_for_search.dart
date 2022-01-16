import 'package:e_shop_app/screens/home_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:flutter/material.dart';

class AppBarForsearch extends StatelessWidget with PreferredSizeWidget {
  final PreferredSizeWidget bottom;

  AppBarForsearch({Key? key, required this.bottom}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
        "Search Product",
        style: TextStyle(
            fontSize: 25.0,
            color: kBackgroundColor,
            fontWeight: FontWeight.bold),
      ),
      bottom: bottom,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart,
                color: kBackgroundColor,
              ),
              onPressed: () {
                // Route route = MaterialPageRoute(builder: (c) => CartPage());
                // Navigator.pushReplacement(context, route);
              },
            ),
            Positioned(
              child: Stack(
                children: [
                  const Icon(
                    Icons.brightness_1,
                    size: 20.0,
                    color: kPrimaryColor,
                  ),
                  Positioned(
                      top: 3.0,
                      bottom: 4.0,
                      left: 4.0,
                      child: Text(
                        (2).toString(),
                        style: const TextStyle(
                            color: kBackgroundColor,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => bottom == null
      ? Size(56, AppBar().preferredSize.height)
      : Size(56, 80 + AppBar().preferredSize.height);
}
