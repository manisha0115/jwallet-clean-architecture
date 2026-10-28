// To parse this JSON data, do
//
//     final transfermodel = transfermodelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Transfermodel transfermodelFromJson(String str) => Transfermodel.fromJson(json.decode(str));

String transfermodelToJson(Transfermodel data) => json.encode(data.toJson());

class Transfermodel {
  bool success;
  Data data;

  Transfermodel({
    required this.success,
    required this.data,
  });

  factory Transfermodel.fromJson(Map<String, dynamic> json) => Transfermodel(
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
  };
}

class Data {
  String transactionId;
  String status;
  int amount;
  String currency;
  double availableBalance;

  Data({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.availableBalance,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    transactionId: json["transactionId"],
    status: json["status"],
    amount: json["amount"],
    currency: json["currency"],
    availableBalance: json["availableBalance"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "transactionId": transactionId,
    "status": status,
    "amount": amount,
    "currency": currency,
    "availableBalance": availableBalance,
  };
}
