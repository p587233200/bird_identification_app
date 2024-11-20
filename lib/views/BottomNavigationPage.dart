import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BirdIdentficationPage.dart';
import 'HomePage.dart';
import 'HuggingChatPage.dart';
import 'LoginPage.dart';
import 'WelcomePage.dart';
import 'globals.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _selectedIndex = 0;

  // 定義頁面列表
  // static final List<Widget> _pages = <Widget>[
  //   // 主頁面
  //   const HomePage(),
  //   // 搜索頁面
  //   const BirdIdentificationPage(),
  //   // 通知頁面
  //   const HuggingChatPage(),
  //   // 個人資料頁面
  //   loggedInUsername != null
  //       ? const WelcomePage() // 如果已登入，進入歡迎頁面
  //       : const LoginPage(),   // 否則顯示登入頁面/ 否則顯示登入頁面
  //   // const LoginPage(),
  // ];
  List<Widget> get _pages => [
    // 主頁面
    const HomePage(),
    // 搜索頁面
    const BirdIdentificationPage(),
    // 通知頁面
    const HuggingChatPage(),
    // 個人資料頁面
    loggedInUsername != null
        ? const WelcomePage() // 如果已登入，進入歡迎頁面
        : const LoginPage(),   // 否則顯示登入頁面
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 顯示當前選中的頁面
      body: _pages[_selectedIndex],

      // 底部導航欄
      bottomNavigationBar: BottomNavigationBar(
        // 設置底部導航欄的顏色模式
        type: BottomNavigationBarType.fixed,

        // 當前選中的索引
        currentIndex: _selectedIndex,

        // 選中項目的顏色
        selectedItemColor: Colors.deepPurple,

        // 未選中項目的顏色
        unselectedItemColor: Colors.grey,

        // 點擊事件
        onTap: _onItemTapped,

        // 導航欄項目–
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '鳥類辨識',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '通知',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '登入',
          ),
        ],
      ),
    );
  }
}

class Login {
  const Login();
}

