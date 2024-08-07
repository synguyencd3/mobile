import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/model/CarInvoice_response.dart';
import 'package:mobile/model/process_model.dart';
import 'package:mobile/model/stage_model.dart';
import 'package:mobile/model/transaction_model.dart';

import '../../model/commission_detail_model.dart';
import '../../services/stage_service.dart';
import '../../services/transaction_service.dart';
import 'package:mobile/widgets/dropdown.dart';

class TransactionDetail extends StatefulWidget {
  const TransactionDetail({super.key});

  @override
  State<TransactionDetail> createState() => _TransactionDetailState();
}

class _TransactionDetailState extends State<TransactionDetail> {
  TransactionModel transaction = TransactionModel();
  StageModel stage = StageModel();
  List<bool> checkboxValues = [];
  bool showButton = true;
  process processData = process();
  late final TextEditingController _commission = TextEditingController();
  ValueNotifier<String> _selectedRatingValue = ValueNotifier('0');
  List<String> _values = [
    '10',
    '20',
    '30',
    '40',
    '50',
    '60',
    '70',
    '80',
    '90',
    '100'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getTransaction().then((value) => getStageDetail());
      setState(() {});
    });
  }

  @override
  void dispose() {
    _commission.dispose();
    super.dispose();
  }

  Future<void> getTransaction() async {
    TransactionModel transactionArgument =
        ModalRoute.of(context)!.settings.arguments as TransactionModel;
    transaction = transactionArgument;
  }
  Future<void> getProcessDetail() async {
    print(transaction.processData?.id);
    var processAPI = await TransactionService.getProcessDetail(
        transaction.processData?.id ?? '');
    processData = processAPI;
  }

  Future<void> getStageDetail() async {
    StageModel stageAPI =
        await StageService.getStageDetail(transaction.stage?.stage_id ?? '');
    //print(stageAPI.commissionDetails?.length);
    setState(() {
      stage = stageAPI;
      checkboxValues = stage.commissionDetails?.map((detail) {
            return transaction.checked?.contains(detail.commissionDetailId) ??
                false;
          }).toList() ??
          [];
    });
  }

  Future<void> getTransactionDetail() async {
    print(transaction.id);
    TransactionModel transactionAPI =
        await TransactionService.getTransactionDetail(transaction.id ?? '');
    setState(() {
      transaction = transactionAPI;
    });
  }

  Future<bool> updateCheckedTransaction() async {
    bool updated = await TransactionService.updateCheckedTransaction(
        transaction.id ?? '', transaction.checked ?? []);
    return updated;
  }

  Future<int> updateNextStage() async {
    if (_commission.text == '') {
      _commission.text = '0';
    }
    int updated = await TransactionService.updateNextStage(transaction.id ?? '',
        int.parse(_commission.text), int.parse(_selectedRatingValue.value));
    return updated;
  }

  bool areAllCheckboxesChecked() {
    return checkboxValues.every((bool value) => value);
  }

  bool checkStatus() {
    return transaction.status == 'success';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết giao dịch'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: (checkStatus() == false)
            ? Column(children: [
                Text(
                  transaction.processData?.name ?? '',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                Text(
                    'Trạng thái: ${transaction.status == 'pending' ? 'Chưa hoàn thành' : transaction.status == 'success' ? 'Đã hoàn thành' : 'Đã hủy'}'),
                Text('Hoa tiêu: ${transaction.userTransaction?.name ?? 'Bạn'}'),
                Text('Giai đoạn hiện tại: ${transaction.stage?.name ?? ' '}'),
                SingleChildScrollView(
                  child: Column(
                    children:
                        stage.commissionDetails?.asMap().entries.map((entry) {
                              int index = entry.key;
                              CommissionDetailModel detail = entry.value;
                              return CheckboxListTile(
                                title: Text(detail.name ?? ''),
                                value: checkboxValues[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkboxValues[index] = value ?? false;
                                    if (value == true) {
                                      transaction.checked
                                          ?.add(detail.commissionDetailId);
                                    } else {
                                      transaction.checked
                                          ?.remove(detail.commissionDetailId);
                                    }
                                    //print(transaction.checked);
                                  });
                                },
                              );
                            }).toList() ??
                            [],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (showButton && areAllCheckboxesChecked())
                        ? Container(
                            child: FilledButton(
                                onPressed: () async {
                                  bool response =
                                      await updateCheckedTransaction();
                                  int check = await updateNextStage();
                                  if (check == 1) {
                                    await getTransactionDetail()
                                        .then((value) => getStageDetail());
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            child: AlertDialog(
                                              title: Text('Đánh giá hoa tiêu'),
                                              content: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Đánh giá phần trăm hoàn thành'),
                                                  DropdownMenuExample(
                                                      valueNotifier:
                                                          _selectedRatingValue,
                                                      items: _values),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  TextField(
                                                    keyboardType:
                                                        TextInputType.number,
                                                    controller: _commission,
                                                    decoration: InputDecoration(
                                                      labelText: 'Hoa hồng',
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          // color: Color(0xFF6F61EF),
                                                          width: 2,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Hủy')),
                                                TextButton(
                                                    onPressed: () async {
                                                      int value =
                                                          await updateNextStage();
                                                      if (value == 1) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'Cập nhật thành công'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ));
                                                      } else if (value == 2) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'Giao dịch đã hoàn thành'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ));
                                                        setState(() {
                                                          showButton = false;
                                                        });
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              'Cập nhật thất bại'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ));
                                                      }

                                                      Navigator.pop(context);
                                                      setState(() {
                                                        transaction.status =
                                                            'success';
                                                      });
                                                    },
                                                    child: Text('Tiếp tục')),
                                              ],
                                            ),
                                          );
                                        });
                                  }
                                },
                                child: Text('Tiếp tục')))
                        : Container(),
                    SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        onPressed: () async {
                          updateCheckedTransaction().then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Cập nhật thành công'),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text('Cập nhật thất bại'),
                              ));
                            }
                          });
                        },
                        child: Text('Lưu')),
                  ],
                ),
              ])
            : FutureBuilder(
            future: getProcessDetail(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  Text(
                    'Giao dịch đã hoàn thành',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.green),
                  ),
                  Column(
                    children:
                    processData.stages!.asMap().entries.map((entry) {
                      int index = entry.key;
                      var stage = entry.value;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(stage.name ?? ''),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    transaction.ratingList?[index]=='-1' ? 'Chưa đánh giá':'Phần trăm hoàn thành: ${transaction.ratingList?[index] ?? 0}%'),
                                Text(
                                    'Hoa hồng: ${transaction.commissionList?[index] ?? 0}'),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              );
            }),
      ),
      // bottomNavigationBar: checkStatus() == false
      //     ? Padding(
      //         padding: const EdgeInsets.all(8.0),
      //         child: FloatingActionButton(
      //           onPressed: () {
      //           },
      //           child: Text('Đặt lịch hẹn'),
      //         ),
      //       )
      //     : null,
    );
  }
}
