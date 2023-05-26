import 'dart:convert';
import 'package:http/http.dart' as http;

class NFT {
  final String id;
  final String name;
  final String description;
  final String contractAddress;
  final String symbol;
  final double price;
  String imageUrl;

  NFT({
    required this.id,
    required this.name,
    required this.description,
    required this.contractAddress,
    required this.symbol,
    required this.price,
    required this.imageUrl,
  });

  factory NFT.fromJson(Map<String, dynamic> json) {
    return NFT(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      contractAddress: json['contract_address'],
      symbol: json['symbol'],
      price: json['floor_price']['usd'].toDouble(),
      imageUrl: json['image']['small'],
    );
  }

  static Future<List<NFT>> fetchNFTs() async {
    var listApiUrl = 'https://api.coingecko.com/api/v3/nfts/list';
    var apiUrl = 'https://api.coingecko.com/api/v3/nfts/';

    try {
      var listResponse = await http.get(Uri.parse(listApiUrl));
      if (listResponse.statusCode == 200) {
        var listData = json.decode(listResponse.body);
        if (listData is List && listData.isNotEmpty) {
          List<String> nftIds = [];
          for (var nftData in listData) {
            var id = nftData['id'];
            nftIds.add(id);
          }

          var nfts = <NFT>[];
          for (var id in nftIds) {
            try {
              var response = await http.get(Uri.parse('$apiUrl$id'));
              if (response.statusCode == 200) {
                var nftData = json.decode(response.body);
                var imageUrl = nftData['image']['small'];
                var nft = NFT.fromJson(nftData);
                nft.imageUrl = imageUrl;
                nfts.add(nft);
              } else {
                print(
                    'API request failed with status code: ${response.statusCode}');
              }
            } catch (error) {
              print('API request failed: $error');
            }
          }

          return nfts;
        }
      }
    } catch (error) {
      print('API request failed: $error');
    }

    return [];
  }
}
