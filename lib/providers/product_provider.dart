import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/model/wishlist.dart';
import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  List<WishListModel> wishListModel = [];

  Future<void> favouriteUpdate(String userId, bool isFavourite,
      ItemModel itemModel, String productId) async {
    if (isFavourite) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("wishlist")
          .where("productId", isEqualTo: productId)
          .get()
          .then((value) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("wishlist")
            .doc(value.docs[0].id)
            .delete()
            .then((value) {
          wishListModel
              .removeWhere((element) => element.productId == productId);

          notifyListeners();
        });
      });
    } else {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("wishlist")
          .add({
        "shortInfo": itemModel.shortInfo,
        "longDescription": itemModel.longDescription,
        "price": itemModel.price,
        "publishedDate": itemModel.publishedDate,
        "status": "available",
        "thumbnailUrl": itemModel.thumbnailUrl,
        "title": itemModel.title,
        "productId": productId,
      }).then((value) {
        WishListModel listModel = WishListModel(
            title: itemModel.title,
            shortInfo: itemModel.shortInfo,
            publishedDate: itemModel.publishedDate,
            thumbnailUrl: itemModel.thumbnailUrl,
            longDescription: itemModel.longDescription,
            status: itemModel.status,
            price: itemModel.price,
            productId: productId);
        wishListModel.add(listModel);
        notifyListeners();
      });
    }
  }

  Future<void> getFavourite(String userId) async {
    wishListModel.clear();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("wishlist")
        .get()
        .then((value) => {
              if (value.docs.isNotEmpty)
                {
                  // ignore: avoid_function_literals_in_foreach_calls
                  value.docs.forEach((element) {
                    WishListModel listModel =
                        WishListModel.fromJson(element.data());
                    wishListModel.add(listModel);
                  })
                }
            });
    notifyListeners();
  }
}
