import 'package:flutter/material.dart';
import 'package:noteme/classes/Note.dart';

class NotesProvider with ChangeNotifier {
  final List<Note> notes = [];

  void addNote(Note note) {
    notes.add(note);
    notifyListeners();
  }

  void updateNote(String id, String title, String body, String noteType) {
    for (var note in notes) {
      if (note.id == id) {
        note.title = title;
        note.body = body;
        note.noteType = noteType;
        note.timestamp = DateTime.now();
        notifyListeners();
        break;
      }
    }
  }

  void deleteNote(String id) {
    notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }

  Note? getNode(String id) {
    for (var note in notes) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }
}
