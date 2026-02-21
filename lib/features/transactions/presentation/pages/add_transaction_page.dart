import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../settings/presentation/pages/ai_setting_page.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../../../accounts/presentation/bloc/account_bloc.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/services/api_key_service.dart';

class AddTransactionPage extends StatefulWidget {
  final DateTime selectedDate;

  const AddTransactionPage({super.key, required this.selectedDate});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechEnabled = false; // 紀錄引擎是否準備好/有無權限

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isExpense = true; // 預設為支出
  bool _isListening = false; // 控制麥克風動畫與狀態

  String? _selectedAccountId;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _initSpeech(); // 畫面載入時立刻初始化語音引擎
    context.read<AccountBloc>().add(LoadAccountsEvent()); // 抓取使用者帳戶列表
    context.read<CategoryBloc>().add(const LoadCategoriesEvent(TransactionType.expense)); // 抓取使用者分類清單
  }

  // 初始化語音引擎 (會自動向使用者請求麥克風權限)
  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (status) => print('語音狀態: $status'),
      onError: (error) => print('語音錯誤: $error'),
    );

// 印出這台手機支援的所有語言 ID
    var locales = await _speech.locales();
    for (var locale in locales) {
      print('支援的語言: ${locale.localeId} - ${locale.name}');
    }


    setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // 語音辨識與解析的邏輯
  void _toggleListening() async {
// 如果沒有初始化成功 (例如使用者拒絕麥克風權限)，就提早退出
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('麥克風權限未開啟或引擎初始化失敗')));
      return;
    }

    if (_speech.isListening) {
      // 正在錄音 -> 停止錄音
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      // 沒在錄音 -> 開始錄音
      setState(() => _isListening = true);

      await _speech.listen(
        // localeId: 'cmn_TW',
        // 設定語言為台灣繁體中文
        onResult: (result) {
          // 當語音引擎給出結果時會觸發這裡
          setState(() {
            // result.recognizedWords 就是你講出來的話
            // finalResult 代表這句話使用者已經講完、系統也做完最終確認了
            if (result.finalResult) {
              _isListening = false;
              // 把真正辨識出來的文字，丟給我們之前寫好的解析器
              _processVoiceCommand(result.recognizedWords);
            }
          });
        },
      );
    }
  }

  // 語意解析器
  void _processVoiceCommand(String text) async {
    if (text.isEmpty) return;
    //print(text);
    // 從本地加密空間讀取金鑰
    final apiKey = await ApiKeyService.getApiKey();

    // 如果找不到金鑰，中斷流程並提示使用者去設定頁面輸入
    if (apiKey == null || apiKey.isEmpty) {
      _showMissingKeyDialog();
      return;
    }

    // 從 BLoC 拿出目前的分類名稱清單
    String availableCategories = '未分類';
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      // 把所有分類的名字抽出來，用逗號連接
      availableCategories = categoryState.categories.map((c) => c.name).join(', ');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI 正在思考中...')),
    );

    try {
      // 初始化 Gemini 模型
      final model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.1,
          responseMimeType: 'application/json',
        ),
      );

      // 撰寫系統提示詞 (System Prompt)
      final prompt = '''
      你是一個專業的記帳助理。請分析使用者的這句話：「$text」
      請嚴格按照以下 JSON 格式回傳，不要包含 Markdown 標記，也不要說廢話。
      {
        "amount": 數字,
        "category": "字串 (請從以下清單中選擇最適合的分類：$availableCategories。若無適合的請回傳'其他')",
        "note": "字串 (精簡品項)",
        "isExpense": 布林值 (支出 true, 收入 false),
        "accountName": "字串 (使用者提及的付款方式或銀行名稱，若無提及請回傳空字串)"
      }
      ''';

      // 發送請求
      final response = await model.generateContent([Content.text(prompt)]);

      // 確保拿到乾淨的 JSON 字串 (去除可能殘留的 markdown)
      String jsonString = response.text?.trim() ?? '{}';
      jsonString = jsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      //print(jsonString);

      // 解析 JSON 並更新 UI
      final Map<String, dynamic> data = jsonDecode(jsonString);

      setState(() {
        _amountController.text = data['amount'].toString();
        _noteController.text = data['note'].toString();
        _isExpense = data['isExpense'] as bool;
        // 配對帳戶
        final aiAccountName = data['accountName']?.toString() ?? '';
        if (aiAccountName.isNotEmpty) {
          // 從目前的 bloc 狀態中把帳戶名單抓出來比對
          final accountState = context
              .read<AccountBloc>()
              .state;
          if (accountState is AccountLoaded) {
            for (var acc in accountState.accounts) {
              // 如果 AI 抓到的名字跟帳戶名字有重疊
              if (acc.name.contains(aiAccountName) ||
                  aiAccountName.contains(acc.name)) {
                _selectedAccountId = acc.id;
                break; // 找到就跳出迴圈
              }
            }
          }
        }
        // 配對分類
        final aiCategoryName = data['category']?.toString() ?? '';
        if (aiCategoryName.isNotEmpty) {
          final categoryState = context.read<CategoryBloc>().state;
          if (categoryState is CategoryLoaded) {
            for (var cat in categoryState.categories) {
              if (cat.name.contains(aiCategoryName) || aiCategoryName.contains(cat.name)) {
                _selectedCategoryId = cat.id; // 綁定分類 ID
                break;
              }
            }
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 解析完成！')),
      );

    } catch (e) {
      print('AI 解析失敗: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 解析失敗，請確認網路或 API Key 是否正確')),
      );
    }
  }

  void _showMissingKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要 API 金鑰'),
        content: const Text('您目前尚未設定 Gemini API Key，請先至「設定」頁面輸入您的專屬金鑰以啟用 AI 語音記帳功能。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('稍後再說'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiSettingPage()),
              );
              // TODO: 這裡可以實作導航到你的 SettingPage
            },
            child: const Text('前往設定'),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('請輸入有效金額')));
      return;
    }

    if (_selectedAccountId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請確實選擇帳戶與分類')),
      );
      return;
    }

    final now = DateTime.now();
    // 取得選定日期的 年/月/日，搭配現在的 時:分:秒
    final finalDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    final newRecord = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // 暫時用時間戳當 ID
      accountId: _selectedAccountId!,
      amount: amount,
      note: _noteController.text.isEmpty ? '語音記帳' : _noteController.text,
      date: finalDateTime,
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      categoryId: _selectedCategoryId!,
      userId: '',
    );

    // 透過 Bloc 觸發寫入事件
    context.read<TransactionBloc>().add(AddTransactionEvent(newRecord));

    Navigator.pop(context); // 儲存後返回上一頁
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增紀錄')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 收支切換開關
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('支出')),
                ButtonSegment(value: false, label: Text('收入')),
              ],
              selected: {_isExpense},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isExpense = newSelection.first;
                  _selectedCategoryId = null;
                });
                // 重新載入分類
                context.read<CategoryBloc>().add(LoadCategoriesEvent(
                  _isExpense ? TransactionType.expense : TransactionType.income,
                ));
              },
            ),
            const SizedBox(height: 16),

            // 金額輸入框
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '金額',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 帳戶下拉選單
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AccountLoaded) {
                  final accounts = state.accounts;

                  // 防呆：如果還沒有建立任何帳戶
                  if (accounts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('請先至「review」建立至少一個帳戶才能記帳', style: TextStyle(color: Colors.red)),
                    );
                  }

                  // 如果還沒選擇，或者選中的 ID 已經不在列表中，預設選擇第一個帳戶
                  if (_selectedAccountId == null || !accounts.any((a) => a.id == _selectedAccountId)) {
                    // 使用延遲來避免在 build 過程中直接呼叫 setState
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedAccountId = accounts.first.id);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                    elevation: 8,
                    menuMaxHeight: 300,
                    decoration: InputDecoration(
                      labelText: '扣款 / 入帳帳戶',
                      prefixIcon: const Icon(Icons.account_balance_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedAccountId = newValue;
                      });
                    },
                  );
                }
                return const SizedBox.shrink(); // Error 狀態先簡單隱藏
              },
            ),
            const SizedBox(height: 16),

            // 備註輸入框
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '備註項目',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // --- 分類選擇區塊 (UI Placeholder) ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('選擇分類', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(height: 8),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;
                  print('可用的分類');
                  print(categories.toString());

                  if (categories.isEmpty) {
                    return const Text('沒有可用的分類', style: TextStyle(color: Colors.grey));
                  }
                  // 如果還沒選擇分類，預設自動選第一個
                  if (_selectedCategoryId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedCategoryId = categories.first.id);
                    });
                  }
                  return Wrap(
                    spacing: 8.0, // 標籤之間的水平間距
                    runSpacing: 8.0, // 換行後的垂直間距
                    children: categories.map((category) {
                      return ChoiceChip(
                        label: Text(category.name),
                        selected: _selectedCategoryId == category.id,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) _selectedCategoryId = category.id;
                          });
                        },
                        selectedColor: Color(category.colorValue).withOpacity(0.3),
                        // selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Spacer(),

            // 語音按鈕 (核心設計：做得大一點、顯眼一點)
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(_isListening ? 24.0 : 20.0),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_isListening)
                      BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isListening ? '聆聽中...' : '點擊開始語音輸入', style: const TextStyle(color: Colors.grey)),
            const Spacer(),

            // 儲存按鈕
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('儲存紀錄', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}