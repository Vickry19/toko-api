import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProdukForm extends StatefulWidget {
  final List<String> existingCodes;
  final Map<String, dynamic>? initialData;

  const ProdukForm({
    Key? key,
    required this.existingCodes,
    this.initialData,
  }) : super(key: key);

  @override
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  String? _kodeError;
  late bool _isEdit;

  final NumberFormat _numberFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  // 🔥 Firestore Reference
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.initialData != null;

    if (_isEdit) {
      _kodeController.text = widget.initialData!['kodeProduk'].toString();
      _namaController.text = widget.initialData!['namaProduk'].toString();
      _hargaController.text = _numberFormat.format(
        widget.initialData!['harga'] ?? 0,
      );
    }
  }

  // =========================================
  // Format harga ribuan otomatis
  // =========================================
  void _formatHarga(String value) {
    String numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) {
      _hargaController.text = '';
      _hargaController.selection = TextSelection.fromPosition(
        const TextPosition(offset: 0),
      );
      return;
    }

    String formatted = _numberFormat.format(int.parse(numericString));
    _hargaController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      ),
    );
  }

  // =========================================
  // Validasi kode produk unik
  // =========================================
  void _validateKodeProduk(String value) {
    setState(() {
      final kode = value.trim();

      if (_isEdit && kode == widget.initialData!['kodeProduk']) {
        _kodeError = null;
        return;
      }

      if (widget.existingCodes.contains(kode)) {
        _kodeError = 'Kode produk "$kode" sudah digunakan';
      } else {
        _kodeError = null;
      }
    });
  }

  // =========================================
  // 🔥 SIMPAN / UPDATE PRODUK KE FIRESTORE
  // =========================================
  Future<void> _simpanProduk() async {
    if (_formKey.currentState!.validate()) {
      try {
        final kode = _kodeController.text.trim();
        final nama = _namaController.text.trim();
        final harga = int.parse(_hargaController.text.replaceAll('.', ''));

        final data = {
          'kodeProduk': kode,
          'namaProduk': nama,
          'harga': harga,
        };

        if (_isEdit) {
          // 🔥 UPDATE
          await _db.collection('produk').doc(widget.initialData!['id']).update(data);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produk "$nama" berhasil diperbarui!'),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          // 🔥 TAMBAH
          await _db.collection('produk').add(data);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Produk "$nama" berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // =========================================
  // UI FORM (TIDAK DIUBAH, HANYA FUNGSI DIUPDATE)
  // =========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Produk' : 'Tambah Produk'),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _kodeController,
                decoration: InputDecoration(
                  labelText: 'Kode Produk',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.code),
                  errorText: _kodeError,
                ),
                onChanged: _validateKodeProduk,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Kode produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Produk',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.shopping_bag),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga Produk',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                onChanged: _formatHarga,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (!RegExp(r'^[0-9.]+$').hasMatch(v)) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),

              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 180,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save, size: 20),
                    label: Text(
                      _isEdit ? 'Perbarui' : 'Simpan',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEdit ? Colors.blue : Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _simpanProduk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
