// import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class FirebaseService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//       //   scopes: [
//       //     'email',
//       //     'https://www.googleapis.com/auth/contacts.readonly',
//       //   ],
//       );

//   Future<User?> signInwithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleSignInAccount =
//           await _googleSignIn.signIn();

//       log("USER EMAIL : ${googleSignInAccount!.email}");
//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//       await _auth.signInWithCredential(credential);
//       User? user = FirebaseAuth.instance.currentUser;
//       log("USER GOOGLE ACCESS TOKEN : ${googleSignInAuthentication.accessToken}");
//       log("USER GOOGLE ID TOKEN : ${googleSignInAuthentication.idToken}");

//       log("USER GOOGLE : $user");
//       log("USER GOOGLE TOKEN AUTH ID : ${await user?.getIdToken()}");
//       if (user != null) {
//         return user;
//       }
//       return null;
//     } on FirebaseAuthException catch (e) {
//       log("Firebase ERROR Exception : " + e.message.toString());
//       rethrow;
//     }
//   }

//   Future<bool> isGoogleSignIn() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       return true;
//     }
//     return false;
//   }

//   Future<void> signOutFromGoogle() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
