import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/firebase_service.dart';
import '../models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'futsal_match_page.dart';
import 'package:proj_k/screens/futsal_queue_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/weather_service.dart';

class NearbyFutsalFieldsPage extends StatefulWidget {
  final double lat;
  final double lng;

  const NearbyFutsalFieldsPage({required this.lat, required this.lng, Key? key}) : super(key: key);

  @override
  State<NearbyFutsalFieldsPage> createState() => _NearbyFutsalFieldsPageState();
}

class _NearbyFutsalFieldsPageState extends State<NearbyFutsalFieldsPage> {
  List<Map<String, dynamic>> _places = [];
  bool _loading = true;
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchNearbyFutsalFields();
    _fetchWeather();
  }
  Future<void> _fetchWeather() async {
    try {
      final data = await WeatherService.fetchWeather(widget.lat, widget.lng);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      print('날씨 정보 오류: $e');
    }
  }

  Future<void> _fetchNearbyFutsalFields() async {
    const String apiKey = 'KakaoAK 411189b31081793cd5c3b4a8d84090d4'; // 실제 API 키로 대체 필요
    final url = Uri.parse(
      'https://dapi.kakao.com/v2/local/search/keyword.json?query=풋살장&x=${widget.lng}&y=${widget.lat}&radius=10000&sort=distance',
    );

    try {
      final response = await http.get(url, headers: {'Authorization': apiKey});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List documents = data['documents'];

        // 디버깅을 위해 모든 장소 출력
        for (final doc in documents) {
          print("🔎 장소: ${doc['place_name']}, 카테고리: ${doc['category_name']}");
        }

        setState(() {
          _places = documents.map<Map<String, dynamic>>((doc) {
            return {
              'name': doc['place_name'],
              'address': doc['road_address_name'] ?? doc['address_name'],
              'distance': double.tryParse(doc['distance'] ?? '') != null
                  ? (double.parse(doc['distance']) / 1000).toStringAsFixed(1)
                  : '-',
            };
          }).toList();
          _loading = false;
        });
      } else {
        throw Exception('API 응답 실패: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load futsal fields: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
        elevation: 0,
        title: const Text('Nearby Futsal Fields'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _places.isEmpty
              ? const Center(child: Text('No nearby futsal fields.'))
              : Column(
                  children: [
                    // 날씨 정보 표시
                    if (_weatherData != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '🌤 ${_weatherData!['weather'][0]['description']} / ${_weatherData!['main']['temp']}°C',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    // Legend for the red soccer ball icon
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.sports_soccer, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '- now playing',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _places.length,
                        itemBuilder: (context, index) {
                          final place = _places[index];
                          return FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('futsal_fields')
                                .doc(place['name'])
                                .collection('queue')
                                .limit(1)
                                .get(),
                            builder: (context, snapshot) {
                              final hasQueue = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                              return Card(
                                elevation: 8,
                                shadowColor: Colors.greenAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.greenAccent, width: 2),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      // LIVE badge
                                      if (hasQueue)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'LIVE',
                                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            if (hasQueue)
                                              const Padding(
                                                padding: EdgeInsets.only(right: 8.0),
                                                child: Icon(Icons.sports_soccer, color: Colors.red),
                                              ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    place['name'],
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    place['address'],
                                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '거리: ${place['distance']} km',
                                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.map, color: Colors.blue),
                                              onPressed: () {
                                                // 장소명과 주소를 합쳐 검색
                                                final name = place['name'] as String? ?? '';
                                                final address = place['address'] as String? ?? '';
                                                final query = '$name $address';
                                                final encoded = Uri.encodeComponent(query);
                                                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
                                                launchUrl(url, mode: LaunchMode.externalApplication);
                                              },
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                final uid = FirebaseService().uid;
                                                final fieldDoc = FirebaseFirestore.instance
                                                    .collection('futsal_fields')
                                                    .doc(place['name']);

                                                // Ensure field info exists
                                                await fieldDoc.set({
                                                  'name': place['name'],
                                                  'lat': widget.lat,
                                                  'lng': widget.lng,
                                                  'address': place['address'],
                                                }, SetOptions(merge: true));

                                                // Check if my team is already in queue
                                                final existing = await fieldDoc
                                                    .collection('queue')
                                                    .where('team_id', isEqualTo: uid)
                                                    .limit(1)
                                                    .get();

                                                if (existing.docs.isNotEmpty) {
                                                  // Already in queue: just navigate
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => FutsalQueuePage(fieldName: place['name']),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                // Not yet in queue: add entry
                                                final teamSnapshot = await FirebaseFirestore.instance
                                                    .collection('teams')
                                                    .doc(uid)
                                                    .get();
                                                final teamData = teamSnapshot.data()!;
                                                final teamName = teamData['name'] ?? 'No Name';
                                                final logoUrl = teamData['logoUrl'] ?? '';

                                                await fieldDoc.collection('queue').add({
                                                  'team_id': uid,
                                                  'team_name': teamName,
                                                  'logo_url': logoUrl,
                                                  'enter_time': FieldValue.serverTimestamp(),
                                                });

                                                // Navigate to queue
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => FutsalQueuePage(fieldName: place['name']),
                                                  ),
                                                );
                                              },
                                              child: const Text('PLAY!'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                minimumSize: const Size(60, 36),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}