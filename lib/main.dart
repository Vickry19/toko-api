import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/firebase_options.dart';
import '/ui/login_page.dart';
import '/ui/produk_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Toko Kita",
      theme: ThemeData(primarySwatch: Colors.green),

      // ====================================
      // 🔥 AUTO LOGIN STREAM
      // Jika user login → ProdukPage
      // Jika tidak → LoginPage
      // ====================================
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // listen perubahan login/logout
        builder: (context, snapshot) {
          // 🔄 Menampilkan loading sementara
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            );
          }

          // ✔ Jika user sudah login → langsung ke ProdukPage
          if (snapshot.hasData) {
            return ProdukPage();
          }

          // ❌ Jika tidak login → ke LoginPage
          return LoginPage();
        },
      ),
    );
  }
}
