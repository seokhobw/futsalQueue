// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = 'd19feddf5b731978185f828dadb03c7a'; // 너의 API 키
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  static Future<Map<String, dynamic>?> fetchWeather(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to load weather data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }
}