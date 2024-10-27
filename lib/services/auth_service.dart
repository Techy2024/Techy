import 'package:final_project/pages/choosePage.dart';
import 'package:final_project/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Sign out from any existing Google session
      await GoogleSignIn().signOut();

      // Begin new sign in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) {
        print('Google sign-in was cancelled.');
        return;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get user ID
      final String uid = userCredential.user!.uid;

      // Check if user document exists and has character_type
      final userDoc =
          await FirebaseFirestore.instance.collection('UserID').doc(uid).get();

      // Check if document exists and has character_type field
      if (userDoc.exists &&
          userDoc.data()?.containsKey('character_type') == true) {
        // User has character_type, navigate to HomePage
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        // User doesn't exist or doesn't have character_type, navigate to choosePage
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CubeMenuPage()),
          );
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to sign in: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
