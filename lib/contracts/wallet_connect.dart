import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/apis/auth_api/auth_client.dart';
import 'package:walletconnect_flutter_v2/apis/auth_api/models/auth_client_events.dart';
import 'package:walletconnect_flutter_v2/apis/auth_api/models/auth_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/auth_api/utils/address_utils.dart';
import 'package:walletconnect_flutter_v2/apis/core/pairing/utils/pairing_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/json_rpc_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/proposal_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/session_models.dart';
import 'package:walletconnect_flutter_v2/apis/sign_api/models/sign_client_models.dart';
import 'package:walletconnect_flutter_v2/apis/web3app/web3app.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectScreen extends StatefulWidget {
  const WalletConnectScreen({super.key});

  @override
  State<WalletConnectScreen> createState() => _WalletConnectScreenState();
}

class _WalletConnectScreenState extends State<WalletConnectScreen> {
  String walletAddress = "ABC";
  void initAuth() async {
    Web3App wcClient = await Web3App.createInstance(
      relayUrl:
          'wss://relay.walletconnect.com', // The relay websocket URL, leave blank to use the default
      projectId: '63d129bc91dec3a9ddeba51096598c6b',
      metadata: PairingMetadata(
        name: 'dApp (Requester)',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );

    ConnectResponse resp = await wcClient.connect(
      requiredNamespaces: {
        'eip155': RequiredNamespace(
          chains: ['eip155:1'], // Ethereum chain
          methods: [
            'personal_sign'
          ], // Requestable Methods, see MethodsConstants for reference
          events: [
            'chainChanged'
          ], // Requestable Events, see EventsConstants for reference
        ),
      },
      optionalNamespaces: {
        'eip155': RequiredNamespace(
          chains: ['eip155:1', 'eip155:5'], // Any other optional Ethereum chain
          methods: [
            'eth_signTransaction'
          ], // Optional requestable Methods, see MethodsConstants for reference
          events: [
            'accountsChanged'
          ], // Optional requestable events, see EventsConstants for reference
        ),
      },
    );
    Uri? uri = resp.uri;
    final SessionData session = await resp.session.future;

// Now that you have a session, you can request signatures
    final dynamic signResponse = await wcClient.request(
      topic: session.topic,
      chainId: 'eip155:1',
      request: SessionRequestParams(
        method: 'eth_signTransaction',
        params: '{json serializable parameters}',
      ),
    );
    final AuthRequestResponse authReq = await wcClient.requestAuth(
      params: AuthRequestParams(
        aud: 'http://localhost:3000/login',
        domain: 'localhost:3000',
        chainId: 'eip155:1',
        statement: 'Sign in with your wallet!',
      ),
      pairingTopic: resp.pairingTopic,
    );

// Await the auth response using the provided completer
    final AuthResponse authResponse = await authReq.completer.future;
    if (authResponse.result != null) {
      // Having a result means you have the signature and it is verified.

      // Retrieve the wallet address from a successful response
      walletAddress = AddressUtils.getDidAddress(authResponse.result!.p.iss);
    } else {
      // Otherwise, you might have gotten a WalletConnectError if there was un issue verifying the signature.
      final WalletConnectError? error = authResponse.error;
      // Of a JsonRpcError if something went wrong when signing with the wallet.
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              walletAddress,
              style: const TextStyle(fontSize: 24, color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
