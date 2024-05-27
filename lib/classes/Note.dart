class Note {
  String id; // Unique identifier for each note
  String title;
  String body;
  DateTime timestamp;
  String noteType; // Added noteType field

  Note({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.noteType, // Include noteType in the constructor
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      timestamp: DateTime.parse(json['timestamp']),
      noteType: json['noteType'], // Read noteType from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'noteType': noteType, // Include noteType in JSON
    };
  }
}
