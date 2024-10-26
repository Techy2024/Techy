import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 檢查是否已經有登入的帳號
      if (await _googleSignIn.isSignedIn()) {
        print('已經有登入的Google帳號，先進行登出');
        await _googleSignIn.signOut();
      }

      print('開始Google登入流程');
      
      // 觸發Google登入流程
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // 檢查使用者是否取消登入
      if (googleUser == null) {
        print('使用者取消了Google登入');
        return null;
      }

      print('已取得Google使用者資料: ${googleUser.email}');

      try {
        // 獲取Google驗證詳情
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('已取得Google認證');

        // 創建Firebase憑證
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('準備使用Firebase進行身份驗證');

        // 使用Firebase進行身份驗證
        final UserCredential userCredential = 
            await _auth.signInWithCredential(credential);
        
        print('Firebase身份驗證成功: ${userCredential.user?.email}');
        return userCredential;

      } catch (authError) {
        print('Google認證過程發生錯誤: $authError');
        throw authError;
      }

    } catch (e) {
      print('Google登入過程發生錯誤: $e');
      if (e is FirebaseAuthException) {
        print('Firebase Auth錯誤代碼: ${e.code}');
        print('Firebase Auth錯誤訊息: ${e.message}');
      }
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('開始登出程序');
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('登出成功');
    } catch (e) {
      print('登出過程發生錯誤: $e');
      throw e;
    }
  }
}