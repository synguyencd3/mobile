import 'package:flutter/material.dart';
import 'package:mobile/widgets/text_card.dart';
import 'package:mobile/services/salon_service.dart';

import '../model/car_model.dart';
import 'package:mobile/services/payment_service.dart';

class Manage extends StatefulWidget {
  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  List<Car> cars = [];
  Set<String> permission = {};
  Set<String> keyMap = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getMySalon();
      getPermission();
      getKeyMap();
    });
  }

  void getPermission() async {
    var data = await SalonsService.getPermission();
    setState(() {
      permission = data;
    });
  }

  void getMySalon() async {
    var salon = await SalonsService.getMySalon();
    //print(salon!.cars?[0].description);
    setState(() {
      cars = salon!.cars;
    });
  }
  void getKeyMap() async {
    var data = await PaymentService.getKeySet();
    setState(() {
      keyMap = data;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quản lý'),
          backgroundColor: Colors.lightBlue,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              text_card(
                headingIcon: Icons.inventory,
                  title: 'Quản lý gói',
                  onTap: () {
                   Navigator.pushNamed(context, '/package/manage');
                  }),
              keyMap.contains("f3") &&
             ( permission.contains("OWNER") || permission.contains("R_EMP")) ?
              text_card(
                headingIcon: Icons.person,
                  title: 'Quản lý nhân viên',
                  onTap: () {
                    Navigator.pushNamed(context, '/employee_management');
                  }) : Container(),
              permission.contains("OWNER")  ?
              text_card(
                  headingIcon: Icons.warning,
                  title: 'Quản lý quyền',
                  onTap: () {
                    Navigator.pushNamed(context, '/authorities');
                  }) : Container(),
              text_card(
                headingIcon: Icons.block,
                  title: 'Quản lý hoa tiêu bị chặn',
                  onTap: () {
                    Navigator.pushNamed(context, '/blocked_user');
                  }),
              text_card(
                headingIcon: Icons.post_add,
                  title: 'Quản lý bài đăng kết nối',
                  onTap: () {
                    Navigator.pushNamed(context, '/post');
                  }),
              text_card(
                headingIcon: Icons.connect_without_contact,
                  title: 'Quản lý kết nối với hoa tiêu',
                  onTap: () {
                    Navigator.pushNamed(context, '/connection');
                  }),
              keyMap.contains("f2") &&
              (permission.contains("OWNER") || permission.contains("R_CAR")) ?
              text_card(
                  headingIcon: Icons.directions_car_filled,
                  title: 'Quản lý xe',
                  onTap: () {
                  Navigator.pushNamed(context, '/listing/manage',arguments: cars);
                  }): Container(),
              keyMap.contains("f5") &&
              (permission.contains("OWNER") || permission.contains("R_WRT")) ?
              text_card(
                headingIcon: Icons.shield,
                  title: 'Quản lý bảo hành',
                  onTap: () {
                    Navigator.pushNamed(context, '/warranty_list');
                  }): Container(),
              keyMap.contains("f6") &&
              permission.contains("OWNER") || permission.contains("R_MT") ?
              text_card(
                headingIcon: Icons.build,
                  title: 'Quản lý bảo dưỡng',
                  onTap: () {
                    Navigator.pushNamed(context, '/maintaince_manage');
                  }): Container(),
              keyMap.contains("f8") ?
              text_card(
                headingIcon: Icons.toys,
                  title: 'Quản lý phụ tùng',
                  onTap: () {
                   Navigator.pushNamed(context, '/accessory_manage');
                  }): Container(),
              permission.contains("OWNER") || permission.contains("R_IV") ?
              text_card(
                headingIcon: Icons.area_chart,
                  title: 'Báo cáo doanh thu',
                  onTap: () {
                    Navigator.pushNamed(context, '/statistic');
                  }): Container(),
              text_card(
                headingIcon: Icons.sync,
                  title: 'Quản lý qui trình',
                  onTap: () {
                    Navigator.pushNamed(context, '/process_list');
                  }),
              keyMap.contains("f7") &&
              (permission.contains("OWNER") || permission.contains("R_IV")) ?
              text_card(
                headingIcon: Icons.payment,
                  title: 'Quản lý giao dịch',
                  onTap: () {
                    Navigator.pushNamed(context, '/transaction_manage');
                  }): Container(),
              text_card(
                  headingIcon: Icons.discount,
                  title: 'Quản lý khuyến mãi',
                  onTap: () {
                    Navigator.pushNamed(context, '/salon_promotion');
                  }),
            ],
          ),
        ));
  }
}
