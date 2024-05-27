import 'package:flutter/material.dart';
import 'package:noteme/Helper/generateRandomNoteIdfunc.dart';
import 'package:noteme/classes/Note.dart';
import 'package:aws_dynamodb_api/dynamodb-2012-08-10.dart';
import 'package:noteme/providers/NotesProvider.dart';
import 'package:provider/provider.dart';

class NotePage extends StatefulWidget {
  static String id = "note_page";
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  late DynamoDB _dynamoDB;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDynamoDB();
    _fetchData();
  }

  void _initDynamoDB() {
    // Initialize DynamoDB client with your AWS credentials and region
    _dynamoDB = DynamoDB(
      region: 'us-west-1',
      credentials: AwsClientCredentials(
        accessKey: "AKIAZI2LD5HLTCJTGYUR",
        secretKey: "r/ukzFqeMqEyOi6onZXfQlHwhmcIB8ap9gVOyj4+",
      ),
    );
  }

  Future<void> _deleteFromDynamoDB(String noteId) async {
    try {
      await _dynamoDB.deleteItem(
        tableName: 'Notes',
        key: {
          'NoteId': AttributeValue(s: noteId),
        },
      );
      print('Note deleted from DynamoDB');
    } catch (e) {
      print('Error deleting note from DynamoDB: $e');
    }
  }

  Future<List<Note>> _fetchData() async {
    try {
      // Perform a scan operation on the 'Notes' table
      final result = await _dynamoDB.scan(
        tableName: 'Notes',
      );

      // Get the items from the result
      final items = result.items;

      // Convert items to List<Note>
      final notes = items!.map((item) {
        return Note(
          id: item['NoteId']?.s ?? '',
          title: item['title']?.s ?? '',
          body: item['body']?.s ?? '',
          timestamp:
              DateTime.parse(item['timestamp']?.s ?? DateTime.now().toString()),
          noteType: item['noteType']?.s ?? '',
        );
      }).toList();

      setState(() {
        _notes = notes;
        _filteredNotes = notes;
        _isLoading = false;
      });

      return notes;
    } catch (e) {
      // Handle errors
      print('Error fetching data from DynamoDB: $e');
      setState(() {
        _isLoading = false;
      });
      return [];
    }
  }

  Future<void> _writeToDynamoDB(Note note) async {
    try {
      await _dynamoDB.putItem(
        tableName: 'Notes',
        item: {
          'NoteId': AttributeValue(s: note.id),
          'title': AttributeValue(s: note.title),
          'body': AttributeValue(s: note.body),
          'timestamp': AttributeValue(s: note.timestamp.toIso8601String()),
          'noteType': AttributeValue(s: note.noteType),
        },
      );
      print('Note added to DynamoDB');
    } catch (e) {
      print('Error writing to DynamoDB: $e');
    }
  }

  Future<void> _updateToDynamoDB(Note note) async {
    try {
      await _dynamoDB.updateItem(
        tableName: 'Notes',
        key: {
          'NoteId': AttributeValue(s: note.id),
        },
        updateExpression:
            'SET title = :title, body = :body, timestamp = :timestamp, #noteType = :noteType',
        expressionAttributeValues: {
          ':title': AttributeValue(s: note.title),
          ':body': AttributeValue(s: note.body),
          ':timestamp': AttributeValue(s: note.timestamp.toIso8601String()),
          ':noteType': AttributeValue(s: note.noteType),
        },
        expressionAttributeNames: {
          '#noteType':
              'noteType', // 'type' is a reserved keyword, so we use an expression attribute name
        },
      );
      print('Note updated in DynamoDB');
    } catch (e) {
      print('Error updating note in DynamoDB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Page'),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _filterNotes('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  onChanged: (value) {
                    _filterNotes(value);
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0XFF282b30), // Light grey color
                                borderRadius: BorderRadius.circular(
                                    8.0), // Rounded corners
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(
                                  note.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  note.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _deleteFromDynamoDB(note.id);
                                      _notes.removeWhere(
                                          (element) => element.id == note.id);
                                    });
                                  },
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        _buildEditNoteDialog(context, note),
                                  );
                                },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a new note
          showDialog(
            context: context,
            builder: (context) => _buildAddNoteDialog(context),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddNoteDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController bodyController = TextEditingController();
    String dropdownValue = 'Work'; // Initial value

    return AlertDialog(
      title: const Text('Add New Note'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                dropdownValue = newValue!;
              },
              items: <String>['Work', 'Study', 'Personal']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            // Add the new note and dismiss the dialog
            final newNote = Note(
              id: generateRandomNoteId(),
              title: titleController.text,
              body: bodyController.text,
              timestamp: DateTime.now(),
              noteType: dropdownValue, // Assign the selected value
            );

            await _writeToDynamoDB(newNote);
            setState(() {
              _notes.add(newNote);
              _filteredNotes = _notes;
            });
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () {
            // Dismiss the dialog without adding the note
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildEditNoteDialog(BuildContext context, Note note) {
    TextEditingController titleController =
        TextEditingController(text: note.title);
    TextEditingController bodyController =
        TextEditingController(text: note.body);
    String dropdownValue = note.noteType; // Initial value

    return AlertDialog(
      title: const Text('Edit Note'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                dropdownValue = newValue!;
              },
              items: <String>['Work', 'Study', 'Personal']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final updatedNote = Note(
              id: note.id,
              title: titleController.text,
              body: bodyController.text,
              timestamp: note.timestamp,
              noteType: dropdownValue,
            );
            setState(() {
              int index = _notes.indexWhere((element) => element.id == note.id);
              if (index != -1) {
                _notes[index] = updatedNote;
                _filteredNotes = _notes;
              }
            });
            _updateToDynamoDB(updatedNote);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () {
            // Dismiss the dialog without updating the note
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _filterNotes(String query) {
    List<Note> filteredNotes = _notes.where((note) {
      return note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.body.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      _filteredNotes = filteredNotes;
    });
  }
}
