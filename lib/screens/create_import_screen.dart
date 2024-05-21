import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dapp_tutorial/momo/momo_request.dart';
import 'package:dapp_tutorial/screens/billing/subcription/subcription_card.dart';
import 'package:dapp_tutorial/screens/memonic/generate_mnemonic_screen.dart';
import 'package:dapp_tutorial/screens/import_wallet.dart';
import 'package:dapp_tutorial/utils/hex_convert.dart';
import 'package:dapp_tutorial/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_js/flutter_js.dart';

class CreateOrImportPage extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  CreateOrImportPage({super.key});

  // Future<String> momoPayMent(JavascriptRuntime jsRuntime, int amount) async {
  //   String link = await DefaultAssetBundle.of(context).loadString("assets/CollectionLink.js");
  //   final jsResult = jsRuntime.evaluate(link + """payMomo($amount)""");
  //   final jsStringResult = jsResult.stringResult;
  //   return jsStringResult;
  // }
  void runJavaScriptFunction(int amount) {
    final javascriptRuntime = getJavascriptRuntime();

    String jsCode = """
      const crypto = require("crypto");
      const https = require("https");
      var resultUrl = "";

      function payMomo(amount) {
        var accessKey = 'F8BBA842ECF85';
        var secretKey = 'K951B6PE1waDMi640xX08PD3vg6EkVlz';
        var orderInfo = 'pay with MoMo';
        var partnerCode = 'MOMO';
        var redirectUrl = 'https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b';
        var ipnUrl = 'https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b';
        var requestType = 'payWithMethod';
        var orderId = partnerCode + new Date().getTime();
        var requestId = orderId;
        var extraData = '';
        var paymentCode = 'T8Qii53fAXyUftPV3m9ysyRhEanUs9KlOPfHgpMR0ON50U10Bh+vZdpJU7VY4z+Z2y77fJHkoDc69scwwzLuW5MzeUKTwPo3ZMaB29imm6YulqnWfTkgzqRaion+EuD7FN9wZ4aXE1+mRt0gHsU193y+yxtRgpmY7SDMU9hCKoQtYyHsfFR5FUAOAKMdw2fzQqpToei3rnaYvZuYaxolprm9+/+WIETnPUDlxCYOiw7vPeaaYQQH0BF0TxyU3zu36ODx980rJvPAgtJzH1gUrlxcSS1HQeQ9ZaVM1eOK/jl8KJm6ijOwErHGbgf/hVymUQG65rHU2MWz9U8QUjvDWA==';
        var orderGroupId = '';
        var autoCapture = true;
        var lang = 'vi';


        var rawSignature =
          'accessKey=' + accessKey +
          '&amount=' + amount +
          '&extraData=' + extraData +
          '&ipnUrl=' + ipnUrl +
          '&orderId=' + orderId +
          '&orderInfo=' + orderInfo +
          '&partnerCode=' + partnerCode +
          '&redirectUrl=' + redirectUrl +
          '&requestId=' + requestId +
          '&requestType=' + requestType;

        var signature = crypto.createHmac('sha256', secretKey)
            .update(rawSignature)
            .digest('hex');
        
        const requestBody = JSON.stringify({
            partnerCode : partnerCode,
            partnerName : "Test",
            storeId : "MomoTestStore",
            requestId : requestId,
            amount : amount,
            orderId : orderId,
            orderInfo : orderInfo,
            redirectUrl : redirectUrl,
            ipnUrl : ipnUrl,
            lang : lang,
            requestType: requestType,
            autoCapture: autoCapture,
            extraData : extraData,
            orderGroupId: orderGroupId,
            signature : signature
        });

        const options = {
            hostname: 'test-payment.momo.vn',
            port: 443,
            path: '/v2/gateway/api/create',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': Buffer.byteLength(requestBody)
                      }
            }
        callback = function (res) {
          res.setEncoding("utf8");
          res.on("data", (body) => {
            console.log("Body: ");
            console.log(body);
            resultUrl = JSON.parse(body).payUrl;
            console.log("resultCode: ");
            console.log(JSON.parse(body).resultCode);
            return resultUrl;
          });
          res.on("end", () => {
            console.log("No more data in response.");
            console.log(resultUrl);
          });
        };

        const req = https.request(options, callback);

        req.on("error", (e) => {
          console.log("Error....");
        });

        req.write(requestBody);
        req.end();

        return resultUrl;
      }

      var result = payMomo($amount);
      result;
    """;

    final result = javascriptRuntime.evaluate(jsCode);

    print('JavaScript Result: ${result.stringResult}');
  }

  Future<String> payMomo(int amount) async {
    const accessKey = "F8BBA842ECF85";
    const secretKey =
        "K951B6PE1waDMi640xX08PD3vg6EkVlz"; // key để test // không đổi
    const orderInfo = "pay with MoMo"; // thông tin đơn hàng
    const partnerCode = "MOMO";
    const redirectUrl =
        "https://webhook.site/b3088a6a-2d17-4f8d-a383-71389a6c600b"; // Link chuyển hướng tới sau khi thanh toán hóa đơn
    const ipnUrl = redirectUrl; // trang truy vấn kết quả, để trùng với redirect
    const requestType = "payWithMethod";
    final orderId = partnerCode +
        DateTime.now()
            .microsecondsSinceEpoch
            .toString(); // mã Đơn hàng, có thể đổi
    final requestId = orderId;
    const extraData =
        ""; // đây là data thêm của doanh nghiệp (địa chỉ, mã COD,....)
    const orderGroupId = "";
    const autoCapture = true;
    const lang = "vi"; // ngôn ngữ

    var rawSignature =
        "accessKey=$accessKey&amount=$amount&extraData=$extraData&ipnUrl=$ipnUrl&orderId=$orderId&orderInfo=$orderInfo&partnerCode=$partnerCode&redirectUrl=$redirectUrl&requestId=$requestId&requestType=$requestType";

    // print(rawSignature);

    // var key = utf8.encode(secretKey);
    // var bytes = utf8.encode(rawSignature);

    // final hmacSha256 = Hmac(sha256, utf8.encode(secretKey!));
    // final signature = hmacSha256.convert(utf8.encode(rawSignature));

    String signature = generateHmacSha256(secretKey, rawSignature);

    Map<String, dynamic> requestBody = {
      'partnerCode': partnerCode,
      'partnerName': 'Test',
      'storeId': 'MomoTestStore',
      'requestId': requestId,
      'amount': amount,
      'orderId': orderId,
      'orderInfo': orderInfo,
      'redirectUrl': redirectUrl,
      'ipnUrl': ipnUrl,
      'lang': lang,
      'requestType': requestType,
      'autoCapture': autoCapture,
      'extraData': extraData,
      'orderGroupId': orderGroupId,
      'signature': signature,
    };

    String jsonRequestBody = jsonEncode(requestBody);
    int contentLength = utf8.encode(jsonRequestBody).length;

    final response = await http.post(
      Uri.parse(
          'https://test-payment.momo.vn/v2/gateway/api/create'), // Adjust the URL as needed
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Content-Length': contentLength.toString()
      },
      body: jsonRequestBody,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final resultUrl = body['payUrl'];
      return resultUrl;
    } else {
      print('Error: ${response.reasonPhrase}');
    }
    return "";
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
                // try {
                //   final resultLink = await payMomo(4500);
                //   //final resultLink = js.context.callMethod('payMomo', [4500]);
                //   // Check link
                //   MyNotification()
                //       .showNotification(title: "Momo status", body: resultLink);
                //   print('---------');
                //   print(resultLink);
                //   myLaunchURL(resultLink);
                // } on PlatformException catch (e) {
                //   log('error:${e.details}');
                // }

                // Create Js Service
                //runJavaScriptFunction(35600);

                // use nodejs server
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MomoRequest()),
                );
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
