class TransactionModel {
  final String id;
  final String type;
  final int amount;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'timestamp': timestamp,
    };
  }
}
