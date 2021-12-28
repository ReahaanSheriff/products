import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:product_crud/login.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var email = new TextEditingController();
  var password = new TextEditingController();
  var confirm = new TextEditingController();

  register() async {
    var e = email.text;
    var p = password.text;
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: e, password: p);
      if (user != null) {
        await FirebaseFirestore.instance.collection('Users').doc(e).set({
          //'FullName': _fullName,
          //'MobileNumber': _mobileNumber,
          'Email': e,
          'password': p,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You have successfully Signed up'),
            duration: Duration(seconds: 5),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        print('user does not exist');
      }
    } on Exception catch (e) {
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
              Text("Signin"),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: confirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (email.text == "" ||
                        password.text == "" ||
                        confirm.text == "") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('All fields are mandatory'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } else if (password.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Password should have atleast 8 characters'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } else if (!password.text
                        .contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Password should have atleast 1 special character'),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } else if (password.text != confirm.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "password and confirm password doesn't match"),
                          duration: Duration(seconds: 5),
                        ),
                      );
                    } else {
                      register();
                    }
                  },
                  child: Text("Signin")),
              TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Login()));
                  },
                  child: Text("Already have an account? Login")),
            ],
          ),
        ),
      ),
    );
  }
}
