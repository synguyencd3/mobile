import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/services/package_service.dart';

import '../../model/package_model.dart';
import '../../services/payment_service.dart';
import 'package:mobile/pages/loading.dart';

class ManagePackage extends StatefulWidget {
  const ManagePackage({super.key});

  @override
  State<ManagePackage> createState() => _ManagePackageState();
}

class _ManagePackageState extends State<ManagePackage> {
  late List<PackageModel> packages = [];

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero, () {
      getPackages();
    });
    super.initState();
  }

  Future<void> getPackages() async {
    //Set<String> purchasedSet = await PaymentService.getPurchasedSet();
    var purchasedPackages = await PaymentService.getPurchasedPackages();
    List<PackageModel> packagesAPI = [];
    // for (String i in purchasedSet) {
    //   packagesAPI.add(await PackageService.getDetailPackage(i));
    // }
    for (var i in purchasedPackages) {
      var package = await PackageService.getDetailPackage(i.package_id);
      package.purchasedTime = i.purchaseTime;
      package.expirationTime = i.expirationTime;
      packagesAPI.add(package);
    }
    setState(() {
      packages = packagesAPI;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gói đang sử dụng'),
      ),
      body: packages.isEmpty
          ? Loading()
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: packages.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(packages[index].name,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        Text(
                          'Ngày đăng ký: ${packages[index].purchasedTime}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text('Ngày hết hạn: ${packages[index].expirationTime}',
                            style: TextStyle(fontSize:16 )),
                        Text('Các tính năng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: packages[index]
                              .features
                              .map((e) => ListTile(
                                    title: Text(e.name),
                            leading: Icon(Icons.check),
                                  ))
                              .toList(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   children: [
                        //     TextButton(
                        //         onPressed: () {}, child: Text('Nâng cấp gói')),
                            Container(
                              alignment: Alignment.center,
                              child: TextButton(
                                  onPressed: () {}, child: Text('Gia hạn gói')),
                            ),
                        //     TextButton(
                        //         onPressed: () {}, child: Text('Hủy gói')),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
