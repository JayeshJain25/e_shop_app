import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/address.dart';
import 'package:e_shop_app/screens/address_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAddress extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final cName = TextEditingController();
  final cPhoneNumber = TextEditingController();
  final cFlatHomeNumber = TextEditingController();
  final cCity = TextEditingController();
  final cState = TextEditingController();
  final cPinCode = TextEditingController();

  String userId;
  double totalAmount;

  AddAddress({Key? key, required this.userId, required this.totalAmount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
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
          "E_shop",
          style: TextStyle(
              fontSize: 25.0,
              color: kBackgroundColor,
              fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            final model = AddressModel(
              name: cName.text.trim(),
              state: cState.text.trim(),
              pincode: cPinCode.text,
              phoneNumber: cPhoneNumber.text,
              flatNumber: cFlatHomeNumber.text,
              city: cCity.text.trim(),
            ).toJson();

            //add to firestore
            FirebaseFirestore.instance
                .collection(EcommerceApp.collectionUser)
                .doc(userId)
                .collection(EcommerceApp.subCollectionAddress)
                .doc(DateTime.now().millisecondsSinceEpoch.toString())
                .set(model)
                .then((value) {
              const snack =
                  SnackBar(content: Text("New Address added successfully."));
              ScaffoldMessenger.of(context).showSnackBar(snack);
              FocusScope.of(context).requestFocus(FocusNode());
              formKey.currentState!.reset();
            });

            Route route = MaterialPageRoute(
                builder: (c) => AddressScreen(
                      totalAmount: totalAmount,
                    ));
            Navigator.pushReplacement(context, route);
          }
        },
        label: const Text("Done"),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.check),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Add New Address",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  MyTextField(
                    hint: "Name",
                    controller: cName,
                  ),
                  MyTextField(
                    hint: "Phone Number",
                    controller: cPhoneNumber,
                  ),
                  MyTextField(
                    hint: "Flat Number / House Number",
                    controller: cFlatHomeNumber,
                  ),
                  MyTextField(
                    hint: "City",
                    controller: cCity,
                  ),
                  MyTextField(
                    hint: "State / Country",
                    controller: cState,
                  ),
                  MyTextField(
                    hint: "Pin Code",
                    controller: cPinCode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;

  const MyTextField({
    Key? key,
    required this.hint,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        validator: (val) => val!.isEmpty ? "Field can not be empty." : null,
      ),
    );
  }
}
