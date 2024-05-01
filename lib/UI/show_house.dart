import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';

import '../database/env_database.dart';
import 'package:coworker/model/env.dart';


class HouseSelect extends StatefulWidget {
  const HouseSelect({Key? key, required this.function}) : super(key: key);

  final Function function;

  @override
  State<HouseSelect> createState() => _HouseSelectState();
}

class _HouseSelectState extends State<HouseSelect> {
  int _selectedItem = 99;
  static final storage = FlutterSecureStorage();
  List<House> houseList = [];

  Future<List<House>> getHouses() async {
    final EnvDatabase _envdatabase = EnvDatabase();

    final houses = await _envdatabase.getAllHouse();
    if ( houseList.isNotEmpty ) {  houseList.clear();  }
    houseList.addAll(houses);

    return houseList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getHouses(),
        builder: (BuildContext context, AsyncSnapshot<List<House>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(30),
              height: MediaQuery.of(context).size.height*0.60,
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
                        '동호수 선택',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    Divider(thickness: 1.2, color: Colors.grey.shade200,),
                    Gap(12),
                    Text('원하신는 동호수를 선택하세요.'),
                    Gap(20),
                    SizedBox(
                        height: MediaQuery.of(context).size.height*0.30,
                        child: GridView.builder(
                            itemCount: houseList.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              childAspectRatio: 7,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
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
                                child: Text('${houseList[index].site_name} ${houseList[index].building_no}동 ${houseList[index].house_no}호'),
                              );
                              //return Text('${widget.houseList[index]['site_name']} ${widget.houseList[index]['building_no']}동 ${widget.houseList[index]['house_no']}호');
                            }
                        )
                    ),
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
                            onPressed: () async {
                              if( _selectedItem == 99 ) {
                                Fluttertoast.showToast(msg: '동호수를 선택해 주세요.');
                                return;
                              }

                              await storage.write(
                                  key: "selectedHouse",
                                  value: "site_code," + houseList[_selectedItem].site_code.toString() + "," +
                                         "site_name," + houseList[_selectedItem].site_name + "," +
                                         "building_no," + houseList[_selectedItem].building_no + "," +
                                         "house_no," + houseList[_selectedItem].house_no + ","
                                         "type," + houseList[_selectedItem].type
                              );

                              Navigator.pop(context);
                              widget.function(houseList[_selectedItem].site_code, houseList[_selectedItem].site_name, houseList[_selectedItem].building_no, houseList[_selectedItem].house_no, houseList[_selectedItem].type);
                            },
                            child: Text('선택'),
                          ),
                        )
                      ],
                    ),
                  ]
              ),
            );
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        }
    );
  }
}