import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/Admin/add_product_screen.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget adminProductCardWidget(
    ItemModel itemModel, BuildContext context, String id) {
  return InkWell(
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                itemModel.thumbnailUrl[0],
                height: 280,
                width: 500,
                fit: BoxFit.contain,
              ),
              Positioned.fill(
                bottom: 200,
                left: 320,
                child: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            child: InkWell(
                                onTap: () {
                                  Route route = MaterialPageRoute(
                                      builder: (c) => AddProductScreen(
                                            editOrAdd: "Edit",
                                            productId: id,
                                          ));
                                  Navigator.push(context, route);
                                },
                                child: const Text("Edit")),
                            value: 1,
                          ),
                          PopupMenuItem(
                            child: InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor:
                                            const Color(0xFF1a1110),
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(32.0)),
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
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("items")
                                                            .doc(id)
                                                            .delete()
                                                            .then((value) => {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop()
                                                                });
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary:
                                                            Colors.red.shade800,
                                                      ),
                                                      child: Text(
                                                        "Delete",
                                                        style:
                                                            GoogleFonts.rubik(),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 15),
                                                  Expanded(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: const Color(
                                                            0xFF52CAF5),
                                                      ),
                                                      child: Text(
                                                        "Cancel",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
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
                                },
                                child: const Text("Delete")),
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
