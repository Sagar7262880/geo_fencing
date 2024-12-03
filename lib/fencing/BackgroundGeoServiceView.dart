import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utility/shared_pref_service/SharedService.dart';

class Backgroundgeoserviceview extends StatefulWidget {
  const Backgroundgeoserviceview({super.key});

  @override
  _BackgroundgeoserviceviewState createState() =>
      _BackgroundgeoserviceviewState();
}

class _BackgroundgeoserviceviewState extends State<Backgroundgeoserviceview> {
  bool isServiceRunning = false;
  var prefs =   SharedService();
  final platform = const MethodChannel('com.infogird.app/service');
  final platform2 = const MethodChannel('com.infogird.app/database');

  var location = "", userEmail = "", userPassword = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Service Control",
            // style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white)),
      //drawer: ComplexDrawer(),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Background Geo Service :"),
                              IconButton(
                                  onPressed: () {
                                    print(
                                        "To ensure accurate attendance tracking, our app requires continuous access to your location. This allows us to verify your presence in specific locations over time. Please make sure location services are enabled for this app, and that you grant it permission to track your location in the background.");
                                  },
                                  icon: const Icon(Icons.info_rounded))
                            ],
                          )),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(1)),
                          onPressed: () {
                            isServiceRunning ? _stopService() : _startService();
                          },
                          child: Text(
                              '${isServiceRunning ? "Stop Service" : "Start Service"}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        getLocation();
                      },
                      child: const Text("Get Location")),
                  ElevatedButton(
                      onPressed: () {
                        clearDb();
                      },
                      child: const Text("Clear DB")),
                ],
              ),
              Expanded(
                  child: Text(
                location,
              ))
            ],
          ),
        ),
      ),
    );
  }

  setPrefs(bool val) async {
    var prefs = await SharedService();
    prefs.setBool("isGeoServiceRunning", val);
    setState(() {});
  }

  getPrefs() async {
     isServiceRunning = prefs.getBool("isGeoServiceRunning") ?? false;
    setState(() {
      userEmail = prefs.getString("useremail") ?? "";
      userPassword = prefs.getString("userpassword") ?? "";
      print('Login with Email: $userEmail and Password: $userPassword');
    });
  }

  Future<void> _startService() async {
    try {
      final result = await platform.invokeMethod('startService');
      print('Service started: $result');
      isServiceRunning = true;
      await setPrefs(isServiceRunning);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }

  getLocation() async {
    var list = await platform2.invokeMethod("getLocations");
    // Singleton.showmsg(context, "Locations", list.toString());
    location = list.toString();
    setState(() {});
  }

  clearDb() async {
    var list = await platform2.invokeMethod("truncateDb");
    // Singleton.showmsg(context, "Locations", list.toString());
    location = "";
    setState(() {});
  }

  Future<void> _stopService() async {
    try {
      final result = await platform.invokeMethod('stopService');
      isServiceRunning = false;
      await setPrefs(isServiceRunning);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 500));
    } on PlatformException catch (e) {
      print("Failed to start service: '${e.message}'.");
    }
  }
}
