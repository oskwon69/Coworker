import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../database/env_database.dart';
import '../model/env.dart';

class WorkSelect extends StatefulWidget {
  const WorkSelect({Key? key, required this.site_code, required this.function}) : super(key: key);

  final int site_code;
  final Function function;

  @override
  State<WorkSelect> createState() => _WorkSelectState();
}

class _WorkSelectState extends State<WorkSelect> {
  int _selectedItem = 999;
  List<Work> workList = [];

  Future<List<Work>> getWorks() async {
    final EnvDatabase _envdatabase = EnvDatabase();

    final works = await _envdatabase.getAllWork(widget.site_code);
    if ( workList.isNotEmpty ) {  workList.clear();  }
    workList.addAll(works);

    return workList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getWorks(),
        builder: (BuildContext context, AsyncSnapshot<List<Work>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(30),
              height: MediaQuery.of(context).size.height * 0.70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        '부위(공종) 선택',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Divider(thickness: 1.2, color: Colors.grey.shade200,),
                    Gap(12),
                    Text('하자가 발생한 공사를 선택해 주세요.'),
                    Gap(10),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: GridView.builder(
                            itemCount: workList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.5,
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedItem == index ? Colors.orangeAccent : Colors.grey.shade200,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: EdgeInsets.symmetric(vertical: 3),
                                ),

                                onPressed: () {
                                  setState(() {
                                    _selectedItem = index;
                                  });
                                },
                                child: Text(workList[index].work_name),
                              );
                            }
                        )
                    ),
                    Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(vertical: 3),
                            ),
                            onPressed: () {
                              widget.function(workList[_selectedItem].work_name);
                              Navigator.pop(context);
                            },
                            child: Text('선택'),
                          ),
                        )
                      ],
                    ),
                  ]
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}