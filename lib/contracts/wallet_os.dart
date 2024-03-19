import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class WalletOS extends StatelessWidget {
  const WalletOS({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blockchain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 54, 91, 191)),
        useMaterial3: true,
      ),
      home: const WalletPage(title: 'Block chain Ether wallet'),
    );
  }
}

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, required this.title});

  final String title;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  //Variables
  late Client httpClient;
  late Web3Client ethClient;
  late BigInt chainId;

  final TextEditingController amountController = TextEditingController();

  bool data = false;
  final String privateKey =
      "82ba7c0cc41ad81a8e119e4669e4b17f19b82af518bc156acc40794af3bfc947";
  // contract in remix
  final String contractAddress = "0x14567ECdF9e82170c71C78D249904A29C23F0282";

  // my IP_V4: 10.0.21.165
  final String _rpcUrl =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'http://127.0.0.1:7545';
  final String _wsUrl =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'ws://127.0.0.1:7545';

  var myData;

  //your wallet url
  final myAddress = "0xE10880aA7522df57f6e1B3cA8791Ae6ed26042f9";

  // the account you send to
  final toAddress = "0xf6E195E74FE05Da67623A51Af5597D0fF6Bb1DBe";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(_rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    getBalance(myAddress);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    amountController.dispose();
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi_wallet_os.json");

    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKWallet"),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String function, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(function);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);

    return result;
  }

  Future<void> getBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getBalance", [address]);
    myData = BigInt.parse(result[0].toString());
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: args,
        ),
        chainId: null,
        fetchChainIdFromNetworkId: true);

    restartMoney();
    return result;
  }

  void restartMoney() {
    getBalance(myAddress);
    setState(() {
      amountController.clear();
    });
  }

  void sendTransaction(String receiver, EtherAmount txValue) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);

    EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
    EtherAmount gasPrice = await ethClient.getGasPrice();
    BigInt chainId = await ethClient.getChainId();
    int intChainId = chainId.toInt();

    //print(etherAmount);

    final response = await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(receiver),
        gasPrice: gasPrice,
        maxGas: 100000,
        value: txValue,
      ),
      chainId: intChainId,
    );

    final receipt = await ethClient.getTransactionReceipt(response);

    // Check if the transaction is successful
    if (receipt == null) {
      showAlertDialog();
    } else {
      showReceiptDialog(receipt);
    }
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Failed'),
          content: const Text("Transaction Failed! No receipts received."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showReceiptDialog(TransactionReceipt receipt) {
    if (receipt.status == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: Text(
                "Transaction successful! Transaction hash: ${receipt.transactionHash}"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Failed'),
            content: Text(
                "Transaction Failed! Transaction hash: ${receipt.transactionHash}"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    restartMoney();
  }

  void processTransaction() {
    double amount = double.parse(amountController.text);
    BigInt bigIntValue = BigInt.from(amount * pow(10, 18));
    EtherAmount ethAmount = EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
    //print(ethAmount);
    sendTransaction(toAddress, ethAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Your Balance: ',
            ),
            const SizedBox(
              height: 20,
            ),
            data
                ? Text(
                    '\$$myData ETH',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount of ETH',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextButton(
                          onPressed: restartMoney,
                          child: const Text(
                            "Reset",
                            textAlign: TextAlign.center,
                          )),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextButton(
                          onPressed: processTransaction,
                          child: const Text("Send your money",
                              textAlign: TextAlign.center)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
