import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/model/car_model.dart';
import 'package:mobile/model/invoice_stat_model.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/salon_service.dart';
import 'package:mobile/services/shared_service.dart';

class StatisticService {
  static var client = http.Client();

  static Future<Map<String,Map<String, dynamic>>> getStatistic(String fromDate) async {
    await APIService.refreshToken();
    String mySalon = await SalonsService.isSalon();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.http(Config.apiURL, Config.statistic,);

    var response = await http.post(url,headers: requestHeaders, body: jsonEncode({
      "salonId": mySalon,
      "fromDate": fromDate
    }));
  print(mySalon);
    var map= <String, Map<String, dynamic>>{};
    
    var responseData = jsonDecode(response.body);
    print(responseData);
    if (responseData['status'] == 'success') {
     map['maintenances'] = getTableList(invoiceStatFromJson(responseData["maintenances"]["invoiceDb"]));
     map['buyCars'] = getTableList(invoiceStatFromJson(responseData["buyCars"]["invoiceDb"]));
     return map;
    }
    return {};
  }

  static Map<String, dynamic> getTableList(List<invoiceStat> invoices) {
    var map = <String, dynamic>{

    };
    invoices.forEach((element) {
      if (!map.containsKey(element.carName)){
       map[element.carName!]= [1, element.expense];
      }
      else
      {
        map[element.carName][0]++;
        map[element.carName][1]+=element.expense;
      }
    });
    return map;
  }


  static Future<Car?> getDetail(String carId) async {

       Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
    };

    var url = Uri.http(Config.apiURL, '${Config.getCarsAPI}/$carId');

    var response = await http.get(url);
    
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      //print(data['car']);
      return Car.fromJson(data['car']); //carsFromJson(data['data']['cars']);
    }
    return null;
  }

}