import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeyService {
  static const _storage = FlutterSecureStorage();
  static const _keyName = 'gemini_api_key';

  // 儲存金鑰 (之後給設定頁面呼叫)
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: _keyName, value: key);
  }

  // 讀取金鑰 (給新增紀錄頁面呼叫)
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _keyName);
  }

  // 刪除金鑰
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: _keyName);
  }
}