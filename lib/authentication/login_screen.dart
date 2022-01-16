import 'package:e_shop_app/Admin/admin_login.dart';
import 'package:e_shop_app/DialogBox/error_dialog.dart';
import 'package:e_shop_app/DialogBox/loading_dialog.dart';
import 'package:e_shop_app/config/config.dart';
import 'package:e_shop_app/model/wishlist.dart';
import 'package:e_shop_app/screens/home_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/images/login.png",
              height: 240.0,
              width: 240.0,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Login to your account",
              style: TextStyle(color: kBackgroundColor),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  _emailTextEditingController,
                  Icons.email,
                  "Email",
                  false,
                ),
                CustomTextField(
                  _passwordTextEditingController,
                  Icons.person,
                  "Password",
                  true,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _emailTextEditingController.text.isNotEmpty &&
                      _passwordTextEditingController.text.isNotEmpty
                  ? loginUser()
                  : showDialog(
                      context: context,
                      builder: (c) {
                        return const ErrorAlertDialog(
                          message: "Please write email and password.",
                        );
                      });
            },
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(kBackgroundColor),
            ),
            child: const Text(
              "Login",
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
          const SizedBox(
            height: 50.0,
          ),
          Container(
            height: 4.0,
            width: _screenWidth * 0.8,
            color: kBackgroundColor,
          ),
          const SizedBox(
            height: 10.0,
          ),
          TextButton.icon(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AdminSignInPage())),
            icon: (const Icon(
              Icons.nature_people,
              color: kBackgroundColor,
            )),
            label: const Text(
              "i'm Admin",
              style: TextStyle(
                  color: kBackgroundColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  void loginUser() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingAlertDialog(
            message: "Authenticating, Please wait...",
          );
        });
    User firebaseUser;
    await _auth
        .signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    )
        .then((authUser) {
      firebaseUser = authUser.user!;
      readData(firebaseUser).then((s) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.pushReplacement(context, route);
      });
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });
  }

  Future readData(User fUser) async {
    final SharedPreferences prefs = await _prefs;
    List<String> cartList = [];
    FirebaseFirestore.instance
        .collection("users")
        .doc(fUser.uid)
        .get()
        .then((dataSnapshot) async {
      print(dataSnapshot.data()![EcommerceApp.userUID]);
      await prefs.setString("uid", dataSnapshot.data()![EcommerceApp.userUID]);

      await prefs.setString(
          EcommerceApp.userEmail, dataSnapshot.data()![EcommerceApp.userEmail]);

      await prefs.setString(
          EcommerceApp.userName, dataSnapshot.data()![EcommerceApp.userName]);

      // await prefs.setString(EcommerceApp.userAvatarUrl,
      //     dataSnapshot.data()![EcommerceApp.userAvatarUrl]);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(fUser.uid)
          .collection("cart")
          .get()
          .then((value) => {
                if (value.docs.isNotEmpty)
                  {
                    // ignore: avoid_function_literals_in_foreach_calls
                    value.docs.forEach((element) {
                      WishListModel listModel =
                          WishListModel.fromJson(element.data());
                      cartList.add(listModel.productId);
                    })
                  }
              });

      await prefs.setStringList(EcommerceApp.userCartList, cartList);
    });
  }
}
