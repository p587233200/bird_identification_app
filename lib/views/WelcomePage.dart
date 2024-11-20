import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'globals.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('歡迎，$loggedInUsername'),
      ),
      body: Center(
        child: Text(
          '登入成功，歡迎使用者：$loggedInUsername',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}