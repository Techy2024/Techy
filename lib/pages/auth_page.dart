import 'package:Techy/pages/home_page.dart';
import 'package:Techy/pages/login_or_register_page.dart';
import 'package:Techy/pages/choosePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If there's no user logged in
          if (!snapshot.hasData) {
            return LoginOrRegisterPage();
          }

          // If user is logged in, check for character_type
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('UserID')
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (context, userSnapshot) {
              // Handle loading state
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // If document exists and has character_type
              if (userSnapshot.hasData &&
                  userSnapshot.data!.exists &&
                  (userSnapshot.data!.data() as Map<String, dynamic>?)
                          ?.containsKey('character_type') ==
                      true) {
                return HomePage();
              }

              // If no document or no character_type
              return CubeMenuPage();
            },
          );
        },
      ),
    );
  }
}
