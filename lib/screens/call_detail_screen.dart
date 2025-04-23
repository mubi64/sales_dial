import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'note_detail_screen.dart';

class CallDetailScreen extends StatefulWidget {
  final CallLogEntry log;
  final Database database; // Add a parameter for the database instance

  const CallDetailScreen({Key? key, required this.log, required this.database})
      : super(key: key);

  @override
  _CallDetailScreenState createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends State<CallDetailScreen> {
  Map<String, dynamic>? _attachedNote;

  @override
  void initState() {
    super.initState();
    _fetchAttachedNote();
  }

  Future<void> _fetchAttachedNote() async {
    final result = await widget.database.query(
      'notes',
      where: 'call_id = ?',
      whereArgs: [widget.log.number],
      limit: 1,
    );
    if (result.isNotEmpty) {
      setState(() {
        _attachedNote = result.first;
      });
    } else {
      setState(() {
        _attachedNote = null;
      });
    }
  }

  void _showAttachNoteDialog() {
    final currentContext = context; // Store the current BuildContext
    widget.database.query('notes', where: 'call_id IS NULL').then((notes) {
      showDialog(
        context: currentContext, // Use the stored BuildContext
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Attach Note'),
            content: notes.isEmpty
                ? const Text('No notes available to attach.')
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return ListTile(
                          title: Text(note['title'] as String),
                          subtitle: Text(
                            note['content'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () async {
                            await widget.database.update(
                              'notes',
                              {'call_id': widget.log.number},
                              where: 'id = ?',
                              whereArgs: [note['id']],
                            );
                            _fetchAttachedNote(); // Refresh the attached note
                            Navigator.of(currentContext)
                                .pop(); // Close the dialog
                          },
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(currentContext).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    });
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Unknown';
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMMM d, y - HH:mm:ss').format(date);
  }

  String _formatDuration(int? duration) {
    if (duration == null || duration == 0) return 'Unknown';
    final int hours = duration ~/ 3600;
    final int minutes = (duration % 3600) ~/ 60;
    final int seconds = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _getCallTypeString(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return 'Incoming';
      case CallType.outgoing:
        return 'Outgoing';
      case CallType.missed:
        return 'Missed';
      case CallType.rejected:
        return 'Rejected';
      case CallType.blocked:
        return 'Blocked';
      case CallType.voiceMail:
        return 'Voicemail';
      default:
        return 'Unknown';
    }
  }

  Icon _getCallTypeIcon(CallType? callType) {
    switch (callType) {
      case CallType.incoming:
        return const Icon(Icons.call_received, color: Colors.green, size: 36);
      case CallType.outgoing:
        return const Icon(Icons.call_made, color: Colors.blue, size: 36);
      case CallType.missed:
        return const Icon(Icons.call_missed, color: Colors.red, size: 36);
      case CallType.rejected:
        return const Icon(Icons.call_missed_outgoing,
            color: Colors.orange, size: 36);
      case CallType.blocked:
        return const Icon(Icons.block, color: Colors.red, size: 36);
      case CallType.voiceMail:
        return const Icon(Icons.voicemail, color: Colors.purple, size: 36);
      default:
        return const Icon(Icons.call, color: Colors.grey, size: 36);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality would go here')),
              );
            },
          ),
          if (_attachedNote == null) ...[
            IconButton(
              icon: const Icon(Icons.note_add),
              onPressed: _showAttachNoteDialog,
            )
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact info section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    child: widget.log.name != null
                        ? Text(
                            widget.log.name![0].toUpperCase(),
                            style: const TextStyle(fontSize: 36),
                          )
                        : const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.log.name ?? 'Unknown Contact',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.log.number ?? 'No number',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Call details section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _getCallTypeIcon(widget.log.callType),
                        const SizedBox(width: 12),
                        Text(
                          _getCallTypeString(widget.log.callType),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _detailRow(
                        'Date & Time', _formatTimestamp(widget.log.timestamp)),
                    const SizedBox(height: 12),
                    _detailRow(
                        'Duration', _formatDuration(widget.log.duration)),
                    if (widget.log.phoneAccountId != null) ...[
                      const SizedBox(height: 12),
                      _detailRow('SIM', widget.log.phoneAccountId!),
                    ],
                  ],
                ),
              ),
            ),

            // AttachedNote details section
            if (_attachedNote != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note_add_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 36),
                          const SizedBox(width: 12),
                          const Text(
                            'Attached Note',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      ListTile(
                        title: Text(_attachedNote!['title']),
                        subtitle: Text(
                          _attachedNote!['content'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteDetailScreen(
                                note: _attachedNote!,
                                database: widget
                                    .database, // Pass the database instance
                              ),
                            ),
                          );
                          if (result == true) {
                            _fetchAttachedNote();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_attachedNote == null) ...[
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.note_add),
                  label: const Text('Attach a Note'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 12),
                  ),
                  onPressed: _showAttachNoteDialog,
                ),
              ),
            ],

            if (_attachedNote != null) ...[
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Send to CRM'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sending to CRM...')),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(
                  context,
                  Icons.call,
                  'Call',
                  Colors.green,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Calling ${widget.log.number}')),
                    );
                  },
                ),
                _actionButton(
                  context,
                  Icons.message,
                  'Message',
                  Colors.blue,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Messaging ${widget.log.number}')),
                    );
                  },
                ),
                _actionButton(
                  context,
                  Icons
                      .person_add, // Changed from add_to_contacts to person_add
                  'Add',
                  Colors.orange,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add to contacts')),
                    );
                  },
                ),
                _actionButton(
                  context,
                  Icons.block,
                  'Block',
                  Colors.red,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Block this number')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onPressed) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
