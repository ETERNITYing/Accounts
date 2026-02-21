import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  // 小工具：把 Firebase User 轉成我們的 Entity
  UserEntity _mapFirebaseUserToEntity(User user) {
    return UserEntity(id: user.uid, email: user.email ?? '');
  }

  @override
  UserEntity? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();
    if (user != null) return _mapFirebaseUserToEntity(user);
    return null;
  }

  @override
  Future<UserEntity> signIn(String email, String password) async {
    try {
      final user = await remoteDataSource.signIn(email, password);
      return _mapFirebaseUserToEntity(user);
    } catch (e) {
      throw Exception('登入發生錯誤: $e');
    }
  }

  @override
  Future<UserEntity> signUp(String email, String password) async {
    try {
      final user = await remoteDataSource.signUp(email, password);
      return _mapFirebaseUserToEntity(user);
    } catch (e) {
      throw Exception('註冊發生錯誤: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw Exception('登出發生錯誤: $e');
    }
  }
}