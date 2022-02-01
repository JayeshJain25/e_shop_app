import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/screens/appbar_for_search.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/my_drawer.dart';
import 'package:e_shop_app/widgets/user_home_product_card_widget.dart';
import 'package:flutter/material.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({Key? key}) : super(key: key);

  @override
  _SearchProductScreenState createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  late Future<QuerySnapshot> docList;
  String query = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarForsearch(
          bottom: PreferredSize(
              child: searchWidget(), preferredSize: const Size(56.0, 56.0)),
        ),
        drawer: const MyDrawer(),
        body: StreamBuilder<QuerySnapshot>(
          stream: (query != "")
              ? FirebaseFirestore.instance
                  .collection("items")
                  .where("caseSearch", arrayContains: query.toLowerCase())
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection("items")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
          builder: (ctx, snap) {
            return (snap.connectionState == ConnectionState.waiting)
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount: snap.data!.docs.length,
                      itemBuilder: (context, index) {
                        ItemModel model = ItemModel.fromJson(
                            snap.data!.docs[index].data()!
                                as Map<String, dynamic>);

                        return UserHomeProductCardWidget(
                            itemModel: model,
                            context: context,
                            productId: snap.data!.docs[index].id);
                      },
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 1,
                      ),
                    ),
                  );
          },
        ));
  }

  Widget searchWidget() {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 80.0,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 10),
            blurRadius: 50,
            color: kPrimaryColor.withOpacity(0.23),
          ),
        ],
        gradient: const LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(1.0, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 45.0,
        height: 45.0,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.search,
                color: kPrimaryColor.withOpacity(0.5),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: "Search here...",
                    hintStyle: TextStyle(color: kPrimaryColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
