import 'dart:math';
import 'package:dapp_tutorial/providers/wallet_provider.dart';
import 'package:dapp_tutorial/screens/create_import_screen.dart';
import 'package:dapp_tutorial/utils/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';

class WalletOSV2 extends StatelessWidget {
  const WalletOSV2({super.key});

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

  late BigInt myData;
  late String error;
  var lbData;
  late DeployedContract contract;
  late ContractEvent contractEvent;

  String myWalletAddress = '';
  String myPrivateKey = '';

  // // Wallet private key
  // final String sepPrivateKey =
  //     "4177462845449c2549df12b12c2c933959ad52b4cb36305974a8cfa7170fcd35";
  // // contract in remix
  final String sepContractAddress =
      "0x39f13B61cEF5939A30D1ac89E1bF441a62371E7C";
  final String _sepRpcUrl =
      'https://sepolia.infura.io/v3/2682fb5ba7214f63ad1b4b90c9169b38';

  // //your wallet url
  // final mySepAddress = "0x55128a9000E226c90Da21cb864d985Ad3ef7E9C5";
  // the account you send to
  final toSepAddress = "0x87adf62727625c29D6A2F478df145c975896498f";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    httpClient = Client();
    // ethClient = Web3Client(_rpcUrl, httpClient, socketConnector: () {
    //   return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    ethClient = Web3Client(_sepRpcUrl, httpClient);
    //initializeNotifications();
    loadWallet();
    getBalance(myWalletAddress);
  }

  Future<void> loadWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');
    if (privateKey != null) {
      final walletProvider = WalletProvider();
      await walletProvider.loadPrivateKey();
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);
      print('My wallet address');
      print(address.hex);
      setState(() {
        myWalletAddress = address.hex;
        myPrivateKey = privateKey;
      });
      print(myPrivateKey);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    amountController.dispose();
    ethClient.dispose();
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi_wallet_os.json");
    contract = DeployedContract(ContractAbi.fromJson(abi, "PKWallet"),
        EthereumAddress.fromHex(sepContractAddress));
    // PROCESS TO LISTENING TRANSFER EVENT
    contractEvent = contract.event("transfer");
    listenForTransfers();
    return contract;
  }

  Future<void> listenForTransfers() async {
    await for (var event in ethClient.events(FilterOptions.events(
        contract: contract,
        event: contractEvent,
        fromBlock: const BlockNum.current()))) {
      // Trigger Notification here
      MyNotification().showNotification(
          title: "Transaction success",
          body: "Transaction hash: ${event.transactionHash}");
    }
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
    EtherAmount balance = await ethClient.getBalance(address);
    myData = balance.getInWei;
    double curETH = pow(10, 18).toDouble();
    isEth ? lbData = ((myData).toDouble()) / curETH : lbData = (myData);
    data = true;
    setState(() {});
  }

  void restartMoney() {
    getBalance(myWalletAddress);
    setState(() {
      amountController.clear();
    });
  }

  void sendTransaction(String receiver, BigInt txValue) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(myPrivateKey);
    DeployedContract contract = await loadContract();
    BigInt chainId = await ethClient.getChainId();
    int intChainId = chainId.toInt();
    setState(() {
      isLoading = true;
    });
    final ethFunction = contract.function("sendViaTransfer");
    final response = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: [EthereumAddress.fromHex(receiver)],
        value: EtherAmount.inWei(txValue),
      ),
      chainId: intChainId,
    );

    await _waitForConfirmation(response);

    setState(() {
      isLoading = false;
    });
    showAlertDialog();
    return;
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

  Future<void> _waitForConfirmation(String transactionHash) async {
    const pollingInterval =
        Duration(seconds: 12); // Adjust polling interval as needed
    const maxAttempts = 10; // 5 * 2 total wait time

    int attempt = 0;

    while (!transactionConfirmed && attempt < maxAttempts) {
      try {
        TransactionReceipt? receipt =
            await ethClient.getTransactionReceipt(transactionHash);
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
      error = 'Transaction not confirmed within timeout period.';
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
                  ),
                  TextButton(
                      onPressed: logOut,
                      child: const Text(
                        "Log out",
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
      ),
    );
  }

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('privateKey');
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrImportPage(),
      ),
      (route) => false,
    );
  }
}
