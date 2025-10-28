import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/meal_record.dart';

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
  /// 取得指定日期的所有紀錄
  static Future<List<MealRecord>> fetchRecordsByDate(DateTime date) async {
    final String d = _yyyyMmDd(date);
    final uri = Uri.parse("$_apiBase/records?date=$d");

    final resp = await http.get(uri, headers: {
      "Accept": "application/json",
    });

    if (resp.statusCode != 200) {
      throw Exception("GET /records failed (${resp.statusCode})");
    }

    final List data = jsonDecode(resp.body) as List;
    return data.map((e) => MealRecord.fromJson(e)).toList();
  }
  /// 上傳圖片並回傳後端提供的 URL
  static Future<String> uploadImage(Uint8List imageBytes) async {
    final uri = Uri.parse('$_apiBase/upload-image');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'upload.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

    try {
      final streamedResponse = await request.send();
      final resp = await http.Response.fromStream(streamedResponse);

      if (resp.statusCode != 200) {
        throw Exception('POST $uri failed: ${resp.statusCode}\n${resp.body}');
      }

      final data = jsonDecode(resp.body);
      if (data is Map<String, dynamic> && data.containsKey('url')) {
        String url = data['url'] as String;
        if (url.startsWith('http://')) {
          url = url.replaceFirst('http://', 'https://');
        }
        return url;
      } else {
        throw Exception('Invalid response format: missing "url" field');
      }
    } catch (e) {
      throw Exception('uploadImage failed: $e');
    }
  }
}
