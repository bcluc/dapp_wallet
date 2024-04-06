import 'package:dapp_tutorial/contracts/wallet_v2_os.dart';
import 'package:dapp_tutorial/providers/wallet_provider.dart';
import 'package:dapp_tutorial/screens/login_screen.dart';
import 'package:dapp_tutorial/utils/notification.dart';
import 'package:dapp_tutorial/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
    WidgetsFlutterBinding.ensureInitialized();

  // Load the private key
  WalletProvider walletProvider = WalletProvider();
  await walletProvider.loadPrivateKey();

  WidgetsFlutterBinding.ensureInitialized();
  MyNotification().initNotification();
  runApp(ChangeNotifierProvider<WalletProvider>.value(
    value: walletProvider,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: MyRoutes.loginRoute,
      routes: {
        MyRoutes.loginRoute: (context) => const LoginScreen(),
      },
    );
  }
}