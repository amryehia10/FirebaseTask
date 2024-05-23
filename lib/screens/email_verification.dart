import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_auth/screens/login_screen.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool isEmailVerified = false;
  Timer? timer;
  bool showResendButton = false;
  
  checkEmail() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if(isEmailVerified && mounted) {
      ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text("Email Successfully Verified")));
      Navigator.push(context, MaterialPageRoute<void>(
        builder: (BuildContext context) => const Login(),
      ),);

      timer?.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => checkEmail());
    Timer(const Duration(seconds: 5), () {
      setState(() {
        showResendButton = true;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "We have sent you an E-mail on ${FirebaseAuth.instance.currentUser?.email}",
              style: const TextStyle(
                fontSize: 20
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20,),
            const CircularProgressIndicator(),
            const SizedBox(height: 10,),
            const Text("Verifying"),
            if (showResendButton)
              ElevatedButton(onPressed: (){
                try {
                  FirebaseAuth.instance.currentUser
                  ?.sendEmailVerification();
                }on FirebaseException catch (e) {
                  Fluttertoast.showToast(
                    msg: e.code,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.deepPurple,
                    textColor: Colors.white,
                    fontSize: 16.0
                  );
                }
              }, child: const Text("Resend"))
          ],
        ),
      ),
    );
  }
}