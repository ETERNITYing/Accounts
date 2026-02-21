import '../entities/user_entity.dart';

abstract class AuthRepository {
  // 獲取當前登入的使用者 (若未登入回傳 null)
  UserEntity? getCurrentUser();
  // 信箱密碼登入
  Future<UserEntity> signIn(String email, String password);
  // 信箱密碼註冊
  Future<UserEntity> signUp(String email, String password);
  // 登出
  Future<void> signOut();
}