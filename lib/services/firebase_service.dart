import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/team_model.dart';
import 'dart:io';

class FirebaseService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<TeamModel?> getMyTeam() async {
    // Always fetch team data using the current user's UID as document ID
    final doc = await _firestore.collection('teams').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!..['id'] = doc.id;
      return TeamModel.fromJson(data!);
    }
    return null;
  }

  Future<void> saveMyTeam(TeamModel team) async {
    final teamWithUid = team.toJson()..['uid'] = uid;
    await _firestore.collection('teams').doc(uid).set(teamWithUid);
  }
  Future<List<TeamModel>> getMyTeams() async {
    final snapshot = await _firestore
        .collection('teams')
        .where('uid', isEqualTo: uid)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return TeamModel.fromJson(data);
        })
        .toList();
  }

  Future<void> addNewTeam(TeamModel team) async {
    await _firestore.collection('teams').doc(uid).set(team.toJson());
  }

  Future<String?> uploadTeamLogo(File file) async {
    final ref = _storage.ref().child('team_logos/$uid.png');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deleteMyTeam() async {
    await _firestore.collection('teams').doc(uid).delete();
  }
}