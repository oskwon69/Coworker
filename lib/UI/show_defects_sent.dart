import 'package:coworker/UI/show_defect_card.dart';
import 'package:coworker/database/defect_from_server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:coworker/model/user.dart';
import 'package:coworker/model/defect.dart';
import 'package:coworker/database/defect_from_server.dart';
import '../model/defect_server.dart';
import 'card_defect_widget.dart';

class ShowDefectsSent extends StatefulWidget {
  const ShowDefectsSent({Key? key, required this.user}) : super(key: key);

  final UserInfo user;

  @override
  State<ShowDefectsSent> createState() => _ShowDefectsSentState();
}

class _ShowDefectsSentState extends State<ShowDefectsSent> {
  late UserInfo _user;
  List<DefectEx> defectList = [];

  final DefectServer _databaseService = DefectServer();

  Future<List<DefectEx>> _getDefects() async {
    try {
      final defects = await _databaseService.getAllDefects(_user.site_code!, _user.building_no!, _user.house_no!);
      //final defects = await _databaseService.getAllDefects(1, '101', '101');
      if (defectList.isNotEmpty) {
        defectList.clear();
      }
      defectList.addAll(defects);

    } catch(e) {
      print(e.toString());
    }
    return defectList;
  }

  @override
  void initState() {
    super.initState();

    _user = widget.user;
  }

  @override
  Widget build(BuildContext context)  {
    String _houseName = '';
    if( _user.site_name!.length>20)  {
      _houseName = '${_user.site_name!.substring(0,20)} ${_user.building_no}동 ${_user.house_no}호';
    }
    else  {
      _houseName = '${_user.site_name} ${_user.building_no}동 ${_user.house_no}호';
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: -5,
        title: ListTile(
          title: Text('하자 접수 내역', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          subtitle: Text(_houseName, style: TextStyle(fontSize: 13, color: Colors.black)),
        ),
        actions: [
        ],
      ),
      body: FutureBuilder(
          future: _getDefects(),
          builder: (BuildContext context, AsyncSnapshot<List<DefectEx>> snapshot) {
            if( snapshot.hasData )  {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Gap(5),
                      ListView.builder(
                          itemCount: defectList.length,
                          shrinkWrap: true,
                          primary: false,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return DefectCardWidget(index: index, defect: defectList[index]);
                          }
                      ),
                    ],
                  ),
                ),
              );
            }
            else {
              return Center(child: CircularProgressIndicator());
            }
          }
      ),
    );
  }
}