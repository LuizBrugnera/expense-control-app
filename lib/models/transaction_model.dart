class TransactionModel {
  final int? id;
  final String name;
  final double value;
  final String type;
  final String date;

  TransactionModel({
    this.id,
    required this.name,
    required this.value,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'type': type,
      'date': date,
    };
  }

  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      name: map['name'],
      value: map['value'],
      type: map['type'],
      date: map['date'],
    );
  }
}
