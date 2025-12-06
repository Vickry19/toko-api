import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registrasi_page.dart';
import 'produk_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  // ============================
  // 🔥 LOGIN MENGGUNAKAN FIREBASE
  // ============================
  Future<void> loginUser() async {
    setState(() => loading = true);

    try {
      // LOGIN FIREBASE
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      setState(() => loading = false);

      // LOGIN BERHASIL
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login berhasil!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProdukPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);

      String message = "";

      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar";
      } else if (e.code == 'wrong-password') {
        message = "Password salah";
      } else {
        message = e.message ?? "Terjadi kesalahan";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
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
              Icon(Icons.shopping_bag, size: 80, color: Colors.green[700]),
              SizedBox(height: 15),
              
              Text(
                "Selamat Datang",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),

              SizedBox(height: 10),
              Text("Silakan login untuk melanjutkan.",
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
                      onTap: loading ? null : loginUser,
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
                                  "LOGIN",
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
                child: Text(
                  "Belum punya akun? Daftar",
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
