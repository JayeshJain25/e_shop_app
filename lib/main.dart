import 'dart:async';

import 'package:e_shop_app/authentication/authenticate_screen.dart';
import 'package:e_shop_app/providers/cart_provider.dart';
import 'package:e_shop_app/providers/change_address.dart';
import 'package:e_shop_app/providers/product_provider.dart';
import 'package:e_shop_app/screens/home_screen.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (c) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (c) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (c) => AddressChanger(),
        )
      ],
      child: MaterialApp(
        title: 'E-Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    displaySplash();
  }

  displaySplash() {
    Timer(const Duration(seconds: 3), () async {
      if (user != null) {
        Route route = MaterialPageRoute(builder: (_) => const HomeScreen());
        Navigator.pushReplacement(context, route);
      } else {
        Route route =
            MaterialPageRoute(builder: (_) => const AuthenticateScreen());
        Navigator.pushReplacement(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "E-Shop App",
                style:
                    GoogleFonts.poppins(color: kBackgroundColor, fontSize: 25),
              ),
              Text(
                "World's Largest & Number one Online Shop",
                style:
                    GoogleFonts.poppins(color: kBackgroundColor, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
