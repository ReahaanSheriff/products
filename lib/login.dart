import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:product_crud/home.dart';
import 'package:product_crud/signin.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var em = new TextEditingController();
  var pass = new TextEditingController();
  static String email = "";

  login() async {
    var e = em.text;
    var p = pass.text;
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: e, password: p);

      if (user != null) {
        //successfully login
        //navigate the user to main page
        email = e;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have successfully Logged in'),
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('user does not exist');
      }
    } catch (e) {
      print("Error on register func $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
              ),
              Text("Login"),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: em,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: pass,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text("Login")),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  },
                  child: Text("Don't have an account? Signin")),
            ],
          ),
        ),
      ),
    );
  }
}
