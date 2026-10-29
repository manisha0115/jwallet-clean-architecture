
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final SecureStorageService _secureStorage =
  SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkLoginSession();
  }

  Future<void> _checkLoginSession() async {
    try {
      final token = await _secureStorage.getToken();

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        debugPrint('STARTUP SESSION CHECK: TOKEN FOUND');

        Navigator.pushReplacementNamed(
          context,
          '/wallet',
          arguments: token,
        );
      } else {
        debugPrint('STARTUP SESSION CHECK: NO TOKEN');

        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      }
    } catch (e) {
      debugPrint('STARTUP SESSION CHECK: STORAGE ERROR');

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
