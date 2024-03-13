import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 54, 91, 191)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Block chain Ether test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //Variables
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  double myAmount = 0;
  final String privateKey =
      "82ba7c0cc41ad81a8e119e4669e4b17f19b82af518bc156acc40794af3bfc947";
  final String _rpcUrl =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'http://127.0.0.1:7545';
  final String _wsUrl =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'ws://127.0.0.1:7545';

  var myData;
  //your wallet url
  final myAddress = "0xE10880aA7522df57f6e1B3cA8791Ae6ed26042f9";

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

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x9CB2f3BA5B43154484e96B093826Aeb35a7929C8";

    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKCoin"),
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
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
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
            contract: contract, function: ethFunction, parameters: args), fetchChainIdFromNetworkId: true);

    return result;
  }

  Future<String> depositMoney() async {
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("depositBalance", [bigAmount]);
    return response;
  }

  Future<String> withdrawMoney() async {
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("withdrawBalance", [bigAmount]);
    return response;
  }

  void getMyAmount() {}

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
                    '\$$myData',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : const CircularProgressIndicator(),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Your Amount: $myAmount',
            ),
            const SizedBox(
              height: 20,
            ),
            Slider(
                value: myAmount,
                min: 0,
                max: 100,
                label: myAmount.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    myAmount = value;
                  });
                }),
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
                          onPressed: depositMoney,
                          child: const Text(
                            "Deposit your account",
                            textAlign: TextAlign.center,
                          )),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextButton(
                          onPressed: withdrawMoney,
                          child: const Text("Withdraw your account",
                              textAlign: TextAlign.center)),
                    ),
                    const SizedBox(
                      width: 20,
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
