import 'package:flutter/material.dart';
// 記得替換成你實際 ApiKeyService 的路徑！
import '../../../../core/services/api_key_service.dart';

class AiSettingPage extends StatefulWidget {
  const AiSettingPage({super.key});

  @override
  State<AiSettingPage> createState() => _AiSettingPageState();
}

class _AiSettingPageState extends State<AiSettingPage> {
  final TextEditingController _apiKeyController = TextEditingController();

  bool _isObscured = true; // 控制金鑰是否隱藏 (預設隱藏)
  bool _isLoading = false; // 控制儲存按鈕的載入狀態

  @override
  void initState() {
    super.initState();
    _loadExistingApiKey(); // 畫面一載入就去讀取現有的金鑰
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  // 從加密空間讀取金鑰
  Future<void> _loadExistingApiKey() async {
    final savedKey = await ApiKeyService.getApiKey();
    if (savedKey != null && savedKey.isNotEmpty) {
      setState(() {
        _apiKeyController.text = savedKey;
      });
    }
  }

  // 儲存金鑰到加密空間
  Future<void> _saveApiKey() async {
    setState(() => _isLoading = true);

    final inputKey = _apiKeyController.text.trim();

    // 如果輸入框是空的，我們就當作使用者想「清除」金鑰
    if (inputKey.isEmpty) {
      await ApiKeyService.deleteApiKey();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API 金鑰已清除。')),
        );
      }
    } else {
      // 否則就執行儲存
      await ApiKeyService.saveApiKey(inputKey);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 API 金鑰已安全儲存！AI 語音記帳已啟用。')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI 語音助理設定',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          )
        )
      ),
      // 加上 SingleChildScrollView 防止小螢幕開啟鍵盤時跑版
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AI 助理設定區塊 ---
            // const Text(
            //   'AI 語音助理設定',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.blueAccent,
            //   ),
            // ),
            // const SizedBox(height: 16),

            // 說明文字
            const Text(
              '請輸入您的 Gemini API 金鑰，以啟用智慧語音記帳功能。'
                  '您的金鑰將使用系統最高級別的加密技術，安全地儲存於您的設備本機端，絕不外流。',
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 24),

            // 金鑰輸入框
            TextField(
              controller: _apiKeyController,
              obscureText: _isObscured, // 控制是否變星星/點點
              decoration: InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                prefixIcon: const Icon(Icons.vpn_key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    // 切換顯示/隱藏
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),

            // 儲存按鈕
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _saveApiKey,
                icon: _isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? '儲存中...' : '儲存金鑰', style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 40),

            // --- 申請教學提示 (UX 加分項目) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '如何獲取金鑰？\n請前往 Google AI Studio 網站，登入您的 Google 帳號即可免費建立 API 金鑰。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}