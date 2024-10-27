// import 'package:final_project/components/my_button.dart';
// import 'package:final_project/components/square_tile.dart';
// import 'package:final_project/components/textfield.dart';
// import 'package:final_project/services/auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// class RegisterPage extends StatefulWidget {
//   final Function()? onTap;
//   const RegisterPage({super.key, required this.onTap});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class TermsAndConditionsPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Techy 使用者隱私權條款'),
//       ),
//       body: FutureBuilder(
//         future: _loadTermsAndConditions(),
//         builder: (context, AsyncSnapshot<String> snapshot) {
//           if (snapshot.hasData) {
//             return Markdown(data: snapshot.data!);
//           } else if (snapshot.hasError) {
//             return const Center(
//               child: Text('Error loading terms and conditions'),
//             );
//           } else {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }

//   Future<String> _loadTermsAndConditions() async {
//     return await rootBundle.loadString('lib/assets/terms_and_conditions.md');
//   }
// }

// class _RegisterPageState extends State<RegisterPage> {
//   // text editing controller
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   bool _agreedToTerms = false;

//   void _toggleAgreement(bool? newValue) {
//     if (newValue != null) {
//       setState(() {
//         _agreedToTerms = newValue;
//       });
//     }
//   }

//   // sign user up method
//   void signUserUp() async {
//     // implement wrong email message
//     void showErrorMessage(String message) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             backgroundColor: Colors.deepPurple,
//             title: Center(
//               child: Text(
//                 message,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           );
//         },
//       );
//     }

//     if (!_agreedToTerms) {
//       // If user hasn't agreed to terms, show error message
//       showErrorMessage("Please agree to the terms and conditions.");
//       return;
//     }
//     // show loading circle
//     showDialog(
//         context: context,
//         builder: (context) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         });

//     if (passwordController.text != confirmPasswordController.text) {
//       Navigator.pop(context);
//       showErrorMessage("Passwords do not match");
//       return;
//     }
//     // try creating the user
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );
//       Navigator.pop(context);
//     } catch (error) {
//       if (error is FirebaseAuthException &&
//           error.code == 'email-already-in-use') {
//         Navigator.pop(context);
//         showErrorMessage("Account already exists!");
//       } else {
//         // For other errors, just show a generic error message
//         Navigator.pop(context);
//         showErrorMessage("An error occurred. Please try again later.");
//       }
//     }
//   }

//   void navigateToTermsAndConditions() {
//     // 在這裡導到 "terms_and_conditions.md"
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 25),

//                 // logo
//                 const Icon(
//                   Icons.lock,
//                   size: 50,
//                 ),

//                 const SizedBox(height: 25),

//                 Text(
//                   'Let\'s create an account for you',
//                   style: TextStyle(
//                     color: Colors.grey[700],
//                     fontSize: 16,
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // email
//                 MyTextField(
//                   controller: emailController,
//                   hintText: 'Email',
//                   obscureText: false,
//                 ),

//                 const SizedBox(height: 10),

//                 // password
//                 MyTextField(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   obscureText: true,
//                 ),

//                 const SizedBox(height: 10),

//                 // confirm password textfield
//                 MyTextField(
//                   controller: confirmPasswordController,
//                   hintText: 'Confirm Password',
//                   obscureText: true,
//                 ),

//                 CheckboxListTile(
//                   title: RichText(
//                     text: TextSpan(
//                       text: 'I agree to the ',
//                       style: TextStyle(color: Colors.black),
//                       children: [
//                         TextSpan(
//                           text: 'Terms and Conditions',
//                           style: const TextStyle(
//                             color: Colors.blue,
//                             decoration: TextDecoration.underline,
//                           ),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = navigateToTermsAndConditions,
//                         ),
//                       ],
//                     ),
//                   ),
//                   value: _agreedToTerms,
//                   onChanged: _toggleAgreement,
//                   controlAffinity: ListTileControlAffinity.leading,
//                   activeColor: Colors.blue,
//                 ),

//                 const SizedBox(height: 10),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Text('Forget Password?',
//                           style: TextStyle(color: Colors.grey[600]))
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 MyButton(
//                   text: "Sign Up",
//                   onTap: signUserUp,
//                 ),

//                 const SizedBox(height: 50),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 25.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Divider(
//                           thickness: 0.5,
//                           color: Colors.grey[400],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                         child: Text(
//                           "Or continue with",
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(
//                           thickness: 0.5,
//                           color: Colors.grey[400],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 50),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // google
//                     SquareTile(
//                       onTap: () {},
//                       imagePath: 'lib/images/instagram.png',
//                     ),

//                     const SizedBox(width: 10),

//                     SquareTile(
//                       onTap: () => AuthService().signInWithGoogle(),
//                       imagePath: 'lib/images/google.png',
//                     ),

//                     const SizedBox(width: 10),

//                     SquareTile(
//                       onTap: () {},
//                       imagePath: 'lib/images/line.png',
//                     ),

//                     const SizedBox(width: 10),
//                     SquareTile(
//                       onTap: () {},
//                       imagePath: 'lib/images/apple.png',
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Already have an account?',
//                       style: TextStyle(color: Colors.grey[700]),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: const Text(
//                         'Login Now',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
