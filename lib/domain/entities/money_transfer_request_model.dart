
class MoneyTransferRequestModel {
  final String beneficiaryName;
  final String mobileNumber;
  final double amount;
  final String remarks;

  MoneyTransferRequestModel({
    required this.beneficiaryName,
    required this.mobileNumber,
    required this.amount,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'beneficiaryName': beneficiaryName,
      'mobileNumber': mobileNumber,
      'amount': amount,
      'remarks': remarks,
    };
  }
}
