import 'package:coworker/model/env.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_style.dart';

class WorkerBuildingWidget extends StatefulWidget {
  const WorkerBuildingWidget({Key? key, required this.function }) : super(key: key);
  final Function function;

  @override
  State<WorkerBuildingWidget> createState() => WorkerBuildingWidgetState();
}

class WorkerBuildingWidgetState extends State<WorkerBuildingWidget> {
  final supabase = Supabase.instance.client;
  late String _building_no;
  List<dynamic> buildingList = [{'site_code': 0, 'building_no': '동 전체'}];

  Future<void> _getBuildings(int site_code) async {
    buildingList.clear();
    buildingList.add({'site_code': site_code, 'building_no': '동 전체'});
    var buildings = await supabase.from('building').select().eq('site_code', site_code);
    if (buildings.isNotEmpty) {
      buildingList.addAll(buildings.toList());
    }
  }

  Future<void> refreshList(int site)  async {
    _building_no = '동 전체';
    await _getBuildings(site);
    setState(() {});
  }

  void setList(String building)  {
    _building_no = building;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _building_no = '동 전체';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey.shade500, width: 1.0)),
                height: 40,
                child: DropdownButton(
                  value: _building_no,
                  items: buildingList.map( (item) => DropdownMenuItem(value: item['building_no'], child: Text(item['building_no'], style: TextStyle(fontSize: 15)))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _building_no = value.toString();
                      widget.function(_building_no);
                    });
                  },
                  isExpanded: true,
                  underline: Container(),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.grey.shade400,
                )
            ),
          ]
      ),
    );
  }
}

class WorkerHouseWidget extends StatefulWidget {
  const WorkerHouseWidget({Key? key, required this.function }) : super(key: key);
  final Function function;

  @override
  State<WorkerHouseWidget> createState() => WorkerHouseWidgetState();
}

class WorkerHouseWidgetState extends State<WorkerHouseWidget> {
  final supabase = Supabase.instance.client;
  late String _house_no;
  List<dynamic> houseList = [{'site_code': 0, 'building_no': '동 전체', 'house_no': '호 전체'}];
  bool _isProcessing = false;

  Future<void> _getHouses(int site_code, String building_no) async {
    houseList.clear();
    houseList.add({'site_code': site_code, 'building_no': '동 전체', 'house_no': '호 전체'});
    var houses = await supabase.from('house').select().match({'site_code':site_code, 'building_no':building_no});
    if (houses.isNotEmpty) {
      houseList.addAll(houses.toList());
    }
  }

  Future<void> refreshList(int site, String building)  async {
    _house_no = '호 전체';
    await _getHouses(site, building);
    setState(() {});
  }

  void setList(String house)  {
    _house_no = house;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _house_no = '호 전체';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey.shade500, width: 1.0)),
                height: 40,
                child: DropdownButton(
                  value: _house_no,
                  items: houseList.map( (item) => DropdownMenuItem(value: item['house_no'], child: Text(item['house_no'], style: TextStyle(fontSize: 15)))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _house_no = value.toString();
                      widget.function(_house_no);
                    });
                  },
                  isExpanded: true,
                  underline: Container(),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.grey.shade400,
                )
            ),
          ]
      ),
    );
  }
}

class WorkerWorkWidget extends StatefulWidget {
  const WorkerWorkWidget({Key? key, required this.worker_id, required this.work_name, required this.function }) : super(key: key);
  final int worker_id;
  final String work_name;
  final Function function;

  @override
  State<WorkerWorkWidget> createState() => WorkerWorkWidgetState();
}

class WorkerWorkWidgetState extends State<WorkerWorkWidget> {
  final supabase = Supabase.instance.client;
  late String _work_name;
  late int _worker_id;
  List<dynamic> workList = [];

  Future<void> _getWorks(int worker_id) async {
    workList.clear();
    var works = await supabase.from('worker_works').select().match({'worker_id':worker_id});
    if (works.isNotEmpty) {
      workList.addAll(works.toList());
    }
  }

  Future<void> refreshList()  async {
    await _getWorks(_worker_id);
    setState(() {});
  }

  void setList(String work_name)  {
    int index = workList.indexWhere((element) => element['work_name'] == work_name);
    if( index >= 0 ) {
      _work_name = work_name;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _worker_id = widget.worker_id;
    _work_name = widget.work_name;
  }

  @override
  Widget build(BuildContext context) {
    print(workList);
    return Flexible(
      flex: 2,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey.shade500, width: 1.0)),
                height: 40,
                child: DropdownButton(
                  value: _work_name,
                  items: workList.length>0 ? workList.map( (item) => DropdownMenuItem(value: item['work_name'], child: Text(item['work_name'], style: TextStyle(fontSize: 15)))).toList(): null,
                  onChanged: (value) {
                    setState(() {
                      _work_name = value.toString();
                      widget.function(_work_name);
                    });
                  },
                  isExpanded: true,
                  underline: Container(),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.grey.shade400,
                )
            ),
          ]
      ),
    );
  }
}

class WorkerStatusWidget extends StatefulWidget {
  const WorkerStatusWidget({Key? key, required this.function }) : super(key: key);
  final Function function;

  @override
  State<WorkerStatusWidget> createState() => WorkerStatusWidgetState();
}

class WorkerStatusWidgetState extends State<WorkerStatusWidget> {
  List<dynamic> statusList = [];
  String _status = '미처리';

  Future<void> _getStatus() async {
    statusList.clear();
    statusList.add({'status': '전체'});
    statusList.add({'status': '미처리'});
    statusList.add({'status': '완료'});
  }

  Future<void> refreshList()  async {
    await _getStatus();
    setState(() {});
  }

  void setList(String status)  {
    _status = status;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8),border: Border.all(color: Colors.grey.shade500, width: 1.0)),
                height: 40,
                child: DropdownButton(
                  value: _status,
                  items: statusList.length>0 ? statusList.map( (item) => DropdownMenuItem(value: item['status'], child: Text(item['status'], style: TextStyle(fontSize: 15)))).toList(): null,
                  onChanged: (value) {
                    setState(() {
                      _status = value.toString();
                      widget.function(_status);
                    });
                  },
                  isExpanded: true,
                  underline: Container(),
                  dropdownColor: Colors.white,
                  iconEnabledColor: Colors.grey.shade400,
                )
            ),
          ]
      ),
    );
  }
}