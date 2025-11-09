import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/team_model.dart';

class FutsalGamePage extends StatefulWidget {
  final String team2Name;
  final String team2LogoUrl;
  final int team1Score;
  final int team2Score;

  const FutsalGamePage({
    Key? key,
    required this.team2Name,
    required this.team2LogoUrl,
    this.team1Score = 0,
    this.team2Score = 0,
  }) : super(key: key);

  @override
  State<FutsalGamePage> createState() => _FutsalGamePageState();
}

class _FutsalGamePageState extends State<FutsalGamePage> {
  late Future<TeamModel?> _myTeamFuture;

  @override
  void initState() {
    super.initState();
    _myTeamFuture = FirebaseService().getMyTeam();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("풋살 경기")),
      body: FutureBuilder<TeamModel?>(
        future: _myTeamFuture,
        builder: (context, snapshot) {
          final team1 = snapshot.data;
          final team1Name = team1?.name ?? '우리팀';
          final team1LogoUrl = (team1?.logoUrl != null && team1!.logoUrl!.isNotEmpty)
              ? team1.logoUrl!
              : 'https://via.placeholder.com/80x80.png?text=우리팀';

          // 기본 네트워크 이미지만 사용
          final ImageProvider team1Image = NetworkImage(team1LogoUrl);
          final ImageProvider team2Image = NetworkImage(widget.team2LogoUrl);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: team1Image,
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 8),
                        Text(team1Name),
                      ],
                    ),
                    const Text("VS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: team2Image,
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                        ),
                        const SizedBox(height: 8),
                        Text(widget.team2Name),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "${widget.team1Score} : ${widget.team2Score}",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}