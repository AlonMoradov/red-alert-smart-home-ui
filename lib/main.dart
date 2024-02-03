import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Red Alert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Red Alert'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var baseUrl = "http://redalert.local:5555";
  // var baseUrl = "http://127.0.0.1:5555";
  var city = "";
  var userId = "";
  var macAddress = "";
  var ipAddress = "";
  List cities = [];

  Future getCity() async {
    var url = Uri.parse("$baseUrl/get_current_city");
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      city = data["city"];
    });
  }

  Future getUserId() async {
    var url = Uri.parse("$baseUrl/get_hue_bridge_username");
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      userId = data["username"];
    });
  }

  Future getMacAddress() async {
    var url = Uri.parse("$baseUrl/get_hue_bridge_mac_addr");
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      macAddress = data["mac_addr"];
    });
  }

  Future getIpAddress() async {
    var url = Uri.parse("$baseUrl/get_hue_bridge_ip_addr");
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      ipAddress = data["ip_addr"];
    });
  }

  Future setCity(String value) async {
    var url = Uri.parse("$baseUrl/set_current_city");
    var body = jsonEncode({"city": value});
    var response = await http.post(url,
        body: body,
        headers: {
          "Content-Type": "application/json",
        },
        encoding: Encoding.getByName("utf-8"));
    var data = jsonDecode(response.body);
    setState(() {
      city = data["city"];
    });
  }

  Future getCitiesList() async {
    var url = Uri.parse("$baseUrl/get_cities_list");
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      cities = data;
    });
  }

  Future reconnect() async {
    var url = Uri.parse("$baseUrl/reconnect");
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    getDetails();
  }

  void getDetails() {
    getCity();
    getUserId();
    getMacAddress();
    getIpAddress();
    getCitiesList();
  }

  void showCustomDialog(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) {
        var showedCities = cities;
        return Scaffold(
            appBar: AppBar(
                title: const Text("עדכן עיר"),
                backgroundColor: Theme.of(context).colorScheme.primary),
            body: StatefulBuilder(
              builder: (context, setStatee) => SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextField(
                          onChanged: (value) {
                            setStatee(() {
                              showedCities = cities
                                  .where((element) => element['label']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                          decoration: const InputDecoration(
                            label: Text(
                              "חיפוש עיר",
                              textAlign: TextAlign.right,
                            ),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                          itemCount: showedCities.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(showedCities[index]['label'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                              onTap: () {
                                setCity(showedCities[index]['label']);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
      fullscreenDialog: true,
      maintainState: true,
    ));
  }

  @override
  void initState() {
    getDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: mainPage(context));
  }

  Column mainPage(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text("מציג התראות עבור",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center),
            Text(city,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        TextButton(
          onPressed: () {
            showCustomDialog(context);
            getDetails();
          },
          child: const Text("עדכן עיר"),
        ),
        const Spacer(),
        userId == ""
            ? Column(children: [
                const Text("יש ללחוץ על הכפתור במגשר ולאחר מכן על חיבור מחדש"),
                const SizedBox(
                  height: 20,
                ),
                const CircularProgressIndicator.adaptive(),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: () {
                    getUserId();
                  },
                  style: TextButton.styleFrom(
                    fixedSize: const Size(200, 50),
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text("חיבור מחדש"),
                ),
              ])
            : Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
        const Spacer(),
        Container(
          height: 120,
          width: double.infinity,
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // reset button
              TextButton(
                onPressed: () {
                  getDetails();
                },
                child: const Text("חיבור מחדש"),
              ),
              Text(ipAddress),
              Text(macAddress),
              userId == ""
                  ? const Text(
                      "יש ללחוץ על הכפתור במגשר ולאחר מכן לרענן את הדף")
                  : Text(userId),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
