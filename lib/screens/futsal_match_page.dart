import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/team_model.dart';
import 'package:collection/collection.dart'; // 추가

class FutsalMatchPage extends StatelessWidget {
  final String placeName;
  final String address;
  final String teamName;

  const FutsalMatchPage({
    Key? key,
    required this.placeName,
    required this.address,
    required this.teamName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
        elevation: 0,
        title: Text('$placeName 경기 참여'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              placeName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              address,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              '이 풋살장에서의 경기에 참여하시겠습니까?',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final allTeams = await FirebaseService().getMyTeams();
                  final TeamModel? myTeam = allTeams.firstWhereOrNull(
                    (team) => team.name == teamName,
                  );
                  final String joinTeamId = myTeam?.id ?? FirebaseService().uid;
                  final String joinTeamName = myTeam?.name ?? 'No Team';
                  final String joinTeamLogoUrl = myTeam?.logoUrl ?? '';

                  // NEW LOGIC START
                  final firestore = FirebaseFirestore.instance;
                  final existingMatches = await firestore
                      .collection('matches')
                      .where('placeName', isEqualTo: placeName)
                      .where('isOngoing', isEqualTo: true)
                      .get();

                  String matchId;

                  if (existingMatches.docs.isNotEmpty) {
                    final doc = existingMatches.docs.first;
                    matchId = doc.id;

                    final data = doc.data() as Map<String, dynamic>;
                    final List<dynamic> currentTeams = data['teams'] ?? [];

                    final alreadyJoined = currentTeams.any((team) => team['teamId'] == joinTeamId);
                    if (!alreadyJoined) {
                      await firestore.collection('matches').doc(matchId).update({
                        'teams': FieldValue.arrayUnion([
                          {
                            'teamId': joinTeamId,
                            'name': joinTeamName,
                            'logoUrl': joinTeamLogoUrl,
                          }
                        ])
                      });
                    }
                  } else {
                    final newMatch = await firestore.collection('matches').add({
                      'placeName': placeName,
                      'address': address,
                      'createdAt': Timestamp.now(),
                      'isOngoing': true,
                      'teams': [
                        {
                          'teamId': joinTeamId,
                          'name': joinTeamName,
                          'logoUrl': joinTeamLogoUrl,
                        }
                      ]
                    });
                    matchId = newMatch.id;
                  }
                  // NEW LOGIC END

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FutsalMatchRoomPage(
                        matchId: matchId,
                        placeName: placeName,
                        address: address,
                      ),
                    ),
                  );
                },
                child: const Text('참여 신청하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FutsalMatchRoomPage extends StatelessWidget {
  final String matchId;
  final String placeName;
  final String address;

  const FutsalMatchRoomPage({
    Key? key,
    required this.matchId,
    required this.placeName,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchRef = FirebaseFirestore.instance.collection('matches').doc(matchId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
        elevation: 0,
        title: Text('$placeName 대기열'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: matchRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final teams = List<Map<String, dynamic>>.from(data['teams']);

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (team['logoUrl'] != null && team['logoUrl'].toString().isNotEmpty)
                      ? NetworkImage(team['logoUrl'])
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: (team['logoUrl'] == null || team['logoUrl'].toString().isEmpty)
                      ? const Icon(Icons.groups, color: Colors.white)
                      : null,
                ),
                title: Text(team['name']),
              );
            },
          );
        },
      ),
    );
  }
}
