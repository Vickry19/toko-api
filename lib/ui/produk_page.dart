import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'produk_form.dart';
import 'produk_detail.dart';
import 'login_page.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List<String> kodeList = [];

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

  Future<void> _hapusProduk(String docId, String namaProduk) async {
    await FirebaseFirestore.instance.collection('produk').doc(docId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Produk "$namaProduk" berhasil dihapus!'),
        backgroundColor: Colors.red,
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
          IconButton(icon: const Icon(Icons.logout,size: 20,), onPressed: _logout, tooltip: 'Logout',color: Colors.redAccent)
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('produk')
            .orderBy('namaProduk')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          // List kode produk
          final existingCodes = data
              .map((d) {
                final map = d.data() as Map<String, dynamic>;
                return map['kodeProduk']?.toString();
              })
              .where((e) => e != null)
              .cast<String>()
              .toList();
          kodeList = existingCodes;

          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey[400],
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada produk',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tekan tombol + untuk menambahkan produk baru'),
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
                    horizontal: 16,
                    vertical: 10,
                  ),
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),tooltip:"Edit Produk" ,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProdukForm(
                                existingCodes: existingCodes,
                                initialData: {
                                  'id': produk.id,
                                  'kodeProduk': produk['kodeProduk'],
                                  'namaProduk': produk['namaProduk'],
                                  'harga': produk['harga'],
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),tooltip: 'Hapus Produk',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Hapus Produk"),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus produk "${produk['namaProduk']}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Batal",
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context); // tutup dialog
                                      _hapusProduk(
                                        produk.id,
                                        produk['namaProduk'],
                                      );
                                    },
                                    child: Text("Hapus"
                                        , style: TextStyle(color: Colors.black),
                                        ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProdukDetail(produkId: produk.id),
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
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        onPressed: () async {
          try {
            // Tampilkan loading saat mengambil data dari Firestore
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            // Ambil semua kode produk
            final snapshot = await FirebaseFirestore.instance
                .collection('produk')
                .get();

            // Tutup dialog loading
            Navigator.pop(context);

            // List kode produk existing
            final existingCodes = snapshot.docs
                .map((d) {
                  final map = d.data();
                  return map['kodeProduk']?.toString();
                })
                .where((e) => e != null)
                .cast<String>()
                .toList();

            // Navigasi ke halaman tambah produk
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProdukForm(existingCodes: kodeList),
              ),
            );
          } catch (e) {
            Navigator.pop(context); // Pastikan loading tertutup
            print("Error on FAB: $e");
          }
        },
      ),
    );
  }
}
