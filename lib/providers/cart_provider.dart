import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartProvider extends ChangeNotifier {
  double _totalAmount = 0;

  double get totalAmount => _totalAmount;

  display(double no) async {
    _totalAmount = no;

    await Future.delayed(const Duration(milliseconds: 100), () {
      notifyListeners();
    });
  }

  Future<void> addCardItem(
      String userId, ItemModel itemModel, String productId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("cart")
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
      Fluttertoast.showToast(msg: "Item Added to Cart Successfully.");
    });
  }

  Future<void> removeCartItem(String userId, String cartId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .doc(cartId)
        .delete()
        .then((value) {
      Fluttertoast.showToast(msg: "Item Deleted from Cart Successfully.");
    });
  }

  Future<void> clearCartItem(String userId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("cart")
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }
}
