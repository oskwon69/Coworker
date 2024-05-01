import 'package:coworker/UI/show_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../database/env_database.dart';
import '../model/env.dart';

class SpaceSelect extends StatefulWidget {
  const SpaceSelect({Key? key, required this.site_code, required this.function}) : super(key: key);

  final int site_code;
  final Function function;

  @override
  State<SpaceSelect> createState() => _SpaceSelectState();
}

class _SpaceSelectState extends State<SpaceSelect> {
  int _selectedItem = 999;
  List<Space> spaceList = [];

  Future<List<Space>> getSpaces() async {
    final EnvDatabase _envdatabase = EnvDatabase();

    final spaces = await _envdatabase.getAllSpace(widget.site_code);
    if ( spaceList.isNotEmpty ) {  spaceList.clear();  }
    spaceList.addAll(spaces);

    return spaceList;
  }

  @override
  Widget build(BuildContext context)  {
    return FutureBuilder(
      future: getSpaces(),
      builder: (BuildContext context, AsyncSnapshot<List<Space>> snapshot) {
        if (snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(30),
            height: MediaQuery.of(context).size.height*0.70,
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
                      '실명 선택',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  Divider(thickness: 1.2, color: Colors.grey.shade200,),
                  Gap(10),
                  Row(
                    children: [
                      Text('실명은 평면도를 참고해 주세요.'),
                      Gap(20),
                      Container(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            maximumSize: Size(120, 40),
                            backgroundColor: Color(0xFFD5E8FA),
                            foregroundColor: Colors.blue.shade800,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LayoutWidget()));
                          },
                          child: Text('평면도'),
                          ),
                      )
                    ],
                  ),
                  Gap(10),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.35,
                    child: GridView.builder(
                      itemCount: spaceList.length,
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
                          child: Text(spaceList[index].space_name),
                        );
                        return Text(spaceList[index].space_name);
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
                              widget.function(spaceList[_selectedItem].space_name);
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
        }
        else {
          return Center(child: CircularProgressIndicator());
        }
      }
    );
  }
}