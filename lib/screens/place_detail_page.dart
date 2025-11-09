import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlaceDetailPage extends StatelessWidget {
  final Map<String, dynamic> place;

  const PlaceDetailPage({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
        elevation: 0,
        title: Text(place['place_name'] ?? 'Futsal Field'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 Address: ${place['address_name'] ?? 'No address'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('📞 Phone: ${place['phone'] ?? 'No info'}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => _joinFutsalField(context),
                child: Text('Enter this futsal field'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinFutsalField(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final uid = user.uid;

      final teamSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .doc(uid)
          .get();

      String teamName = 'Unknown Team';
      if (teamSnapshot.exists) {
        final data = teamSnapshot.data();
        if (data != null && data['team_name'] != null) {
          teamName = data['team_name'];
        }
      }

      final fieldDoc = FirebaseFirestore.instance
          .collection('futsal_fields')
          .doc(place['place_name']);

      await fieldDoc.set({
        'name': place['place_name'],
        'lat': place['y'],
        'lng': place['x'],
        'address': place['address_name'],
        'phone': place['phone'],
      }, SetOptions(merge: true));

      await fieldDoc.collection('queue').add({
        'team_id': uid,
        'team_name': teamName,
        'enter_time': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entered ${place['place_name']} successfully!')),
      );
    }
  }
}