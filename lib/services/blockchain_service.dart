// lib/services/blockchain_service.dart
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import '../models/defaut.dart';

class BlockchainService {
  static const String contractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3'; // Remplace par l'adresse de ton contrat
  static const String privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'; // Remplace par ta clé privée

  final Web3Client _client;
  final EthPrivateKey _credentials;
  final DeployedContract _contract;

  BlockchainService(String rpcUrl)
      : _client = Web3Client(rpcUrl, Client()),
        _credentials = EthPrivateKey.fromHex(privateKey),
        _contract = DeployedContract(
          ContractAbi.fromJson('''
            [
              {
                "inputs": [
                  {"internalType": "string", "name": "_id", "type": "string"},
                  {"internalType": "string", "name": "_description", "type": "string"},
                  {"internalType": "string", "name": "_localisation", "type": "string"},
                  {"internalType": "uint256", "name": "_date", "type": "uint256"}
                ],
                "name": "ajouterDefaut",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
              }
            ]
          ''', 'DefautsBatiment'),
          EthereumAddress.fromHex(contractAddress),
        );

  Future<void> ajouterDefaut(Defaut defaut) async {
    try {
      final function = _contract.function('ajouterDefaut');
      await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: function,
          parameters: [
            defaut.id,
            defaut.description,
            defaut.localisation,
            BigInt.from(defaut.date.millisecondsSinceEpoch ~/ 1000) // Convertir la date en timestamp
          ],
        ),
        chainId: 31337, 
      );
    } catch (e) {
      print('Erreur lors de l\'ajout du défaut à la blockchain: $e');
      throw e;
    }
  }
}
