import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/Admin/admin_home_screen.dart';
import 'package:e_shop_app/DialogBox/error_dialog.dart';
import 'package:e_shop_app/authentication/authenticate_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:e_shop_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSignInPage extends StatelessWidget {
  const AdminSignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        title: Text(
          "e-Shop",
          style: GoogleFonts.roboto(fontSize: 30.0, color: kBackgroundColor),
        ),
        centerTitle: true,
      ),
      body: const AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  const AdminSignInScreen({Key? key}) : super(key: key);

  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _adminIDTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: kPrimaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/images/admin.png",
              height: 240.0,
              width: 240.0,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Admin",
              style: TextStyle(
                  color: kBackgroundColor,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  _adminIDTextEditingController,
                  Icons.person,
                  "Id",
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
          const SizedBox(
            height: 25.0,
          ),
          ElevatedButton(
            onPressed: () {
              _adminIDTextEditingController.text.isNotEmpty &&
                      _passwordTextEditingController.text.isNotEmpty
                  ? loginAdmin()
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
            height: 25.0,
          ),
          TextButton.icon(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(kBackgroundColor),
            ),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AuthenticateScreen())),
            icon: (const Icon(
              Icons.nature_people,
              color: kPrimaryColor,
            )),
            label: const Text(
              "i'm not Admin",
              style:
                  TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  loginAdmin() {
    FirebaseFirestore.instance.collection("admins").get().then((snapshot) {
      for (var result in snapshot.docs) {
        if (result.data()["id"] != _adminIDTextEditingController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("your id is not correct."),
          ));
        } else if (result.data()["password"] !=
            _passwordTextEditingController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("your password is not correct."),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Welcome Dear Admin, " + result.data()["name"]),
          ));

          setState(() {
            _adminIDTextEditingController.text = "";
            _passwordTextEditingController.text = "";
          });

          Route route =
              MaterialPageRoute(builder: (c) => const AdminHomeScreen());
          Navigator.pushReplacement(context, route);
        }
      }
    });
  }
}
