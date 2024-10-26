import '../components/square_tile.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Techy 使用者隱私權條款'),
      ),
      body: FutureBuilder(
        future: _loadTermsAndConditions(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(data: snapshot.data!);
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading terms and conditions'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<String> _loadTermsAndConditions() async {
    return await rootBundle.loadString('assets/terms_and_conditions.md');
  }
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _agreedToTerms = false;

  void _toggleAgreement(bool? newValue) {
    if (newValue != null) {
      setState(() {
        _agreedToTerms = newValue;
      });
    }
  }

  // show error message
  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // sign user in method
  void signUserIn() async {
    if (!_agreedToTerms) {
      // If user hasn't agreed to terms, show error message
      showErrorMessage("Please agree to the terms and conditions.");
      return;
    }

    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign in
    try {
      await FirebaseAuth.instance.signInAnonymously();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  void navigateToTermsAndConditions() {
    // Navigate to terms and conditions page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                // const Icon(
                //   Icons.lock,
                //   size: 100,
                // ),
                Image.asset(
                  'assets/gif/ENFJ/shake_head.gif', // 使用 GIF 文件
                  fit: BoxFit.cover, // 设置适合的显示方式
                ),

                const SizedBox(height: 50),

                Text(
                  'Welcome back to Techy!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // Animated third-party login buttons (AnimatedSize for expanding effect)
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: _agreedToTerms
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google login button
                            SquareTile(
                              onTap: () => AuthService().signInWithGoogle(),
                              imagePath: 'assets/image/google.png',
                            ),

                            const SizedBox(width: 10),

                            // Other third-party login options
                            // SquareTile(
                            //   onTap: () {},
                            //   imagePath: 'lib/images/apple.png',
                            // ),
                          ],
                        )
                      : const SizedBox.shrink(), // 不顯示按鈕時用空白空間
                ),

                const SizedBox(height: 10),

                // terms and conditions checkbox (centered including checkbox)
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _agreedToTerms,
                            onChanged: _toggleAgreement,
                            activeColor: Colors.blue,
                          ),
                          GestureDetector(
                            onTap: navigateToTermsAndConditions,
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // sign in button
                // ElevatedButton(
                //   onPressed: signUserIn,
                //   child: const Text('Sign In'),
                // ),

                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          "Agree the Terms and Conditions to Login",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
