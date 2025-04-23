import 'package:flutter/material.dart';
import 'package:sales_dial/screens/call_detail_screen.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  final Database database; // Add a parameter for the database instance

  const NoteDetailScreen({Key? key, required this.note, required this.database})
      : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  String? _associatedCall;
  late Map<String, dynamic> _mutableNote;

  @override
  void initState() {
    super.initState();
    _mutableNote = Map<String, dynamic>.from(widget.note);
  }

  Future<void> _unlinkNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Note'),
        content:
            const Text('Are you sure you want to unlink note from this call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.database
          .update(
            'notes',
            {'call_id': null},
            where: 'id = ?',
            whereArgs: [widget.note['id']],
          )
          .then((value) => {Navigator.pop(context, true)});
    }
  }

  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.database.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [widget.note['id']],
      ).then((value) => {Navigator.pop(context, true)});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mutableNote['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _mutableNote['content'],
              style: const TextStyle(fontSize: 18),
            ),
            if (_mutableNote['call_id'] != null) ...[
              const SizedBox(height: 32),
              const Text(
                'Associated Call:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text(_mutableNote['call_id']),
                  trailing: IconButton(
                      icon: const Icon(Icons.link_off_sharp, color: Colors.red),
                      onPressed: _unlinkNote),
                  onTap: () {},
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
