import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/appointment_card.dart';
import 'package:mobile/services/appointment_service.dart';
import 'package:mobile/model/appointment_model.dart';
import 'package:mobile/pages/loading.dart';
import 'package:mobile/services/salon_service.dart';

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = <Tab>[
    Tab(text: 'Lịch hẹn'),
    Tab(text: 'Lịch sử'),
  ];
  List<AppointmentModel> appointmentsCurrent = [];
  List<AppointmentModel> appointmentsHistory = [];
  late final TabController _tabController;
  String salonId = '';
  Set<String> permission = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _tabController = TabController(length: tabs.length, vsync: this);
    Future.delayed(Duration.zero, () {
      isSalon();
      getPermission();
    });
    _tabController.addListener(() {
      // Check if the 'Lịch hẹn' tab is selected
      if (_tabController.index == 0) {
        // Call setState to rebuild the widget
        getAllAppointments();
      }
    });
  }

  void getPermission() async {
    var data = await SalonsService.getPermission();
    setState(() {
      permission = data;
    });
  }

  Future<void> isSalon() async {
    String isSalon = await SalonsService.isSalon();
    setState(() {
      salonId = isSalon;
    });
  }

  Future<void> getAllAppointments() async {
    try {
      List<AppointmentModel> appointmentAPI;
      if (salonId == '') {
        appointmentAPI = await AppointmentService.getAll();
      } else if (permission.contains("OWNER") || permission.contains("R_APM")) {
        appointmentAPI =
            await AppointmentService.getAllSalonAppointments(salonId);
      } else {
        appointmentAPI = [];
      }
      //print(appointmentAPI[0].datetime);
      if (appointmentAPI.isEmpty) {
        return;
      }
      appointmentsCurrent = [];
      appointmentsHistory = [];
      for (var appointment in appointmentAPI) {
        int daysDifference =
            appointment.datetime.difference(DateTime.now()).inDays;
        appointment.dayDiff = daysDifference + 1;
        if (appointment.dayDiff >= 0) {
          appointmentsCurrent.add(appointment);
        } else {
          appointmentsHistory.add(appointment);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TabBar(
            tabs: tabs,
            controller: _tabController,
          ),
          Expanded(
            child: FutureBuilder(
              future: getAllAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Loading();
                } else {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      appointmentsCurrent.isEmpty
                          ? Center(
                              child: Text('Bạn không có cuộc hẹn nào',
                                  style: TextStyle(fontSize: 20)),
                            )
                          : ListView.builder(
                              itemCount: appointmentsCurrent.length,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: 1),
                              itemBuilder: (context, index) {
                                return AppointmentCard(
                                    appointment: appointmentsCurrent[index],
                                    isSalon: salonId);
                              }),
                      appointmentsHistory.isEmpty
                          ? Center(
                              child: Text('Bạn không có cuộc hẹn nào',
                                  style: TextStyle(fontSize: 20)),
                            )
                          : ListView.builder(
                              itemCount: appointmentsHistory.length,
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.only(top: 1),
                              itemBuilder: (context, index) {
                                return AppointmentCard(
                                    appointment: appointmentsHistory[index],
                                    isSalon: salonId);
                              },
                            ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
