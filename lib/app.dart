import 'package:flutter/services.dart';
import 'screens/team_router.dart';
import 'screens/place_search_page.dart';
import 'models/team_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/futsal_search_page.dart';
import 'login.dart';
import 'homepage.dart';
import 'screens/team_manage_page.dart';
import 'screens/my_team_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Futsal Queue',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.transparent,
        cardColor: Colors.white.withOpacity(0.9), // slightly more white
      ),
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/Background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
      home: const GoogleLoginPage(),
      routes: {
        '/home': (_) => const HomePage(),
        '/team-manage': (_) => const TeamManagePage(),
        '/my-team': (_) => const MyTeamPageWithDrawer(),
        '/team_router': (context) => const TeamRouterWithDrawer(),
        '/futsal-search': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, double>?;
          final lat = args?['lat'] ?? 37.5665;
          final lng = args?['lng'] ?? 126.9780;
          return FutsalSearchPage(lat: lat, lng: lng);
        },
        '/place-search': (_) => const PlaceSearchPage(),
      },
    );
  }
}

// Wrap MyTeamPage with Drawer
class MyTeamPageWithDrawer extends StatelessWidget {
  const MyTeamPageWithDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: const MyTeamPage(),
    );
  }
}

// Wrap TeamRouter with Drawer
class TeamRouterWithDrawer extends StatelessWidget {
  const TeamRouterWithDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: const TeamRouter(),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('팀 만들기'),
            onTap: () {
              Navigator.pushNamed(context, '/team-manage');
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('내 팀 보기'),
            onTap: () {
              Navigator.pushNamed(context, '/my-team');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}