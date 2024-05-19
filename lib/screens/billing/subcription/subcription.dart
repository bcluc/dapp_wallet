import 'package:dapp_tutorial/screens/billing/subcription/subcription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SubcriptionScreen extends StatelessWidget {
  const SubcriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(children: <Widget>[
        // SVG background
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/plain_bg.svg',
            fit: BoxFit.cover,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('Be part of our',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 45, 196, 182),
                    ),
                    textAlign: TextAlign.center),
                const Text("Family",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 159, 28), //primaryColor,
                    ),
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                    "Easy and fast process, provide multiple  billing options just for you",
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SubscriptionCard(
                      planName: "Quater",
                      price: "\$9,99",
                      time: "3 months",
                      description:
                          "Full access to all our library in Funny Filter",
                      onSubscribe: () {}),
                ),
                const SizedBox(height: 70),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
