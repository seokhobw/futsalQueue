import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/kakao_api_service.dart';
import 'place_detail_page.dart';
import 'nearby_futsal_fields_page.dart';
import 'package:flutter/material.dart';

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({Key? key}) : super(key: key);

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search(String keyword) async {
    setState(() => _loading = true);
    try {
      final data = await KakaoApiService.searchByKeyword(keyword);
      setState(() {
        _results = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('검색 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // Sky-blue theme
        elevation: 0,
        title: const Text('장소 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '장소 또는 주소 입력',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_controller.text),
                ),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (ctx, idx) {
                    final place = _results[idx];
                    return Card(
                      color: Colors.white,  // solid white background
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(place['name']),
                        subtitle: Text(place['address']),
                        trailing: ElevatedButton(
                          onPressed: () {
                            final lat = double.tryParse(place['lat'].toString());
                            final lng = double.tryParse(place['lng'].toString());
                            if (lat != null && lng != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NearbyFutsalFieldsPage(lat: lat, lng: lng),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Unable to load location data.')),
                              );
                            }
                          },
                          child: const Text('Go!'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 32),
                          ),
                        ),
                        onTap: () {
                          final lat = double.tryParse(place['lat'].toString());
                          final lng = double.tryParse(place['lng'].toString());
                          if (lat != null && lng != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NearbyFutsalFieldsPage(lat: lat, lng: lng),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Unable to load location data.')),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}