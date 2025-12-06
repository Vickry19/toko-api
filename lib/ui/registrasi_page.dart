import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nama = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  // ========================================
  // 🔥 REGISTER MENGGUNAKAN FIREBASE AUTH + FIRESTORE
  // ========================================
  Future<void> registerUser() async {
    if (nama.text.isEmpty || email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1️⃣ Register ke Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      // 2️⃣ Simpan data user ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "nama": nama.text.trim(),
        "email": email.text.trim(),
        "created_at": DateTime.now().toIso8601String(),
      });

      setState(() => loading = false);

      // 3️⃣ Notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registrasi berhasil! Silakan login")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);

      String msg = "";
      if (e.code == "email-already-in-use") {
        msg = "Email sudah terdaftar!";
      } else if (e.code == "weak-password") {
        msg = "Password terlalu lemah!";
      } else if (e.code == "invalid-email") {
        msg = "Format email tidak valid!";
      } else {
        msg = e.message ?? "Terjadi kesalahan";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Column(
            children: [
              Icon(Icons.person_add_alt_1, size: 80, color: Colors.green[700]),
              SizedBox(height: 10),

              Text(
                "Daftar Akun",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 10),
              Text("Buat akun baru untuk melanjutkan.",
                  style: TextStyle(color: Colors.grey[600])),

              SizedBox(height: 35),

              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nama,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    TextField(
                      controller: email,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    TextField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    InkWell(
                      onTap: loading ? null : registerUser,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.greenAccent],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "DAFTAR",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "Sudah punya akun? Login",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
