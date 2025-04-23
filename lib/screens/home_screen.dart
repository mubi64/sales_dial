import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path; // Use an alias for the path package
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sales_dial/screens/call_detail_screen.dart';
import 'package:sales_dial/screens/note_detail_screen.dart';
import 'package:sales_dial/screens/login_screen.dart';
import 'package:sales_dial/helpers/dio_client.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<CallLogEntry> _callLogs = [];
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  late TabController _tabController;
  late Database _database;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermission();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(dbPath, 'notes3.db'), // Use the alias for path
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY, 
            title TEXT, 
            content TEXT,
            call_id TEXT
          );
          ''',
        );
      },
      version: 1,
    );
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final notes = await _database.query('notes');
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addNote(String title, String content) async {
    await _database.insert(
      'notes',
      {'title': title, 'content': content},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _fetchNotes();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.phone.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _getCallLogs();
    } else {
      await _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.phone.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      _getCallLogs();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCallLogs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Iterable<CallLogEntry> entries = await CallLog.get();
      setState(() {
        _callLogs = entries.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching call logs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    final dioClient = await DioClient.create(); // Reinitialize DioClient
    await dioClient.cookieJar.deleteAll(); // Clear all cookies

    // Navigate to the LoginScreen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController titleController = TextEditingController();
        final TextEditingController contentController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addNote(
                  titleController.text,
                  contentController.text,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Dial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Call the logout method
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calls History'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCallHistory(),
          _buildNotesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNoteDialog();
          // if (_tabController.index == 0) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(content: Text('Add Call Log functionality here')),
          //   );
          // } else {
          //   _showAddNoteDialog();
          // }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCallHistory() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Permission to access call logs denied',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Request Permission'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _getCallLogs,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8),
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          if (_callLogs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 200.0),
              child: Center(child: Text('No call logs found')),
            );
          }
          final log = _callLogs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(
                log.name ?? log.number ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.number ?? 'No number'),
                  Row(
                    children: [
                      _getCallTypeIcon(log.callType),
                      const SizedBox(width: 4),
                      Text(_formatTimestamp(log.timestamp)),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (log.duration != null && log.duration! > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _formatDuration(log.duration),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
              isThreeLine: true,
              onTap: () => _openDetailScreen(log),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return const Center(child: Text('No notes found'));
    }

    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(note['title']),
            subtitle: Text(
              note['content'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: note['call_id'] != null
                ? Text(note['call_id'] as String)
                : null,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(
                    note: note,
                    database: _database, // Pass the database instance
                  ),
                ),
              );
              if (result == true) {
                _fetchNotes();
              }
            },
          ),
        );
      },
    );
  }

  Icon _getCallTypeIcon(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return const Icon(Icons.call_received, color: Colors.green);
      case CallType.outgoing:
        return const Icon(Icons.call_made, color: Colors.blue);
      case CallType.missed:
        return const Icon(Icons.call_missed, color: Colors.red);
      case CallType.rejected:
        return const Icon(Icons.call_missed_outgoing, color: Colors.orange);
      case CallType.blocked:
        return const Icon(Icons.block, color: Colors.red);
      case CallType.voiceMail:
        return const Icon(Icons.voicemail, color: Colors.purple);
      default:
        return const Icon(Icons.call, color: Colors.grey);
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return '';
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, y • HH:mm').format(date);
  }

  String _formatDuration(int? duration) {
    if (duration == null) return '';
    final int minutes = duration ~/ 60;
    final int seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _openDetailScreen(CallLogEntry log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallDetailScreen(
          log: log,
          database: _database, // Pass the database instance
        ),
      ),
    );
  }
}