import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../database/env_database.dart';
import '../model/env.dart';

class SortSelect extends StatefulWidget {
  const SortSelect({Key? key, required this.site_code, required this.function}) : super(key: key);

  final int site_code;
  final Function function;

  @override
  State<SortSelect> createState() => _SortSelectState();
}

class _SortSelectState extends State<SortSelect> {
  int _selectedItem = 999;
  List<Sort> SortList = [];

  Future<List<Sort>> getSorts() async {
    final EnvDatabase _envdatabase = EnvDatabase();

    final sorts = await _envdatabase.getAllSort(widget.site_code);
    if ( SortList.isNotEmpty ) {  SortList.clear();  }
    SortList.addAll(sorts);

    return SortList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSorts(),
        builder: (BuildContext context, AsyncSnapshot<List<Sort>> snapshot) {
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
                        '하자유형 선택',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Divider(thickness: 1.2, color: Colors.grey.shade200,),
                    Gap(12),
                    Text('발생한 하자유형을 선택해 주세요.'),
                    Gap(10),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: GridView.builder(
                            itemCount: SortList.length,
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
                                  widget.function(SortList[_selectedItem].sort_name);
                                  Navigator.pop(context);
                                },
                                child: Text(SortList[index].sort_name),
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
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade800,
                              side: BorderSide(color: Colors.blue.shade800),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.symmetric(vertical: 3),
                            ),
                            onPressed: () {
                              //widget.function(SortList[_selectedItem].sort_name);
                              Navigator.pop(context);
                            },
                            child: Text('닫기'),
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