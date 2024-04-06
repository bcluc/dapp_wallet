import 'package:dapp_tutorial/contracts/wallet_v2_os.dart';
import 'package:dapp_tutorial/providers/wallet_provider.dart';
import 'package:dapp_tutorial/screens/create_import_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    if(walletProvider.privateKey == null){
      return const CreateOrImportPage();
    }
    else{
      return const WalletOSV2();
    }
  }
}