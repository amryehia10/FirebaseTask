import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_auth/components/facebook_button.dart';
import 'package:user_auth/components/google_button.dart';
import 'package:user_auth/screens/email_verification.dart';
import 'package:user_auth/screens/login_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Register",
                    style: TextStyle(fontSize: 30, color: Colors.deepPurple),
                  ),
                  TextFormField(
                    decoration: const InputDecoration(label: Text("Name")),
                    controller: nameController,
                    validator: (value) {
                      if (value!.length < 3) {
                        return 'Name should be at least 3 characters';
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(label: Text("Email")),
                    controller: emailController,
                    validator: (value) {
                      bool isValid = EmailValidator.validate(value!);
                      if (!isValid) {
                        return "Email isn't valid";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(label: Text("Password")),
                    controller: passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(label: Text("Confirm Password")),
                    controller: confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return "Passwords don't match";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () => {
                            if (formKey.currentState!.validate())
                              {userRegister()}
                          },
                      child: const Text("Register")),
                  const SizedBox(
                    height: 20,
                  ),
                  const Column(
                    children: [
                      Text("Or"),
                      GoogleButton(name:"register"),
                      SizedBox(
                        height: 20,
                      ),
                      FacebookButton(name: "register")
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("You have an account?"),
                      TextButton(
                          onPressed: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        const Login(),
                                  ),
                                )
                              },
                          child: const Text("Please Login."))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> userRegister() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      if (FirebaseAuth.instance.currentUser != Null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const EmailVerification(),
          ),
        );
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
