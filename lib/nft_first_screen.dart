import 'package:eurisko_assesment/nft_api.dart';
import 'package:flutter/material.dart';

class NFTScreen extends StatefulWidget {
  @override
  _NFTScreenState createState() => _NFTScreenState();
}

class _NFTScreenState extends State<NFTScreen> {
  List<NFT> nfts = [];
  bool isLoading = false;
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchNFTs();
  }

  Future<void> fetchNFTs() async {
    setState(() {
      isLoading = true;
    });

    var fetchedNFTs = await NFT.fetchNFTs();

    setState(() {
      nfts.addAll(fetchedNFTs);
      isLoading = false;
    });
  }

  Future<void> loadMoreNFTs() async {
    currentPage++;
    await fetchNFTs();
  }

  Widget buildLoader() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildNFTList() {
    return ListView.builder(
      itemCount: nfts.length,
      itemBuilder: (context, index) {
        var nft = nfts[index];
        return ListTile(
          leading: Image.network(nft.imageUrl),
          title: Text(nft.name),
          subtitle: Text(nft.description),
          trailing: Text('\$${nft.price.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Widget buildPaginationLoader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFTs'),
      ),
      body: isLoading
          ? buildLoader()
          : Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!isLoading &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        loadMoreNFTs();
                        return true;
                      }
                      return false;
                    },
                    child: buildNFTList(),
                  ),
                ),
                isLoading ? buildPaginationLoader() : Container(),
              ],
            ),
    );
  }
}
