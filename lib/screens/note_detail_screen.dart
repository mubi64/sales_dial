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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
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
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await widget.database.update(
                        'notes',
                        {'call_id': null},
                        where: 'id = ?',
                        whereArgs: [widget.note['id']],
                      );

                      Navigator.pop(context, true);
                    },
                  ),
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
