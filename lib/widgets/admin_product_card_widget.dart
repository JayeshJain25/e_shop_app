import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/Admin/add_product_screen.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget adminProductCardWidget(
    ItemModel itemModel, BuildContext context, String id) {
  Size _screenSize = MediaQuery.of(context).size;

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  return InkWell(
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: itemModel.thumbnailUrl[0],
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                height: 280,
                width: 500,
                fit: BoxFit.contain,
              ),
              Positioned(
                top: _screenSize.height * 0.02,
                right: _screenSize.width * 0.02,
                child: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (selection) {
                      switch (selection) {
                        case 1:
                          Route route = MaterialPageRoute(
                              builder: (c) => AddProductScreen(
                                    editOrAdd: "Edit",
                                    productId: id,
                                  ));
                          Navigator.push(context, route);
                          break;
                        case 2:
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: const Color(0xFF1a1110),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(32.0)),
                                ),
                                content: SizedBox(
                                  height: 150,
                                  child: Column(
                                    children: [
                                      Text(
                                        "Are you sure you want to delete it?",
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
                                                Navigator.of(context).pop();
                                                showLoaderDialog(context);
                                                FirebaseFirestore.instance
                                                    .collection("items")
                                                    .doc(id)
                                                    .delete()
                                                    .then((value) => {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .get()
                                                              .then((value) {
                                                            if (value.docs
                                                                .isNotEmpty) {
                                                              value.docs.forEach(
                                                                  (element) {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(element
                                                                        .id)
                                                                    .collection(
                                                                        "cart")
                                                                    .where(
                                                                        "productId",
                                                                        isEqualTo:
                                                                            id)
                                                                    .get()
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              if (value.docs.isNotEmpty)
                                                                                {
                                                                                  FirebaseFirestore.instance.collection("users").doc(element.id).collection("cart").doc(value.docs[0].id).delete().then((value) => {})
                                                                                }
                                                                            });
                                                              });
                                                            }
                                                          })
                                                        });

                                                FirebaseFirestore.instance
                                                    .collection("items")
                                                    .doc(id)
                                                    .delete()
                                                    .then((value) => {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "users")
                                                              .get()
                                                              .then((value) {
                                                            if (value.docs
                                                                .isNotEmpty) {
                                                              value.docs.forEach(
                                                                  (element) {
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "users")
                                                                    .doc(element
                                                                        .id)
                                                                    .collection(
                                                                        "wishlist")
                                                                    .where(
                                                                        "productId",
                                                                        isEqualTo:
                                                                            id)
                                                                    .get()
                                                                    .then(
                                                                        (value) =>
                                                                            {
                                                                              if (value.docs.isNotEmpty)
                                                                                {
                                                                                  FirebaseFirestore.instance.collection("users").doc(element.id).collection("wishlist").doc(value.docs[0].id).delete().then((value) => {})
                                                                                }
                                                                            });
                                                              });
                                                            }
                                                          })
                                                        });

                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red.shade800,
                                              ),
                                              child: Text(
                                                "Delete",
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
                                                primary:
                                                    const Color(0xFF52CAF5),
                                              ),
                                              child: Text(
                                                "Cancel",
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
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                          const PopupMenuItem(
                            child: Text("Edit"),
                            value: 1,
                          ),
                          const PopupMenuItem(
                            child: Text("Delete"),
                            value: 2,
                          ),
                        ]),
              ),
            ],
          ),
          ListTile(
            title: Text(
              itemModel.title,
              style: GoogleFonts.rubik(fontSize: 20),
            ),
            subtitle: Text(
              itemModel.shortInfo,
              style: GoogleFonts.rubik(fontSize: 17),
            ),
            trailing: Text(
              itemModel.price.toString(),
              style: GoogleFonts.nunito(fontSize: 15),
            ),
          ),
        ],
      ),
    ),
  );
}
