import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final double price;
  final String description;
  final int duration;
  final String timeUnit;

  const SubscriptionCard({
    Key? key,
    required this.planName,
    required this.price,
    required this.duration,
    required this.timeUnit,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(
          color: Color.fromARGB(26, 0, 0, 0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo_xs.svg',
                    fit: BoxFit.contain,
                    width: 44,
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    planName,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "\$ $price",
                    style: const TextStyle(
                      fontSize: 34,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    "\/ $duration $timeUnit",
                    style: const TextStyle(
                      fontSize: 19.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_yes.svg',
                    fit: BoxFit.contain,
                    width: 24,
                  ),
                  const SizedBox(width: 16.0),
                  const Text(
                    "Access all filters",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_yes.svg',
                    fit: BoxFit.contain,
                    width: 24,
                  ),
                  const SizedBox(width: 16.0),
                  const Text(
                    "Use all stickers",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_yes.svg',
                    fit: BoxFit.contain,
                    width: 24,
                  ),
                  const SizedBox(width: 16.0),
                  const Text(
                    "No commercials",
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue), //primaryColor),
                    child: const Text(
                      'Pay with Momo',
                      //style: buttonTextStyle,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.blue), //primaryColor),
                    child: const Text(
                      'Pay with Wallet',
                      //style: buttonTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
