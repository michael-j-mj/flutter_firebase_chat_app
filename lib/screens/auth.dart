import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? _selecetedImage;
  bool _isLogIn = true;
  String _enteredEmail = '';
  String _enteredUsername = '';
  String _enteredPassword = '';
  final _formKey = GlobalKey<FormState>();
  bool isAuthing = false;
  void _submit() async {
    bool isValid = _formKey.currentState!.validate();
    if (!isValid || (!_isLogIn && _selecetedImage == null)) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        isAuthing = true;
      });
      if (_isLogIn) {
      } else {
        //create account
        final userCred = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCred.user!.uid}.jpg');
        await storageRef.putFile(_selecetedImage!);
        String imageUrl = await storageRef.getDownloadURL();
        debugPrint('IMAGE URL :$imageUrl');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isAuthing = false;
      });

      debugPrint("$e \n${e.code}");
      if (e.code == "INVALID_LOGIN_CREDENTIALS") {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? "Auth failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!_isLogIn) ...[
                                UserImagePicker(
                                  onPickedImage: (pickedImage) {
                                    setState(() {
                                      _selecetedImage = pickedImage;
                                    });
                                  },
                                ),
                              ],
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Email Address",
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      !RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                                          .hasMatch(value)) {
                                    return "Please enter a valid email address";
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredEmail = newValue!;
                                },
                              ),
                              if (!_isLogIn)
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "User Name",
                                  ),
                                  enableSuggestions: false,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 4) {
                                      return "user name must be at least 4 characters long";
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    setState(() {
                                      _enteredUsername = newValue!;
                                    });
                                  },
                                ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: "Password",
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return "Password must be at least 6 characters long";
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredPassword = newValue!;
                                },
                              ),
                              const SizedBox(height: 10),
                              if (!isAuthing) ...[
                                ElevatedButton(
                                    onPressed: _submit,
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer),
                                    child:
                                        Text(_isLogIn ? "Login" : "SIGN UP")),
                              ] else ...[
                                const CircularProgressIndicator()
                              ],
                              if (!isAuthing) ...[
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogIn = !_isLogIn;
                                      });
                                    },
                                    child: Text(_isLogIn
                                        ? "Create an Account"
                                        : "I already have an account")),
                              ],
                            ],
                          ))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
