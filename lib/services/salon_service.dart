import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile/config.dart';
import 'package:mobile/model/car_model.dart';
import 'package:mobile/model/salon_model.dart';
import 'package:mobile/model/salon_payment_response.dart';
import 'package:mobile/model/user_model.dart';
import 'package:mobile/model/user_post_model.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/shared_service.dart';

import '../model/Payment_Method_Request.dart';
import '../model/Payment_Method_Response.dart';
import '../model/employee_model.dart';
import '../model/payment_request.dart';

class SalonsService {
  static var client = http.Client();

  static Future<List<Salon>> getAll(int page, int perPage, String search) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.SalonsAPI, {
      "page": page.toString(),
      "per_page": perPage.toString(),
      "q": search
    });

    var response = await http.get(url, headers: requestHeaders);
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return salonsFromJson(data['salons']['salons']);
    }
    return [];
  }

  static Future<List<Car>> getDetail(String? salonId, int? available) async {
    await APIService.refreshToken();
    var mySalon = await SalonsService.isSalon();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, '${Config.salonCarsAPI}/$mySalon', available!=null ? {
      'available' : available.toString()
    } : {});
    if (salonId != null) {
      url = Uri.https(Config.apiURL, '${Config.salonCarsAPI}/$salonId', available!=null ? {
        'available' : available.toString()
      } : {});
    }

    var response = await http.get(url, headers: requestHeaders);
    //print (response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("salon cars: $data");
      return carsFromJson(data['cars']);
    }
    return [];
  }

  static Future<Salon?> getMySalon() async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.mySalon);

    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var salon = Salon.fromJson(data['salon']);
      return salon;
    }
    return null;
  }

  static Future<Salon?> getSalon(String id) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, "${Config.SalonsAPI}/${id}");

    var response = await http.get(url, headers: requestHeaders);
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      var salon = Salon.fromJson(data['salon']);
      return salon;
    }
    return null;
  }

  static Future<bool?> NewSalon(Salon model) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, Config.SalonsAPI);
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var param = model.toJson();

    var request = http.MultipartRequest("POST", url);
    request.headers.addAll(requestHeaders);
    request.fields['name'] = param['name'];
    request.fields['addess'] = param['address'];
    request.fields['email'] = param['email'];
    request.fields['phoneNumber'] = param['phoneNumber'];
    request.fields['introductionMarkdown'] = param['introductionMarkdown'];

    if (model.banner != null) {
      var image =
          await http.MultipartFile.fromPath("image", model.banner!.first);
      request.files.add(image);
      model.banner?.forEach(
        (element) async {
          request.files
              .add(await http.MultipartFile.fromPath("banner", element));
        },
      );
    }
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var data = jsonDecode(responseString);
    if (data['status'] == 'success') return true;
    return false;
  }

  static Future<bool?> DeleteSalon(String id) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    String mySalon = await isSalon();
    Map<String, String> requestHeaders = {
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, "${Config.SalonsAPI}/$id");

    var response = await http
        .delete(url, headers: requestHeaders, body: {"salonId": mySalon});
    print(mySalon);
    print(response.body);
    var data = jsonDecode(response.body);
    if (data['status'] == 'success') return true;
    return false;
  }

  static Future<bool?> EditSalon(Salon model, String id) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, '${Config.SalonsAPI}/$id');
    print(url.toString());
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var param = model.toJson();

    var request = http.MultipartRequest("PATCH", url);
    request.headers.addAll(requestHeaders);
    request.fields['name'] = param['name'];
    request.fields['address'] = param['address'];
    request.fields['email'] = param['email'];
    request.fields['phoneNumber'] = param['phoneNumber'];
    request.fields['introductionMarkdown'] = param['introductionMarkdown'];

    if (model.banner != null) {
      var image =
          await http.MultipartFile.fromPath("image", model.banner!.first);
      request.files.add(image);
      model.banner?.forEach(
        (element) async {
          request.files
              .add(await http.MultipartFile.fromPath("banner", element));
        },
      );
    }
    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var data = jsonDecode(responseString);
    if (data['status'] == 'success') return true;
    return false;
  }

  static Future<String> isSalon() async {
    await APIService.refreshToken();
    var loginDetails = await SharedService.loginDetails();
    //print('access token ${loginDetails?.accessToken}');
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${loginDetails?.accessToken}',
    };
    var url = Uri.https(Config.apiURL, Config.mySalon);

    var response = await http.get(url, headers: requestHeaders);
    var responseData = jsonDecode(response.body);
    print('salon: ${response.body}');
    if (responseData['status'] == 'success') {
        return responseData['salon']['salon_id'];
    } else {
      return '';
    }
  }

  static Future<bool> acceptInvite(String token) async {
    await APIService.refreshToken();
    var loginDetails = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${loginDetails?.accessToken}',
    };
    var url = Uri.https(Config.apiURL, Config.acceptInviteAPI);
    var response = await http.post(url,
        headers: requestHeaders, body: jsonEncode({'token': token}));
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == 'success') {
      return true;
    }
    return false;
  }

  static Future<List<Employee>> getEmployees() async {
    await APIService.refreshToken();
    String mySalon = await isSalon();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.getEmployees);

    var response = await http
        .post(url, headers: requestHeaders, body: {"salonId": mySalon});
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      //print(data);
      var employees = employeesFromJson(data['salonDb']['employees']);
      return employees;
    }
    return [];
  }

  static Future<bool> setPermission(List<String> permissions, String id) async {
    await APIService.refreshToken();
    String mySalon = await isSalon();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.Permission);

    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['salonId'] = mySalon;
    data['permission'] = permissions.join(",");
    data['userId'] = id;

    var response = await http.post(url, headers: requestHeaders, body: data);
    // if (response.statusCode == 200) {
    //   print(response.body);
    //   return true;
    // }
    // return false;
    var resBody = jsonDecode(response.body);
    if (resBody['status'] == 'success') return true;
    return false;
  }

  static Future<List<Salon>> getSalonNoBlock() async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, '${Config.SalonsAPI}' + '/no-block');

    var response = await http.get(url, headers: requestHeaders);
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return salonsFromJson(data['salons']);
    }
    return [];
  }

  static Future<List<UserPostModel>> getBlockedUsers() async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.blockedUsersAPI);

    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return userPostModelFromJson(data['blockedUsers']);
    }
    return [];
  }

  static Future<bool> UnBlockUser(String userId) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.blocksAPI + '/un');

    var response = await http.post(url,
        headers: requestHeaders, body: jsonEncode({'userId': userId}));
    return response.statusCode == 201;
  }
  static Future<Set<String>> getPermission() async {
    var LoginInfo = await SharedService.loginDetails();
    return Set.from(LoginInfo!.user?.permissions ?? []);
  }

  static Future<List<SalonPaymentModel>> getPayment()  async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };
    var url = Uri.https(Config.apiURL, Config.SalonPaymentAPI);
    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return PaymentsFromJson(data['data']['data']);
    }
    return [];
  }

  static Future<bool?> createPayment(PaymentRequest request) async {
    await APIService.refreshToken();
    var salonId = await isSalon();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, Config.createSalonPaymentAPI);
    var reqBody = request.toJson();
    reqBody["salonId"] = salonId;
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };
  print(reqBody);
    var response = await http.post(url, headers: requestHeaders, body: jsonEncode(reqBody));
    var responseData = jsonDecode(response.body);
    print('response:' + response.body);
    if (responseData['status'] == 'success') {
      return true;
    }
    return false;
  }

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    await APIService.refreshToken();
    String mySalon = await SalonsService.isSalon();
    var loginInfo = await SharedService.loginDetails();
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Access-Control-Allow-Origin': "*",
      HttpHeaders.authorizationHeader: 'Bearer ${loginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, Config.salonPaymentMethodAPI, {
      "": mySalon
    });


    var response = await http.get(url, headers: requestHeaders);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return PaymentMethodsFromJson(data['data']);
    }
    return [];
  }

  static Future<bool?> deletePaymentMethod(String id) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    String mySalon = await isSalon();
    Map<String, String> requestHeaders = {
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var url = Uri.https(Config.apiURL, "${Config.salonPaymentMethodAPI}/$id");

    var response = await http
        .delete(url, headers: requestHeaders, body: {"salonId": mySalon});
    print(mySalon);
    print(response.body);
    var data = jsonDecode(response.body);
    if (data['status'] == 'success') return true;
    return false;
  }

  static Future<bool?> createPaymentMethod(PaymentMethodRequest request) async {
    await APIService.refreshToken();
    var salonId = await isSalon();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, Config.createSalonPaymentMethodAPI);
    var reqBody = request.toJson();
    reqBody["salonId"] = salonId;
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };
    print(reqBody);
    var response = await http.post(url, headers: requestHeaders, body: jsonEncode(reqBody));
    var responseData = jsonDecode(response.body);
    print('response:' + response.body);
    if (responseData['status'] == 'success') {
      return true;
    }
    return false;
  }

  static Future<bool?> updatePaymentMethod(PaymentMethod request) async {
    await APIService.refreshToken();
    var salonId = await isSalon();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, Config.salonPaymentMethodAPI);
    var reqBody = request.toJson();
    reqBody["salonId"] = salonId;
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };
    print(reqBody);
    var response = await http.patch(url, headers: requestHeaders, body: jsonEncode(reqBody));
    var responseData = jsonDecode(response.body);
    print('response:' + response.body);
    if (responseData['status'] == 'success') {
      return true;
    }
    return false;
  }

  static Future<bool> userConfirm(String id) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, Config.userConfirmAPI);
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };
    print(id);
    var response = await http.post(url, headers: requestHeaders, body: jsonEncode({
      'id': id
    }));
    print(response.body);
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == 'success') {
      return true;
    }
    return false;
  }

  static Future<bool> salonConfirm(String id) async {
    await APIService.refreshToken();
    var LoginInfo = await SharedService.loginDetails();
    var url = Uri.https(Config.apiURL, Config.salonConfirmAPI);
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${LoginInfo?.accessToken}',
    };

    var response = await http.post(url, headers: requestHeaders, body: jsonEncode({
      'id': id
    }));
    print(response.body);
    var responseData = jsonDecode(response.body);
    if (responseData['status'] == 'success') {
      return true;
    }
    return false;
  }
}
