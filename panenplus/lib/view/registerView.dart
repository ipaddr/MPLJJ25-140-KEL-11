import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panenplus/firebase_options.dart';
import 'package:panenplus/constants/routes.dart';

import 'package:panenplus/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Scaffold(
                appBar: AppBar(title: const Text('Register')),
                body: Column(
                  children: [
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Email Here',
                      ),
                    ),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'Enter Your Password Here',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );
                          final user = FirebaseAuth.instance.currentUser;
                          user?.sendEmailVerification();
                          Navigator.of(context).pushNamed(verifyEmailRoute);
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            await showErrorDialog(context, 'Weak Password');
                          } else if (e.code == 'email-already-in-use') {
                            await showErrorDialog(
                              context,
                              'Email Already in Use',
                            );
                          } else if (e.code == 'invalid-email') {
                            await showErrorDialog(context, 'Invalid Email');
                          } else {
                            await showErrorDialog(context, 'Error ${e.code}');
                          }
                        } catch (e) {
                          await showErrorDialog(context, e.toString());
                        }
                      },
                      child: const Text('Register'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                      },
                      child: const Text('Already registered? Login here!'),
                    ),
                  ],
                ),
              );
            default:
              return const Text('Loading... ');
          }
        },
      ),
    );
  }
}
