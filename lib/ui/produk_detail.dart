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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Center(
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Colors.green,
                          size: 75, // ⭐ lebih besar
                        ),

                        SizedBox(height: 25),

                        Text(
                          data['namaProduk'],
                          style: TextStyle(
                            fontSize: 25, // ⭐ lebih besar
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 15),

                        Text(
                          "Kode Produk: ${data['kodeProduk']}",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(
                          "Harga: $harga",
                          style: TextStyle(
                            fontSize: 20, // ⭐ lebih besar
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),

                        SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              "Kembali",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
