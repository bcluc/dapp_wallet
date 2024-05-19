import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  void _addOption1() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add Option 1 selected!')),
    );
  }

  void _addOption2() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add Option 2 selected!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Wallet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Add your billing information 💳',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "You can add your Ethereum wallet anytime in Funny Filter",
              ),
              const Spacer(),
              Image.asset(
                'assets/images/wallet.png',
                fit: BoxFit.contain,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _addOption1,
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue), //primaryColor),
                child: const Text(
                  'Add your wallet',
                  //style: buttonTextStyle,
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _addOption2,
                style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue), //primaryColor),
                child: const Text(
                  'Maybe later',
                  //style: buttonTextStyle,
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
