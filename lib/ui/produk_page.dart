import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'produk_form.dart';
import 'produk_detail.dart';
import 'login_page.dart';

class ProdukPage extends StatefulWidget {
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  String _formatHarga(int harga) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(harga);
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Berhasil logout!"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ====================================================
  // 🔥 Hapus data dari Firebase
  // ====================================================
  Future<void> _hapusProduk(String docId, String namaProduk) async {
    await FirebaseFirestore.instance.collection('produk').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk "$namaProduk" berhasil dihapus!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ====================================================
  // 🔥 Navigasi Ubah Produk
  // ====================================================
  void _editProduk(DocumentSnapshot produk) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukForm(
          existingCodes: [],
          initialData: {
            'id': produk.id,
            'kodeProduk': produk['kodeProduk'],
            'namaProduk': produk['namaProduk'],
            'harga': produk['harga'],
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),

      // ========================================================
      // 🔥 STREAMBUILDER UNTUK REALTIME FIRESTORE
      // ========================================================
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('produk')
            .orderBy('namaProduk')
            .snapshots(),
        builder: (context, snapshot) {
          // Loading
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          // Jika kosong
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      color: Colors.grey[400], size: 80),
                  SizedBox(height: 16),
                  Text('Belum ada produk',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Text('Tekan tombol + untuk menambahkan produk baru'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final produk = data[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  title: Text(
                    produk['namaProduk'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "${produk['kodeProduk']} • ${_formatHarga(produk['harga'])}",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // EDIT
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editProduk(produk),
                      ),

                      // DELETE
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _hapusProduk(
                          produk.id,
                          produk['namaProduk'],
                        ),
                      ),
                    ],
                  ),

                  // DETAIL PRODUK
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProdukDetail(
                          produkId: produk.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProdukForm(existingCodes: [])),
          );
        },
      ),
    );
  }
}
