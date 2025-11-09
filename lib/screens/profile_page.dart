import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: user == null
              ? const Text('Login required.')
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty)
                          ? NetworkImage(user.photoURL!)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: (user.photoURL == null || user.photoURL!.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'No Name',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(user.email ?? 'No Email', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('UID: ${user.uid}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
        ),
      ),
    );
  }
}