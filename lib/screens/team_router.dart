import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import 'my_team_page.dart';
import 'team_manage_page.dart';

class TeamRouter extends StatelessWidget {
  const TeamRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, _) {
        final teams = teamProvider.teams;
        if (teams == null || teams.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("팀 없음")),
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/team-manage');
                },
                child: const Text("팀을 설정하세요!"),
              ),
            ),
          );
        } else {
          return const MyTeamPage();
        }
      },
    );
  }
}