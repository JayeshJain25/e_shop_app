import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/Admin/add_product_screen.dart';
import 'package:e_shop_app/Admin/user_product_screen.dart';
import 'package:e_shop_app/main.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/widgets/admin_drawer.dart';
import 'package:e_shop_app/widgets/admin_product_card_widget.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Future<bool?> showExitPopup(double width, double height) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a1110),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          content: SizedBox(
            height: height * 0.15,
            child: Column(
              children: [
                Text(
                  "Are you sure you want to exit?",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red.shade800,
                        ),
                        child: Text(
                          "Exit",
                          style: GoogleFonts.rubik(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xFF52CAF5),
                        ),
                        child: Text(
                          "Stay",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () {
        showExitPopup(width, height);
        return false as Future<bool>;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Home"),
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
        ),
        drawer: const AdminDrawer(),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("items")
              .orderBy("publishedDate")
              .snapshots(),
          builder: (c, snapshot) {
            return snapshot.hasData
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (c, index) {
                        ItemModel model = ItemModel.fromJson(
                            snapshot.data!.docs[index].data()!
                                as Map<String, dynamic>);
                        return adminProductCardWidget(
                            model, context, snapshot.data!.docs[index].id);
                      },
                    ),
                  )
                : Center(
                    child: circularProgress(),
                  );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: kPrimaryColor,
          onPressed: () {
            Route route = MaterialPageRoute(
                builder: (c) => const AddProductScreen(
                      editOrAdd: "Add",
                      productId: "1",
                    ));
            Navigator.push(context, route);
          },
        ),
      ),
    );
  }
}
