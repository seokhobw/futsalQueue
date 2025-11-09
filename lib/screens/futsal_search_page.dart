import 'package:flutter/material.dart';
import '../services/kakao_api_service.dart';

class FutsalSearchPage extends StatefulWidget {
  final double lat;
  final double lng;

  const FutsalSearchPage({Key? key, required this.lat, required this.lng}) : super(key: key);

  @override
  State<FutsalSearchPage> createState() => _FutsalSearchPageState();
}

class _FutsalSearchPageState extends State<FutsalSearchPage> {
  List<Map<String, dynamic>> _places = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    try {
      final results = await KakaoApiService.searchFutsal("풋살장", widget.lng, widget.lat);
      setState(() {
        _places = results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("검색 실패: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // Sky-blue theme
        elevation: 0,
        title: const Text("주변 풋살장 찾기"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _places.length,
        itemBuilder: (ctx, idx) {
          final place = _places[idx];
          // Card로 감싸 보기를 개선
          return Card(
            color: Colors.white.withOpacity(0.1),
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                place['name'],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(place['address']),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context, place); // 선택한 장소 반환
              },
            ),
          );
        },
      ),
    );
  }
}