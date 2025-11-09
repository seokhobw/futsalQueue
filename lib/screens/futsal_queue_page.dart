import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FutsalQueuePage extends StatefulWidget {
  final String fieldName;
  const FutsalQueuePage({Key? key, required this.fieldName}) : super(key: key);

  @override
  State<FutsalQueuePage> createState() => _FutsalQueuePageState();
}

class _FutsalQueuePageState extends State<FutsalQueuePage> {
  bool _gameStarted = false;
  Duration _remaining = const Duration(seconds: 30);
  Timer? _timer;
  Timestamp? _gameStartTimestamp;

  List<QueryDocumentSnapshot>? _docs;
  Map<String, dynamic>? _firstData;
  Map<String, dynamic>? _secondData;

  @override
  void initState() {
    super.initState();
    _restoreTimer();
  }

  Future<void> _restoreTimer() async {
    final doc = await FirebaseFirestore.instance
        .collection('futsal_fields')
        .doc(widget.fieldName)
        .get();
    final data = doc.data();
    if (data != null && data['gameStart'] != null) {
      final start = (data['gameStart'] as Timestamp).toDate();
      final elapsed = DateTime.now().difference(start);
      final remainingSec = 30 - elapsed.inSeconds;
      if (remainingSec > 0) {
        setState(() {
          _gameStarted = true;
          _remaining = Duration(seconds: remainingSec);
        });
        _startPeriodicTimer();
      } else {
        _onTimerEnd();
      }
    }
  }

  void _startTimer() async {
    setState(() {
      _gameStarted = true;
      _remaining = const Duration(seconds: 30);
    });
    // Persist start time
    await FirebaseFirestore.instance
        .collection('futsal_fields')
        .doc(widget.fieldName)
        .update({'gameStart': FieldValue.serverTimestamp()});
    _startPeriodicTimer();
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        _onTimerEnd();
      } else {
        setState(() {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueRef = FirebaseFirestore.instance
        .collection('futsal_fields')
        .doc(widget.fieldName)
        .collection('queue')
        .orderBy('enter_time');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.fieldName} Queue',
          style: const TextStyle(color: Colors.white),
        ),
        flexibleSpace: Image.asset(
          'assets/game.png',
          fit: BoxFit.cover,
        ),
      ),
      body: Stack(
        children: [
          // 1) Background image
          Positioned.fill(
            child: Image.asset(
              'assets/game.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2) Semi-transparent overlay for readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          // 3) Original queue content
          StreamBuilder<QuerySnapshot>(
            stream: queueRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No teams waiting.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              _docs = docs;
              _firstData = (docs[0].data() as Map<String, dynamic>);
              _secondData = docs.length > 1 ? (docs[1].data() as Map<String, dynamic>) : null;
              final waiting = docs.length > 2 ? docs.sublist(2) : [];

              return Column(
                children: [
                  if (_firstData != null && _secondData != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: (_firstData!['logo_url'] ?? '').isNotEmpty
                                    ? NetworkImage(_firstData!['logo_url'])
                                    : null,
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                child: (_firstData!['logo_url'] == null || _firstData!['logo_url'] == '')
                                    ? const Icon(Icons.groups, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _firstData!['team_name'] ?? 'Team 1',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Text(
                            'VS',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: (_secondData!['logo_url'] ?? '').isNotEmpty
                                    ? NetworkImage(_secondData!['logo_url'])
                                    : null,
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                child: (_secondData!['logo_url'] == null || _secondData!['logo_url'] == '')
                                    ? const Icon(Icons.groups, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _secondData!['team_name'] ?? 'Team 2',
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _gameStarted
                        ? Text(
                            '${_remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${_remaining.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : ElevatedButton(onPressed: _startTimer, child: const Text('Start Game')),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Waiting Teams',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: waiting.length,
                      itemBuilder: (context, index) {
                        final data = waiting[index].data() as Map<String, dynamic>;
                        return Card(
                          color: Colors.white.withOpacity(0.1),
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (data['logo_url'] ?? '').isNotEmpty ? NetworkImage(data['logo_url']) : null,
                              backgroundColor: Colors.grey[300],
                              child: (data['logo_url'] == null || data['logo_url'] == '') ? const Icon(Icons.sports_soccer) : null,
                            ),
                            title: Text(
                              data['team_name'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _onTimerEnd() async {
    if (_docs == null || _firstData == null || _secondData == null) return;
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('Which team won?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'first'), child: Text(_firstData!['team_name'])),
          TextButton(onPressed: () => Navigator.pop(context, 'second'), child: Text(_secondData!['team_name'])),
        ],
      ),
    );
    if (result == null) return;

    final loserIndex = result == 'first' ? 1 : 0;
    final loserDoc = _docs![loserIndex];
    final data = loserDoc.data() as Map<String, dynamic>;
    final queueRef = FirebaseFirestore.instance
        .collection('futsal_fields')
        .doc(widget.fieldName)
        .collection('queue');

    await queueRef.doc(loserDoc.id).delete();
    await queueRef.add({
      'team_id': data['team_id'],
      'team_name': data['team_name'],
      'logo_url': data['logo_url'],
      'enter_time': FieldValue.serverTimestamp(),
    });

    // Clear persisted start time
    await FirebaseFirestore.instance
        .collection('futsal_fields')
        .doc(widget.fieldName)
        .update({'gameStart': FieldValue.delete()});

    setState(() {
      _gameStarted = false;
      _remaining = const Duration(seconds: 30);
    });
  }
}