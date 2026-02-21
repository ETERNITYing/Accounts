import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  User? getCurrentUser();
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password);
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  @override
  Future<User> signIn(String email, String password) async {
    final userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('登入失敗：找不到使用者');
    return userCredential.user!;
  }

  @override
  Future<User> signUp(String email, String password) async {
    final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user == null) throw Exception('註冊失敗：無法建立使用者');
    return userCredential.user!;
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}