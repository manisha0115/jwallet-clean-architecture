import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  bool success;
  Data data;

  LoginResponseModel({
    required this.success,
    required this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
        success: json['success'] == true,
        data: Data.fromJson(
          Map<String, dynamic>.from(json['data'] as Map),
        ),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data.toJson(),
      };
}

class Data {
  String accessToken;
  LoginUserModel user;

  Data({
    required this.accessToken,
    required this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        accessToken: json['accessToken']?.toString() ?? '',
        user: LoginUserModel.fromJson(
          Map<String, dynamic>.from(json['user'] as Map),
        ),
      );

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'user': user.toJson(),
      };
}

class LoginUserModel {
  String id;
  String name;
  String email;

  LoginUserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) => LoginUserModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
