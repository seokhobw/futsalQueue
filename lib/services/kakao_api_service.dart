import 'dart:convert';
import 'package:http/http.dart' as http;

class KakaoApiService {
  static const _apiKey = 'KakaoAK 411189b31081793cd5c3b4a8d84090d4'; // 실제 키로 대체

  static Future<List<Map<String, dynamic>>> searchFutsal(String keyword, double x, double y) async {
    final response = await http.get(
      Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword&x=$x&y=$y&radius=5000'),
      headers: {"Authorization": _apiKey},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['documents'] as List).map((doc) => {
        'name': doc['place_name'],
        'address': doc['road_address_name'] ?? doc['address_name'],
        'lat': doc['y'],
        'lng': doc['x'],
      }).toList();
    } else {
      throw Exception('카카오 API 호출 실패: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> searchByKeyword(String keyword) async {
    final response = await http.get(
      Uri.parse('https://dapi.kakao.com/v2/local/search/keyword.json?query=$keyword'),
      headers: {"Authorization": _apiKey},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['documents'] as List).map((doc) => {
        'name': doc['place_name'],
        'address': doc['road_address_name'] ?? doc['address_name'],
        'lat': doc['y'],
        'lng': doc['x'],
      }).toList();
    } else {
      throw Exception('카카오 키워드 검색 실패: ${response.body}');
    }
  }
  static Future<List<Map<String, dynamic>>> searchFutsalFieldsNearby(double lat, double lng) async {
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/search/category.json?category_group_code=CT1&x=$lng&y=$lat&radius=2000');
    final response = await http.get(url, headers: {
      'Authorization': 'KakaoAK 411189b31081793cd5c3b4a8d84090d4',
    });

    final data = json.decode(response.body);
    final documents = data['documents'] as List;

    return documents.map((doc) {
      return {
        'name': doc['place_name'],
        'address': doc['road_address_name'] ?? doc['address_name'],
        'lat': double.tryParse(doc['y']),
        'lng': double.tryParse(doc['x']),
        'phone': doc['phone'],
      };
    }).toList();
  }
}