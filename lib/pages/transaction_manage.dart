
import 'package:flutter/material.dart';
import 'package:mobile/widgets/text_card.dart';

class TransactionManage extends StatelessWidget {
  const TransactionManage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý giao dịch'),
      ),
      body: Column(
        children: [
          text_card(
              title: 'Quản lý giao dịch hoa tiêu',
              onTap: () {
                Navigator.pushNamed(context, '/transaction');
              }),
          text_card(
              title: 'Quản lý giao dịch mua xe',
              onTap: () {
                Navigator.pushNamed(context, '/car_voice');
              }),
          text_card(
              title: 'Quản lý giao dịch phụ tùng',
              onTap: () {
                Navigator.pushNamed(context, '/accessory_invoice_manage');
              }),
          text_card(
              title: 'Quản lý giao dịch bảo dưỡng',
              onTap: () {
                Navigator.pushNamed(context, '/maintaince_invoice_manage');
              }),
        ],
      ),
    );
  }
}
