import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'BottomNavigationPage.dart';
import 'RegisterPage.dart';
import 'globals.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  // 模擬登入操作
  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    // print(username);
    // print(password);

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫使用者名稱和密碼')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 登入 API URL
    const String loginUrl = 'http://10.0.2.2:5001/POST/login'; // 替換為你的 API URL

    // 創建帳號和密碼的 JSON 對象
    final Map<String, String> loginData = {
      'username': username,
      'password': password,
    };

    try {
      // 發送 POST 請求
      print(json.encode(loginData));
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData), // 將資料轉換為 JSON
      );

      if (response.statusCode == 201) {
        // 假設後端返回的是登入成功的訊息
        final responseBody = json.decode(response.body); // 解析伺服器回應
        loggedInUsername = responseBody['username']; // 假設回應包含 username

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登入成功')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationPage()),
        );
      } else {
        // 如果登入失敗，顯示錯誤訊息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登入失敗，請檢查帳號或密碼')),
        );
      }
    } catch (e) {
      // 發生錯誤時顯示錯誤訊息
      print('登入請求失敗：$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入失敗：$e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登入頁面'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '使用者名稱',
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密碼',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('登入'),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text('還沒有帳號？前往註冊'),
            ),
          ],
        ),
      ),
    );
  }
}