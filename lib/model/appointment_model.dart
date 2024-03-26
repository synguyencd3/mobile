
List<AppointmentModel> appointmentsFromJson(dynamic str) =>
    List<AppointmentModel>.from((str).map((x) => AppointmentModel.fromJson(x)));
class AppointmentModel {
  final String description;
  final String datetime;
  final int? status;
  final String? id;
  final String salon;

  AppointmentModel({
    required this.description,
    required this.datetime,
    this.status,
    this.id,
    required this.salon,
  });
  AppointmentModel.fromJson(Map<String, dynamic> json)
      : description = json['description'],
        datetime = json['date'],
        status = json['status'],
        id = json['id'],
        salon = json['salon'];

  Map<String, dynamic> toJson() => {
        'description': description,
        'date': datetime,
        'salonId': salon,
  };
}