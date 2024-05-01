import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../database/env_database.dart';
import '../model/env.dart';

class AreaSelect extends StatefulWidget {
  const AreaSelect({Key? key, required this.site_code, required this.function}) : super(key: key);

  final int site_code;
  final Function function;

  @override
  State<AreaSelect> createState() => _AreaSelectState();
}

class _AreaSelectState extends State<AreaSelect> {
  int _selectedItem = 999;
  List<Area> areaList = [];

  Future<List<Area>> getAreas() async {
    final EnvDatabase _envdatabase = EnvDatabase();

    final areas = await _envdatabase.getAllArea(widget.site_code);
    if ( areaList.isNotEmpty ) {  areaList.clear();  }
    areaList.addAll(areas);

    return areaList;
  }

  @override
  Widget build(BuildContext context)  {
    return FutureBuilder(
      future: getAreas(),
      builder: (BuildContext context, AsyncSnapshot<List<Area>> snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(30),
            height: MediaQuery.of(context).size.height*0.50,
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
                      '위치 선택',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Divider(thickness: 1.2, color: Colors.grey.shade200,),
                  Gap(12),
                  Text('하자가 발생한 위치를 선택해 주세요.'),
                  Gap(20),
                  SizedBox(
                      height: MediaQuery.of(context).size.height*0.20,
                      child: GridView.builder(
                          itemCount: areaList.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                          ),
                          itemBuilder: (BuildContext context, int index)  {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedItem == index ? Colors.orangeAccent : Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(vertical: 3),
                              ),

                              onPressed: () {
                                setState(() {
                                  _selectedItem = index;
                                });
                              },
                              child: Text(areaList[index].area_name),
                            );
                            return Text(areaList[index].area_name);
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(vertical: 3),
                          ),
                          onPressed: () {
                            widget.function(areaList[_selectedItem].area_name);
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