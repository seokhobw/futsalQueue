import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login.dart';
import '../providers/team_provider.dart';
import 'nearby_futsal_fields_page.dart'; // 추가된 import
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({Key? key}) : super(key: key);

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<TeamProvider>(context, listen: false).fetchTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC),
        elevation: 0,
        title: const Text("My Teams"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GoogleLoginPage()),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<TeamProvider>(
        builder: (context, teamProvider, _) {
          final teams = teamProvider.teams;
          if (teams.isEmpty) {
            return const Center(child: Text("No teams registered yet."));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: teams.length,
                  itemBuilder: (ctx, idx) {
                    final team = teams[idx];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (team.logoUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  team.logoUrl!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              team.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Column(
                              children: team.members
                                  .map((m) => Text(
                                "${m.name} (${m.position})",
                                style: const TextStyle(fontSize: 14),
                              ))
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Provider.of<TeamProvider>(context, listen: false).deleteTeam(team.id);
                                await Provider.of<TeamProvider>(context, listen: false).fetchTeams();
                                final updatedTeams = Provider.of<TeamProvider>(context, listen: false).teams;
                                if (updatedTeams.isEmpty && mounted) {
                                  Navigator.pushReplacementNamed(context, '/team_router');
                                  return;
                                }
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text("Delete"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                minimumSize: const Size(64, 32),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                debugPrint("PLAY button pressed");
                                final result = await Navigator.pushNamed(context, '/place-search');
                                debugPrint("Returned from place-search: $result");
                                if (result is Map<String, dynamic>) {
                                  final lat = double.tryParse(result['lat'].toString());
                                  final lng = double.tryParse(result['lng'].toString());
                                  if (lat != null && lng != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NearbyFutsalFieldsPage(lat: lat, lng: lng),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Location information is invalid.")),
                                    );
                                  }
                                }
                              },
                              child: const Text('PLAY!'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                backgroundColor: Colors.lightBlueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Team"),
                  onPressed: () {
                    Navigator.pushNamed(context, '/team-manage');
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}