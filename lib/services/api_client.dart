import 'dart:convert';
import 'package:http/http.dart' as http;

/// 後端 API base URL（一定要是 dietapi 而不是 elainediet）
const String _apiBase = 'https://dietapi.zeabur.app';

class ApiClient {
  /// 把 DateTime 轉成後端要的 yyyy-MM-dd
  static String _yyyyMmDd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// 取得指定日期的彙總（Whole/Vegetables/ProteinTotal/JunkFood）
  static Future<Map<String, dynamic>> fetchDailySummary(DateTime date) async {
    final String dateStr = _yyyyMmDd(date);

    // 正確組 URL：/summary?date=yyyy-MM-dd
    final uri = Uri.parse('$_apiBase/summary?date=$dateStr');

    final resp = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
      },
    );

    // 不是 200 時，把 body 印出來方便追查（有時候是 HTML）
    if (resp.statusCode != 200) {
      throw Exception(
        'GET $uri failed: ${resp.statusCode} ${resp.reasonPhrase}\n${resp.body}',
      );
    }

    // 確保是 JSON
    try {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      throw Exception('Response is not JSON:\n${resp.body}');
    }
  }

  /// 新增一筆紀錄（給 Record Page 用）
  static Future<void> createRecord(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_apiBase/records');

    final resp = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (resp.statusCode != 200) {
      // 把錯誤內文帶出（避免只看到 “POST /records failed”）
      throw Exception('POST $uri failed: ${resp.statusCode}\n${resp.body}');
    }

    // 如果需要用回傳的內容，可在這裡 jsonDecode(resp.body)
  }
}
