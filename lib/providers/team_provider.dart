import 'package:flutter/material.dart';
import '../models/team_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class TeamProvider extends ChangeNotifier {
  List<TeamModel> _teams = [];
  List<TeamModel> get teams => _teams;

  Future<void> fetchTeams() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('teams')
        .where('ownerId', isEqualTo: FirebaseService().uid)
        .get();
    _teams = snapshot.docs
        .map((doc) => TeamModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
    notifyListeners();
  }

  Future<void> saveTeam(TeamModel team) async {
    // Save team with document ID equal to user's UID
    final docRef = FirebaseFirestore.instance.collection('teams').doc(FirebaseService().uid);
    await docRef.set({
      ...team.toJson(),
      'ownerId': FirebaseService().uid,
      // 'id': docRef.id, // No need to set 'id' field since it's the UID
    });
    fetchTeams();
  }

  Future<void> deleteTeam(String teamId) async {
    await FirebaseFirestore.instance.collection('teams').doc(teamId).delete();
    fetchTeams();
  }

  Future<void> updateTeamRegion(String teamId, String region) async {
    await FirebaseFirestore.instance
        .collection('teams')
        .doc(teamId)
        .update({'region': region});
    await fetchTeams();
  }
}