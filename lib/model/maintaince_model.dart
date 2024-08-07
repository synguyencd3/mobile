List<MaintainceModel> maintainceFromJson(dynamic str) =>
    List<MaintainceModel>.from((str).map((x) => MaintainceModel.fromJson(x)));

class MaintainceModel {
  final String name;
  final String? description;
  final int cost;
  String? id;

  MaintainceModel({
    required this.name,
    required this.description,
    required this.cost,
    this.id,
  });

  MaintainceModel.fromJson(Map<String, dynamic> json)
      : description =  json.containsKey('description') ? json['description'] : '',
        name = json['name'],
        id = json.containsKey('maintenance_id') ? json['maintenance_id'] : null,
        cost = json['cost'];

  Map<String, dynamic> toJson() => {
        'description': description,
        'name': name,
        'cost': cost,
      };
}
