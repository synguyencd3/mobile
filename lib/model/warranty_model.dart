

import 'maintaince_model.dart';

List<Warranty> warrantiesFromJson(dynamic str) =>
    List<Warranty>.from((str).map((x) => Warranty.fromJson(x)));

class Warranty {
  String? warrantyId;
  String? createAt;
  String? name;
  bool? reuse;
  int? limitKilometer;
  int? months;
  String? policy;
  String? note;
//  Car? car;
 // Salon?
  List<MaintainceModel>? maintenance;



  Warranty(
      {this.warrantyId,
        this.createAt,
        this.name,
        this.reuse,
        this.limitKilometer,
        this.months,
        this.policy,
        this.note,
      //  this.car
        });

  Warranty.fromJson(Map<String, dynamic> json) {
    warrantyId = json['warranty_id'];
    createAt = json['create_at'];
    name = json['name'];
    reuse = json['reuse'];
    limitKilometer = json['limit_kilometer'];
    months = json['months'];
    policy = json['policy'];
    note = json['note'];
   // salon = json['salon'] != null ? new Salon.fromJson(json['salon']) : null;
    maintenance = maintainceFromJson(json['maintenance']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
   // data['warranty_id'] = this.warrantyId;
    //data['create_at'] = this.createAt;
    data['name'] = this.name;
  //  data['reuse'] = this.reuse;
    data['limit_kilometer'] = this.limitKilometer ;
    data['months'] = this.months;
    data['policy'] = this.policy;
    data['maintenance'] = this.maintenance;
   // data['carId'] = this.car?.id;
   // data['note'] = this.note;
    // if (this.salon != null) {
    //   data['salon'] = this.salon!.toJson();
    // }
    return data;
  }
}

