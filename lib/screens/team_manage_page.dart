import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/team_model.dart';
import '../services/firebase_service.dart';
import '../providers/team_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TeamManagePage extends StatefulWidget {
  const TeamManagePage({Key? key}) : super(key: key);

  @override
  State<TeamManagePage> createState() => _TeamManagePageState();
}

class _TeamManagePageState extends State<TeamManagePage> {
  final _nameController = TextEditingController();
  final List<Member> _members = [];
  File? _logoFile;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _logoFile = File(picked.path));
  }

  void _addMember() {
    if (_members.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can add up to 5 members.")),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        String? selectedPos;
        final positions = ['LW', 'FW', 'GK', 'DF'];
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add Member"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                    enabled: true,
                  ),
                  Wrap(
                    spacing: 8,
                    children: positions.map((pos) {
                      return ChoiceChip(
                        label: Text(pos),
                        selected: selectedPos == pos,
                        onSelected: (_) => setStateDialog(() => selectedPos = pos),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedPos != null ? "Selected position: $selectedPos" : "Please select a position",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || selectedPos == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter both name and position.")),
                      );
                      return;
                    }
                    if (_members.length >= 5) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You can add up to 5 members.")),
                      );
                      return;
                    }
                    setState(() {
                      _members.add(Member(name: nameCtrl.text, position: selectedPos!));
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTeam() async {
    String? logoUrl;
    if (_logoFile != null) {
      logoUrl = await FirebaseService().uploadTeamLogo(_logoFile!);
    }
    final team = TeamModel(
      id: FirebaseService().uid, // Set the team document ID to user's UID
      name: _nameController.text,
      members: _members,
      logoUrl: logoUrl,
    );
    await Provider.of<TeamProvider>(context, listen: false).saveTeam(team);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Team information saved!")));
      Navigator.pushReplacementNamed(context, '/my-team');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFB3E5FC), // match My Teams color
          elevation: 0,
          title: const Text("Team Management"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/team_router'),
          ),
        ),
        body: Consumer<TeamProvider>(
          builder: (context, teamProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Team Name"),
                    enabled: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(onPressed: _pickLogo, child: const Text("Pick Logo")),
                      if (_logoFile != null) ...[
                        const SizedBox(width: 10),
                        Image.file(_logoFile!, width: 60, height: 60),
                      ]
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(onPressed: _addMember, child: const Text("Add Member")),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _members.length,
                      itemBuilder: (ctx, idx) => ListTile(
                        title: Text(_members[idx].name),
                        subtitle: Text(_members[idx].position),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: _saveTeam, child: const Text("Save")),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}