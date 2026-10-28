// To parse this JSON data, do
//
//     final transactionsmodel = transactionsmodelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Transactionsmodel transactionsmodelFromJson(String str) => Transactionsmodel.fromJson(json.decode(str));

String transactionsmodelToJson(Transactionsmodel data) => json.encode(data.toJson());

class Transactionsmodel {
  bool success;
  List<Datum> data;

  Transactionsmodel({
    required this.success,
    required this.data,
  });

  factory Transactionsmodel.fromJson(Map<String, dynamic> json) => Transactionsmodel(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String id;
  String type;
  int amount;
  String currency;
  String beneficiaryName;
  String status;
  DateTime createdAt;

  Datum({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.beneficiaryName,
    required this.status,
    required this.createdAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    type: json["type"],
    amount: json["amount"],
    currency: json["currency"],
    beneficiaryName: json["beneficiaryName"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "amount": amount,
    "currency": currency,
    "beneficiaryName": beneficiaryName,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
  };
}
