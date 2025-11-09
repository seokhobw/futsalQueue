import 'login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/team_model.dart';
import 'screens/my_team_page.dart';
import 'screens/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
        elevation: 0,
        title: const Text('Futsal Queue'),
        actions: [
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
                backgroundImage: (user?.photoURL != null && user!.photoURL!.isNotEmpty)
                    ? NetworkImage(user.photoURL!)
                    : null,
                backgroundColor: Colors.white,
                child: (user?.photoURL == null || user!.photoURL!.isEmpty)
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () async {
          //     await FirebaseAuth.instance.signOut();
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => const GoogleLoginPage()),
          //     );
          //   },
          // ),
        ],
      ),
      body: FutureBuilder<List<TeamModel>>(
        future: FirebaseService().getMyTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            final teams = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.displayName ?? 'User'}!',
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (user?.email != null)
                    Text(
                      'Email: ${user!.email}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: teams.length,
                            itemBuilder: (context, index) {
                              final team = teams[index];
                              return Card(
                                color: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                            appBar: AppBar(title: Text(team.name)),
                                            body: Center(child: Text("팀 상세 페이지가 준비되지 않았습니다.")),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: (team.logoUrl != null && team.logoUrl!.isNotEmpty)
                                              ? NetworkImage(team.logoUrl!)
                                              : null,
                                          radius: 60,
                                          backgroundColor: Colors.grey[300],
                                          child: (team.logoUrl == null || team.logoUrl!.isEmpty)
                                              ? const Icon(Icons.groups, size: 48, color: Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          team.name,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add Team"),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(context, '/team-manage');
                            if (result == true) {
                              setState(() {}); // refresh only if team was deleted
                            }
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Show message and button if no team info
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No team information available. Please register in Team Management.'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/team-manage');
                      if (result == true) {
                        setState(() {}); // refresh only if team was deleted
                      }
                    },
                    child: const Text('Register Team'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}