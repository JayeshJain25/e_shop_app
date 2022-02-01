import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/model/item.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  final String editOrAdd;
  final String productId;

  const AddProductScreen(
      {Key? key, required this.editOrAdd, required this.productId})
      : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<String>? _imageFileList = [];
  List<dynamic> imgeUrl = [];

  FirebaseStorage storage = FirebaseStorage.instance;

  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final TextEditingController _priceTextEditingController =
      TextEditingController();
  final TextEditingController _titleTextEditingController =
      TextEditingController();
  final TextEditingController _shortInfoTextEditingController =
      TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            widget.editOrAdd == "Add" ? "Add Product" : "Update Product",
            style: GoogleFonts.roboto(
              color: kBackgroundColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton.icon(
              icon: Icon(
                widget.editOrAdd == "Add" ? Icons.add : Icons.update,
                color: kBackgroundColor,
              ),
              label: Text(
                widget.editOrAdd == "Add" ? "Add" : "update",
                style: const TextStyle(
                  color: kBackgroundColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                if (_titleTextEditingController.text.isEmpty ||
                    _descriptionTextEditingController.text.isEmpty ||
                    _priceTextEditingController.text.isEmpty ||
                    _shortInfoTextEditingController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please fill all required fields"),
                  ));
                } else if (_imageFileList!.isEmpty &&
                    widget.editOrAdd == "Add") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Select atleast one image"),
                  ));
                } else {
                  showLoaderDialog(context);
                  uploadMultipleImages(imgeUrl);
                }
              },
            )
          ],
          backgroundColor: kPrimaryColor,
        ),
        body: widget.editOrAdd == "Edit"
            ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection("items")
                    .doc(widget.productId)
                    .get(),
                builder: (c, snapshot) {
                  if (snapshot.hasData) {
                    ItemModel model =
                        ItemModel.fromJson(snapshot.data!.data()!);
                    imgeUrl = model.thumbnailUrl;
                    return ListView(
                      children: [
                        model.thumbnailUrl.isEmpty && _imageFileList!.isEmpty
                            ? const SizedBox()
                            : CarouselSlider.builder(
                                itemCount: model.thumbnailUrl.length +
                                    _imageFileList!.length,
                                itemBuilder: (BuildContext context,
                                        int itemIndex, int pageViewIndex) =>
                                    SizedBox(
                                  height: 230.0,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child:
                                          model.thumbnailUrl.length > itemIndex
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: CachedNetworkImageProvider(
                                                              model.thumbnailUrl[
                                                                  itemIndex]),
                                                          fit: BoxFit.cover)),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: FileImage(File(
                                                              _imageFileList![
                                                                  itemIndex -
                                                                      model
                                                                          .thumbnailUrl
                                                                          .length])),
                                                          fit: BoxFit.cover)),
                                                ),
                                    ),
                                  ),
                                ),
                                options: CarouselOptions(
                                  height: 230,
                                  aspectRatio: 16 / 9,
                                  viewportFraction: 0.8,
                                  initialPage: 0,
                                  enableInfiniteScroll: false,
                                  reverse: false,
                                  autoPlay: false,
                                  autoPlayInterval: const Duration(seconds: 5),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  // onPageChanged: callbackFunction,
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            "Add Image",
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            getImage();
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(top: 12.0)),
                        ListTile(
                          leading: const Icon(
                            Icons.title,
                            color: kPrimaryColor,
                          ),
                          title: SizedBox(
                            width: 250.0,
                            child: TextField(
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent),
                              controller: _titleTextEditingController
                                ..text = model.title,
                              decoration: const InputDecoration(
                                hintText: "Title",
                                hintStyle:
                                    TextStyle(color: Colors.deepPurpleAccent),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          color: kPrimaryColor,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.short_text,
                            color: kPrimaryColor,
                          ),
                          title: SizedBox(
                            width: 250.0,
                            child: TextField(
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent),
                              controller: _shortInfoTextEditingController
                                ..text = model.shortInfo,
                              decoration: const InputDecoration(
                                hintText: "Short Info",
                                hintStyle:
                                    TextStyle(color: Colors.deepPurpleAccent),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          color: kPrimaryColor,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.description,
                            color: kPrimaryColor,
                          ),
                          title: SizedBox(
                            width: 250.0,
                            child: TextField(
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent),
                              controller: _descriptionTextEditingController
                                ..text = model.longDescription,
                              decoration: const InputDecoration(
                                hintText: "Description",
                                hintStyle:
                                    TextStyle(color: Colors.deepPurpleAccent),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          color: kPrimaryColor,
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.attach_money_outlined,
                            color: kPrimaryColor,
                          ),
                          title: SizedBox(
                            width: 250.0,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: Colors.deepPurpleAccent),
                              controller: _priceTextEditingController
                                ..text = model.price.toString(),
                              decoration: const InputDecoration(
                                hintText: "Price",
                                hintStyle:
                                    TextStyle(color: Colors.deepPurpleAccent),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(
                          color: kPrimaryColor,
                        )
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )
            : ListView(
                children: [
                  _imageFileList!.isEmpty
                      ? const SizedBox()
                      : CarouselSlider.builder(
                          itemCount: _imageFileList!.length,
                          itemBuilder: (BuildContext context, int itemIndex,
                                  int pageViewIndex) =>
                              SizedBox(
                            height: 230.0,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: FileImage(
                                              File(_imageFileList![itemIndex])),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                            ),
                          ),
                          options: CarouselOptions(
                            height: 230,
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.8,
                            initialPage: 0,
                            enableInfiniteScroll: false,
                            reverse: false,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 5),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            // onPageChanged: callbackFunction,
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.add,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      "Add Image",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      getImage();
                    },
                  ),
                  const Padding(padding: EdgeInsets.only(top: 12.0)),
                  ListTile(
                    leading: const Icon(
                      Icons.title,
                      color: kPrimaryColor,
                    ),
                    title: SizedBox(
                      width: 250.0,
                      child: TextField(
                        style: const TextStyle(color: Colors.deepPurpleAccent),
                        controller: _titleTextEditingController,
                        decoration: const InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: kPrimaryColor,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.short_text,
                      color: kPrimaryColor,
                    ),
                    title: SizedBox(
                      width: 250.0,
                      child: TextField(
                        style: const TextStyle(color: Colors.deepPurpleAccent),
                        controller: _shortInfoTextEditingController,
                        decoration: const InputDecoration(
                          hintText: "Short Info",
                          hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: kPrimaryColor,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.description,
                      color: kPrimaryColor,
                    ),
                    title: SizedBox(
                      width: 250.0,
                      child: TextField(
                        style: const TextStyle(color: Colors.deepPurpleAccent),
                        controller: _descriptionTextEditingController,
                        decoration: const InputDecoration(
                          hintText: "Description",
                          hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: kPrimaryColor,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.attach_money_outlined,
                      color: kPrimaryColor,
                    ),
                    title: SizedBox(
                      width: 250.0,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.deepPurpleAccent),
                        controller: _priceTextEditingController,
                        decoration: const InputDecoration(
                          hintText: "Price",
                          hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: kPrimaryColor,
                  )
                ],
              ));
  }

  Future getImage() async {
    try {
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFileList!.add(image!.path);
      });
    } catch (e) {
      print(e);
    }
  }

  Future uploadMultipleImages(List<dynamic> imgUrl) async {
    List<String> _imageUrls = [];
    if (_imageFileList!.isNotEmpty) {
      try {
        for (int i = 0; i < _imageFileList!.length; i++) {
          final Reference storageReference = storage.ref().child(
              "items/${_titleTextEditingController.text + i.toString()}");

          final UploadTask uploadTask =
              storageReference.putFile(File(_imageFileList![i]));

          await uploadTask.then((res) async {
            String imageUrl = await res.ref.getDownloadURL();
            _imageUrls.add(imageUrl);
          });
        }
        _imageUrls = [...imgeUrl, ..._imageUrls];
      } catch (e) {
        print(e);
      }
    } else {
      _imageUrls = List<String>.from(imgUrl);
    }

    widget.editOrAdd == "Add"
        ? saveItemInfo(_imageUrls)
        : updateItemInfo(_imageUrls);
  }

  updateItemInfo(List<String> downloadUrl) {
    final itemsRef =
        FirebaseFirestore.instance.collection("items").doc(widget.productId);
    itemsRef.update({
      "shortInfo": _shortInfoTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "price": int.parse(_priceTextEditingController.text),
      "status": "available",
      "thumbnailUrl": downloadUrl,
      "title": _titleTextEditingController.text.trim(),
      "caseSearch":
          setSearchParam(_titleTextEditingController.text.trim().toLowerCase()),
    });

    setState(() {
      _imageFileList!.clear();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _priceTextEditingController.clear();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Product Updated Sucessfully"),
    ));
  }

  saveItemInfo(List<String> downloadUrl) {
    final itemsRef = FirebaseFirestore.instance.collection("items");
    itemsRef.add({
      "shortInfo": _shortInfoTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "price": int.parse(_priceTextEditingController.text),
      "publishedDate": DateTime.now().millisecondsSinceEpoch,
      "status": "available",
      "thumbnailUrl": downloadUrl,
      "title": _titleTextEditingController.text.trim(),
      "caseSearch":
          setSearchParam(_titleTextEditingController.text.trim().toLowerCase()),
    });

    setState(() {
      _imageFileList!.clear();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _priceTextEditingController.clear();
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Product Added Sucessfully"),
    ));
  }

  setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }
}
