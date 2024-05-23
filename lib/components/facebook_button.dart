import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_auth/screens/home.dart';
import 'package:user_auth/screens/login_screen.dart';

class FacebookButton extends StatefulWidget {
  final String name;
  const FacebookButton({super.key, required this.name});

  @override
  State<FacebookButton> createState() => _FacebookButtonState();
}

class _FacebookButtonState extends State<FacebookButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Text(widget.name == 'register' ? "Register with Facebook" : "Sign in with Facebook"),
      icon: Image.asset(
        'assets/facebook.jpg',
        height: 24,
        width: 24,
      ),
      onPressed: () async {
        User? user = await userRegisterWithFacebook();
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

   Future<User?> userRegisterWithFacebook() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final AccessToken? accessToken = loginResult.accessToken;
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(accessToken!.tokenString);
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        final User? user = userCredential.user;
        Navigator.pop(context);
        return user;
      } else {
        return null;
      }
     
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