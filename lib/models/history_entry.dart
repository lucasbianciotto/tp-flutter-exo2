class HistoryEntry {
  int? id;
  late String operation;
  late DateTime date;

  HistoryEntry(this.operation) {
    date = DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'date' : date.millisecondsSinceEpoch
    };
  }

  HistoryEntry.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    operation = map['operation'];
    date = DateTime.fromMillisecondsSinceEpoch(map['date']);
  }

  @override
  String toString() {
    return '$date : $operation';
  }

}