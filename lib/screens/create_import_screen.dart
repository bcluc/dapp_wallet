import 'dart:developer';
import 'dart:ffi';

import 'package:dapp_tutorial/screens/memonic/generate_mnemonic_screen.dart';
import 'package:dapp_tutorial/screens/import_wallet.dart';
import 'package:dapp_tutorial/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateOrImportPage extends StatelessWidget {
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  CreateOrImportPage({super.key});

  Future<String> momoPayMent(JavascriptRuntime jsRuntime, int amount) async {
    String link = await rootBundle.loadString("assets/CollectionLink.js");
    final jsResult = jsRuntime.evaluate("""${link}payMomo($amount)""");
    final jsStringResult = jsResult.stringResult;
    return jsStringResult;
  }

  void myLaunchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Web3 Wallet',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            const SizedBox(height: 50.0),

            // Login button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenerateMnemonicPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue, // Customize button background color
                foregroundColor: Colors.white, // Customize button text color
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text(
                'Create Wallet',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Register button
            ElevatedButton(
              onPressed: () {
                // Add your register logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImportWallet(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white, // Customize button background color
                foregroundColor: Colors.black, // Customize button text color
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text(
                'Import',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),

            const SizedBox(height: 16.0),

            // Momo button
            ElevatedButton(
              onPressed: () async {
                // Add your payment logic here
                try {
                  final resultLink = await momoPayMent(jsRuntime, 45000);
                  MyNotification()
                      .showNotification(title: "Momo status", body: resultLink);
                  myLaunchURL(resultLink);
                } on PlatformException catch (e) {
                  log('error:${e.details}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white, // Customize button background color
                foregroundColor: Colors.black, // Customize button text color
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Text(
                'Momo',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
