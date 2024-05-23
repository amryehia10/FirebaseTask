import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user_auth/screens/home.dart';
import 'package:user_auth/screens/login_screen.dart';

class GoogleButton extends StatefulWidget {
  final String name;
  const GoogleButton({super.key, required this.name});

  @override
  State<GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Text(widget.name == 'register' ? "Register with Google" : "Sign in with Google"),
      icon: Image.asset(
        'assets/google.png',
        height: 24,
        width: 24,
      ),
      onPressed: () async {
        User? user = await userRegisterWithGoogle();
        if (user != null) {
          Fluttertoast.showToast(
            msg: (widget.name == 'register' ?"Registerd Successfuly: ${user.email}":"Login Successfuly: ${user.email}"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => (widget.name == 'register' ? const Login() : const Home()),
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Register Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
    );
  }

  Future<User?> userRegisterWithGoogle() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      Navigator.pop(context);
      return user;
    } on FirebaseException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: e.code,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepPurple,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }
}
