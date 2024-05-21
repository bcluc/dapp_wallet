import 'package:dapp_tutorial/utils/hex_convert.dart';
import 'package:dapp_tutorial/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MomoRequest extends StatelessWidget {
  const MomoRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Run JavaScript Function'),
        ),
        body: PayMomoExample(),
      ),
    );
  }
}

class PayMomoExample extends StatefulWidget {
  @override
  _PayMomoExampleState createState() => _PayMomoExampleState();
}

class _PayMomoExampleState extends State<PayMomoExample> {
  String _payUrl = '';

  void _payMomo() async {
    final response = await http.post(
      Uri.parse('https://momo-backend-1r3y.onrender.com/api/pay'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'amount': 45000,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _payUrl = jsonDecode(response.body)['payUrl'];
        MyNotification().showNotification(title: "Momo status", body: _payUrl);
        print(_payUrl);
        myLaunchURL(_payUrl);
      });
    } else {
      setState(() {
        _payUrl = 'Error: ${response.reasonPhrase}';
      });
    }
    print(_payUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _payMomo,
            child: const Text('Pay with MoMo'),
          ),
          const SizedBox(height: 20),
          Text('Pay URL: $_payUrl'),
        ],
      ),
    );
  }
}
