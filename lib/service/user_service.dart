import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final userServiceProvider = Provider<UserService>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return UserService(auth);
});

class UserService {
  UserService(this.auth);

  final FirebaseAuth auth;

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signUp(
      {required String email, required String password}) async {
    return await auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    return await auth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
