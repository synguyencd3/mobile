import 'package:flutter/material.dart';
import 'package:mobile/widgets/bottom_bar.dart';
import 'package:mobile/widgets/introduction_car.dart';
import 'package:mobile/widgets/home.dart';
import 'package:mobile/modules/page.dart';
import 'package:mobile/widgets/user.dart';
import 'package:mobile/pages/notification.dart';
import 'package:mobile/pages/message.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  List<PageModule> pages = [
    PageModule(page: Home(), label: 'Xin chào,'),
    PageModule(page: IntroCar(), label: 'Sản phẩm'),
    PageModule(page: Noti(), label: 'Thông báo'),
    PageModule(page: Message(), label: 'Tin nhắn'),
    PageModule(page: User(), label: 'Tài khoản'),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(pages[_currentIndex].label),
            Icon(Icons.home),
          ],
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: pages[_currentIndex].page,
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
