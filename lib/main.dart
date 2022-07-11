import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'models/shopping_list.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: "AIzaSyDRIBaj2XFEjyD-wg43zLt_oZ3Ml1rd3aY",
            appId: "1:326531656045:web:42208bcd6d013199865264",
            messagingSenderId: "326531656045",
            projectId: "home-module-17",
            storageBucket: "home-module-17.appspot.com",
          )
        : null,
  );

  const emulatorHost = kIsWeb ? 'localhost' : '10.0.2.2';
  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
  await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
  await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final storage = FirebaseStorage.instance;
  GoogleSignInAccount? user;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  @override
  void initState() {
    _googleSignIn.signOut();
    setState(() {
      user = _googleSignIn.currentUser;
    });
    super.initState();
  }

  Future<void> signIn() async {
    await _googleSignIn.signIn();
    setState(() {
      user = _googleSignIn.currentUser;
    });
  }

  @override
  void dispose() {
    _googleSignIn.signOut();
    _googleSignIn.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ShoppingList>(
      create: (_) => ShoppingList(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            if (user == null) {
              return Scaffold(
                appBar: AppBar(),
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      signIn();
                    },
                    child: Text('Login'),
                  ),
                ),
              );
            } else {
              return const MyHomePage(title: 'Shopping list');
            }
          },
        ),
      ),
    );
  }
}

