import 'package:dapp_tutorial/contracts/dapp_os.dart';
import 'package:dapp_tutorial/contracts/wallet_os.dart';
import 'package:dapp_tutorial/contracts/wallet_v2_os.dart';
import 'package:dapp_tutorial/utils/notification.dart';
import 'package:flutter/material.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MyNotification().initNotification();
  runApp(const WalletOSV2());
}

