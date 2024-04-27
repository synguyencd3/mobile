
import 'dart:convert';

import 'package:mobile/model/accessory_model.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/salon_service.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/shared_service.dart';

import '../config.dart';

class AccessoryService {
  Future<List<AccessoryModel>> getAccessoriesSalon() async {
    String salonId = await SalonsService.isSalon();
    print(salonId);
    if (salonId == '') {
      return [];
    }
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
    };

    var url = Uri.http(Config.apiURL, '${Config.getSalonAccessoriesApi}/$salonId');

    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return accessoriesFromJson(data['accessory']);
    }
    return [];
  }

  Future<bool> addAccessory(AccessoryModel accessory) async {
    await APIService.refreshToken();
    var loginDetails = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      'Authorization': 'Bearer ${loginDetails?.accessToken}',
    };

    var url = Uri.http(Config.apiURL, Config.accessoryAPI);

    var response = await http.post(url, headers: requestHeaders, body: jsonEncode(accessory.toJson()));
    return response.statusCode == 201;
  }

  Future<bool> deleteAccessory(String id) async {
    await APIService.refreshToken();
    var loginDetails = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      'Authorization': 'Bearer ${loginDetails?.accessToken}',
    };

    var url = Uri.http(Config.apiURL, '${Config.accessoryAPI}/$id');

    var response = await http.delete(url, headers: requestHeaders);
    return response.statusCode == 200;
  }

  Future<bool> updateAccessory(AccessoryModel accessory) async {
    await APIService.refreshToken();
    var loginDetails = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      'Authorization': 'Bearer ${loginDetails?.accessToken}',
    };
    print(accessory.toJson());

    var url = Uri.http(Config.apiURL, '${Config.accessoryAPI}/${accessory.id}');

    var response = await http.patch(url, headers: requestHeaders, body: jsonEncode(accessory.toJson()));
    return response.statusCode == 200;
  }
}