import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProdukDetail extends StatelessWidget {
  final String produkId;

  const ProdukDetail({Key? key, required this.produkId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('produk')
          .doc(produkId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text("Detail Produk")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!;
        final harga = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(data['harga']);

        return Scaffold(
          appBar: AppBar(
            title: Text('Detail Produk'),
            backgroundColor: Colors.green,
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag,
                          color: Colors.green, size: 60),
                      SizedBox(height: 20),
                      Text("Kode Produk: ${data['kodeProduk']}"),
                      Text("Nama Produk: ${data['namaProduk']}"),
                      Text("Harga: $harga"),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Kembali"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
