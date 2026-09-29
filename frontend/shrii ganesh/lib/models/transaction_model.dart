class BankTransaction {
  final String id;
  final String senderAccountId;
  final String recipientName;
  final String recipientAccountNumber;
  final String? recipientBank;
  final double amount;
  final String? description;
  final String status; // "pending" | "approved" | "rejected"
  final DateTime createdAt;

  BankTransaction({
    required this.id,
    required this.senderAccountId,
    required this.recipientName,
    required this.recipientAccountNumber,
    this.recipientBank,
    required this.amount,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      id: json['id'] as String,
      senderAccountId: json['sender_account_id'] as String,
      recipientName: json['recipient_name'] as String,
      recipientAccountNumber: json['recipient_account_number'] as String,
      recipientBank: json['recipient_bank'] as String?,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now() : DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
}
