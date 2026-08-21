class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  final String phoneNumber;
  final double balance;
  final String createdAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.phoneNumber,
    required this.balance,
    required this.createdAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      ifscCode: json['ifsc_code'] as String,
      accountHolderName: json['account_holder_name'] as String,
      phoneNumber: json['phone_number'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String,
    );
  }

  String get formattedBalance => '₹${balance.toStringAsFixed(2)}';

  // Returns last 4 digits of account number masked
  String get maskedNumber {
    if (accountNumber.length >= 4) {
      return "A/C •••• ${accountNumber.substring(accountNumber.length - 4)}";
    }
    return "A/C •••• ????";
  }
}
