import 'package:dapp_tutorial/screens/billing/subcription/subcription_card.dart';
import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SubscriptionCard(
          planName: 'Quater',
          price: '\$9.99',
          time: '3 months',
          description: 'Full access to all our library in Funny Filter',
          onSubscribe: () {
            // Handle subscription logic here
            print('Subscribed!');
          },
        ),
      ),
    );
  }
}
