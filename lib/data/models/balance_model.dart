// To parse this JSON data, do
//
//     final balancemodel = balancemodelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Balancemodel balancemodelFromJson(String str) => Balancemodel.fromJson(json.decode(str));

String balancemodelToJson(Balancemodel data) => json.encode(data.toJson());

class Balancemodel {
  bool success;
  Data data;

  Balancemodel({
    required this.success,
    required this.data,
  });

  factory Balancemodel.fromJson(Map<String, dynamic> json) => Balancemodel(
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
  };
}

class Data {
  String walletId;
  String currency;
  double availableBalance;
  String maskedAccountNumber;

  Data({
    required this.walletId,
    required this.currency,
    required this.availableBalance,
    required this.maskedAccountNumber,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    walletId: json["walletId"],
    currency: json["currency"],
    availableBalance: json["availableBalance"]?.toDouble(),
    maskedAccountNumber: json["maskedAccountNumber"],
  );

  Map<String, dynamic> toJson() => {
    "walletId": walletId,
    "currency": currency,
    "availableBalance": availableBalance,
    "maskedAccountNumber": maskedAccountNumber,
  };
}
