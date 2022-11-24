import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:traffic_live/pages/profile_page.dart';
import 'package:traffic_live/pages/records_page.dart';

import '../helper/helper_function.dart';
import '../service/auth_service.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  final TextEditingController _plateNumber = new TextEditingController();
  final TextEditingController _description = new TextEditingController();
  String queryName = "";
  var selectedViolation;
  var locationLat;
  var locationLong;
  String gpsAddress = "";
  String order = "";
  String dateTime = "";
  String userName = "";
  String email = "";
  int currentIndex = 0;
  String plateNumber = "";
  String description = "";

  Future<void> updateLocation() async {
    Position pos = await getLocation();
    List pm = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    Placemark placeMark = pm[0];
    String name = placeMark.name.toString();
    String subLocality = placeMark.subLocality.toString();
    String locality = placeMark.locality.toString();
    String country = placeMark.country.toString();

    setState(() {
      locationLat = pos.latitude.toString();
      locationLong = pos.longitude.toString();
      gpsAddress = "${name}, ${subLocality}, ${locality}, ${country}";
    });
  }

  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location Premissions are denied");
      }
    }

    return await Geolocator.getCurrentPosition();

    // locationLat = position.latitude.toString();//"${position.latitude}";
    // locationLong = position.longitude.toString();//"${position.longitude}";
  }

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // IconButton(
          //     onPressed: () {
          //       nextScreen(context, const SearchPage());
          //     },
          //     icon: const Icon(
          //       Icons.search,
          //     ))
        ],
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "TrafficLive",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {},
              selectedColor: Theme.of(context).primaryColor,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.home),
              title: const Text(
                "Home",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreenReplace(
                    context,
                    ProfilePage(
                      userName: userName,
                      email: email,
                    ));
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            ),
                          )
                        ],
                      );
                    });
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),

      body: currentIndex == 0
          ? Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // const Text(
                        //   "Enter violation details below:",
                        //   textAlign: TextAlign.left,
                        //   style: TextStyle(
                        //       fontSize: 15, fontWeight: FontWeight.bold),
                        // ),
                        const SizedBox(height: 15),
                        TextFormField(
                          textCapitalization: TextCapitalization.characters,
                          controller: _plateNumber,
                          decoration: textInputDecoration.copyWith(
                              labelText: "Plate Number",
                              prefixIcon: Icon(
                                Icons.no_crash_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              focusedBorder: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              errorBorder: UnderlineInputBorder()),
                          onChanged: (val) {
                            setState(() {
                              val.toUpperCase();
                              plateNumber = val.toUpperCase();
                            });
                          },

                          //Check the validation
                          validator: (val) {
                            if (val!.length < 6) {
                              return "Plate number is insufficient";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),

                        //Dropdown
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("violations")
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData)
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              else {
                                List<String> violationItems = [];
                                for (int i = 0;
                                    i < snapshot.data!.docs.length;
                                    i++) {
                                  DocumentSnapshot snap =
                                      snapshot.data!.docs[i];
                                  violationItems.add(snap.id);
                                }

                                return DropdownSearch<String>(
                                    items: violationItems,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedViolation = value as String;
                                      });
                                    },
                                    selectedItem: selectedViolation,
                                    // icon: const Icon(
                                    //   Icons.arrow_drop_down_circle,
                                    //   //color: Colors.green
                                    // ),
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Violation",
                                        prefixIcon: Icon(
                                          Icons.warning_rounded,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        //border: UnderlineInputBorder()
                                      ),
                                    ),
                                    dropdownButtonProps: DropdownButtonProps(
                                        icon: Icon(Icons.arrow_drop_down_circle,
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    popupProps: PopupProps.menu(
                                        showSearchBox: true,
                                        //fit: FlexFit.loose,
                                        searchFieldProps: TextFieldProps(),
                                        menuProps: MenuProps()
                                        //title: Text("Violations")
                                        ),
                                    // dropdownSearchDecoration: InputDecoration(
                                    //     labelText: "Violations",
                                    //     prefixIcon: Icon(
                                    //       Icons.warning_rounded,
                                    //       color: Theme.of(context).primaryColor,
                                    //     ),
                                    //     border: UnderlineInputBorder()),
                                    autoValidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value != null) {
                                        return null;
                                      } else {
                                        return "Violation cannot be empty";
                                      }
                                    },
                                    enabled: true);
                              }
                              //return SizedBox(height: 0);
                            }),

                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _description,
                          decoration: textInputDecoration.copyWith(
                              labelText: "Description (optional)",
                              prefixIcon: Icon(
                                Icons.text_snippet_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              focusedBorder: UnderlineInputBorder(),
                              enabledBorder: UnderlineInputBorder(),
                              errorBorder: UnderlineInputBorder()),
                          onChanged: (val) {
                            setState(() {
                              description = val;
                            });
                          },
                        ),

                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                            child: const Text("Submit",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            onPressed: () {
                              updateLocation();
                              submit();
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('records')
                  .orderBy("order", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                else {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              queryName = value;
                            });
                          },
                          decoration: InputDecoration(
                              labelText: 'Search',
                              suffixIcon: Icon(Icons.search)),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                            child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  var data = snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;

                                  if (queryName.isEmpty) {
                                    return Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: ListTile(
                                          title: Text(
                                            data['plateNumber'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['violation'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  data['dateTime'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  data['gpsAddress'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    );
                                  }

                                  if (data['plateNumber']
                                      .toString()
                                      .contains(queryName.toUpperCase())) {
                                    return Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Container(
                                        height: 100,
                                        child: ListTile(
                                          title: Text(
                                            data['plateNumber'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['violation'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  data['dateTime'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  data['gpsAddress'],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    );
                                  }
                                  return Container();
                                }))
                      ],
                    ),
                  );
                }
              }),

      // floatingActionButton: FloatingActionButton(
      //   elevation: 0,
      //   backgroundColor: Theme.of(context).primaryColor,
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.white,
      //     size: 30,
      //   ),
      //   onPressed: () {
      //     popUpDialog(context);
      //   },
      // ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.withOpacity(0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.add),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.manage_search_rounded),
          )
        ],
        currentIndex: currentIndex,
        onTap: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  submit() async {
    if (formKey.currentState!.validate()) {
      final records = FirebaseFirestore.instance.collection('records').doc();
      DateTime now = DateTime.now();
      dateTime = DateFormat("MMMM d, yyyy h:mm:ss aa").format(now);
      order = DateFormat("yMMddHHmm").format(now);

      final data = {
        'order': order,
        'dateTime': dateTime,
        'plateNumber': plateNumber,
        'gpsAddress': gpsAddress,
        'gpsLat': locationLat,
        'gpsLong': locationLong,
        'desc': description,
        'violation': selectedViolation
      };

      await records.set(data);
      _description.clear();
      _plateNumber.clear();

      setState(() {
        selectedViolation = null;
      });

      //formKey.currentState!.reset();

      return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              contentPadding: EdgeInsets.only(top: 10),
              title: Text(
                "Successfully Saved!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.check_circle,
                    color: Color.fromARGB(255, 13, 107, 69),
                  ),
                ),
              ]);
        },
      );
    }
  }

  popUpDialog(BuildContext context) {}
  groupList() {}
}
