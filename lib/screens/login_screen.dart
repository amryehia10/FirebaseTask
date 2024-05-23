import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user_auth/components/facebook_button.dart';
import 'package:user_auth/components/google_button.dart';
import 'package:user_auth/screens/home.dart';
import 'package:user_auth/screens/register_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.deepPurple
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Email")),
                  controller: emailController,
                  validator: (value) {
                    bool isValid = EmailValidator.validate(value!);
                    if(!isValid || value.isEmpty) {
                      return "Email or Password is invalid";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  decoration: const InputDecoration(label: Text("Password")),
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if(value!.length < 6) {
                      return "Email or Password is invalid";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20,),
                ElevatedButton(onPressed: ()=>{
                  if(formKey.currentState!.validate()){
                      userLogin()
                    }
                }, child: const Text("Login")),
                const SizedBox(height: 20,),
                  const Column(
                    children: [
                      Text("Or"),
                      GoogleButton(name:"login"),
                      const SizedBox(
                        height: 20,
                      ),
                      FacebookButton(name: "login")
                    ],
                  ),
                  const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text("Doesn't have an account?"),
                    TextButton(onPressed: ()=>{
                      Navigator.push(context,MaterialPageRoute<void>(
                        builder: (BuildContext context) => const Register(),
                      ),)
                    }, child: const Text("Register here"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void>userLogin() async {
    showDialog(context: context, builder: (context) => const Center(
        child: CircularProgressIndicator(),
      )
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      if(mounted) {
        Navigator.push(context, 
        MaterialPageRoute<void>(builder: (BuildContext context) => const Home(),),);
      
      Fluttertoast.showToast(
            msg: "Login Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepPurple,
            textColor: Colors.white,
            fontSize: 16.0
         );
      }
      
    }on FirebaseException catch(e) {
      if(mounted) {
        Navigator.pop(context);
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
      }
    }

}