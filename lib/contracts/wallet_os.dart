import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

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
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool data = false;
  bool isLoading = false;
  bool isEth = false;
  bool transactionConfirmed = false;

  // Wallet private key
  final String localPrivateKey =
      "82ba7c0cc41ad81a8e119e4669e4b17f19b82af518bc156acc40794af3bfc947";
  final String sepPrivateKey =
      "4177462845449c2549df12b12c2c933959ad52b4cb36305974a8cfa7170fcd35";
  // contract in remix
  final String localContractAddress =
      "0x14567ECdF9e82170c71C78D249904A29C23F0282";
  final String sepContractAddress =
      "0x1fA8630d9aA5F3aAC32869761Fb989f0c754a2c1";

  // my IP_V4: 10.0.21.165
  final String _rpcUrl =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'http://127.0.0.1:7545';
  final String _wsUrl =
      Platform.isAndroid ? 'http://10.0.2.2:7545' : 'ws://127.0.0.1:7545';
  final String _sepRpcUrl =
      'https://sepolia.infura.io/v3/2682fb5ba7214f63ad1b4b90c9169b38';

  late BigInt myData;
  late String error;
  var lbData;

  //your wallet url
  final myLocalAddress = "0xE10880aA7522df57f6e1B3cA8791Ae6ed26042f9";
  final mySepAddress = "0x55128a9000E226c90Da21cb864d985Ad3ef7E9C5";

  // the account you send to
  final toLocalAddress = "0xf6E195E74FE05Da67623A51Af5597D0fF6Bb1DBe";
  final toSepAddress = "0x87adf62727625c29D6A2F478df145c975896498f";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    // ethClient = Web3Client(_rpcUrl, httpClient, socketConnector: () {
    //   return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    ethClient = Web3Client(_sepRpcUrl, httpClient);

    getBalance(mySepAddress);
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
        EthereumAddress.fromHex(sepContractAddress));

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
    //List<dynamic> result = await query("getBalance", [address]);
    EtherAmount balance = await ethClient.getBalance(address);

    //myData = result[0];
    myData = balance.getInWei;
    double curETH = pow(10, 18).toDouble();
    isEth ? lbData = ((myData).toDouble()) / curETH : lbData = (myData);
    data = true;
    setState(() {});
  }

  void restartMoney() {
    getBalance(mySepAddress);
    setState(() {
      amountController.clear();
    });
  }

  void sendTransaction(String receiver, BigInt txValue) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(sepPrivateKey);
    EtherAmount gasPrice = await ethClient.getGasPrice();
    BigInt chainId = await ethClient.getChainId();
    int intChainId = chainId.toInt();
    setState(() {
      isLoading = true;
    });

    final response = await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(receiver),
        gasPrice: gasPrice,
        maxGas: 3000000,
        value: EtherAmount.inWei(txValue),
      ),
      chainId: intChainId,
    );
    
    await _waitForConfirmation(response);

    setState(() {
      isLoading = false;
    });
    showAlertDialog();
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(transactionConfirmed ? "Success" : "Failed"),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                restartMoney();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _waitForConfirmation(String? transactionHash) async {
    const pollingInterval =
        Duration(seconds: 5); // Adjust polling interval as needed
    const maxAttempts = 4; // 12 * 5 seconds = 1 minute total wait time

    int attempt = 0;

    while (!transactionConfirmed && attempt < maxAttempts) {
      try {
        TransactionReceipt? receipt =
            await ethClient.getTransactionReceipt(transactionHash!);
        if (receipt != null && receipt.blockNumber != null) {
          // Transaction is confirmed
          transactionConfirmed = true;
          error = 'Transaction confirmed in block ${receipt.blockNumber}';
        }
      } catch (e) {
        error = 'Error fetching transaction receipt: $e';
      }

      if (!transactionConfirmed) {
        await Future.delayed(pollingInterval);
        attempt++;
      }
    }

    if (!transactionConfirmed) {
      transactionConfirmed = true;
      error =
          'Transaction not confirmed within timeout period.\nYou can close this notification and wait';
    }
  }

  // Process to take the amount and make transaction
  void processTransaction() {
    double amount = double.parse(amountController.text);
    BigInt weiAmount;
    isEth
        ? weiAmount = BigInt.from(amount * pow(10, 18))
        : weiAmount = BigInt.from(amount);
    sendTransaction(toSepAddress, weiAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
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
                          '\$$lbData ${isEth ? "ETH" : "WEI"}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        )
                      : const CircularProgressIndicator(),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                isEth = !isEth;
                                double curETH = pow(10, 18).toDouble();
                                isEth
                                    ? lbData = ((myData.toDouble())) / curETH
                                    : lbData = (myData);
                              });
                            },
                            child: Text(
                              "Currency: ${isEth ? "ETH" : "WEI"}",
                              textAlign: TextAlign.center,
                            )),
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: 'Amount of ${isEth ? "ETH" : "WEI"}',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ],
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
