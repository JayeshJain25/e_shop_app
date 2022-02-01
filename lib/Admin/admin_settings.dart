import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop_app/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({Key? key}) : super(key: key);

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  bool cashOnDelivery = true;
  bool fetchedData = false;
  String id = '';

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("admins").get().then((snapshot) {
      for (var result in snapshot.docs) {
        cashOnDelivery = result.data()["cashOnDelivery"];
        id = result.id;
        setState(() {
          fetchedData = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Settings"),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: fetchedData
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Cash On Delivery",
                        style: TextStyle(fontSize: 18),
                      ),
                      ToggleSwitch(
                        minWidth: 80.0,
                        initialLabelIndex: cashOnDelivery ? 0 : 1,
                        cornerRadius: 20.0,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey,
                        inactiveFgColor: Colors.white,
                        totalSwitches: 2,
                        labels: const ['Enabled', 'Disabled'],
                        activeBgColors: const [
                          [Colors.blue],
                          [Colors.pink]
                        ],
                        onToggle: (index) {
                          if (index == 0) {
                            cashOnDelivery = true;
                          } else {
                            cashOnDelivery = false;
                          }
                          FirebaseFirestore.instance
                              .collection("admins")
                              .doc(id)
                              .update({"cashOnDelivery": cashOnDelivery});
                        },
                      ),
                    ],
                  ),
                ],
              )
            : const SizedBox(),
      ),
    );
  }
}
