import 'package:coworker/model/env.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_style.dart';

class SiteWidget extends StatefulWidget {
  const SiteWidget({Key? key, required this.function }) : super(key: key);
  final Function function;

  @override
  State<SiteWidget> createState() => SiteWidgetState();
}

class SiteWidgetState extends State<SiteWidget> {
  final supabase = Supabase.instance.client;
  List<dynamic> siteList = [];
  late int _site_code;

  Future<void> _getSites() async {
    siteList.clear();
    siteList.add({'site_code': 999, 'site_name': '단지 선택'});
    var sites = await supabase.from('site').select().match({'status' : 1}).order('site_name');
    if (sites.isNotEmpty) {
      siteList.addAll(sites.toList());
    }
  }

  Future<void> refreshList()  async {
    await _getSites();
    setState(() {});
  }

  void setList(int site) {
    int index = siteList.indexWhere((element) => element['site_code'] == site);
    if( index >= 0 ) {
      _site_code = site;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _site_code = 999;

    _getSites().then( (_) {setState(() {}); });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('단지', style: AppStyle.headingOne,),
            Gap(6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8),),
              child: DropdownButton(
                value: _site_code,
                items: siteList.map( (item) => DropdownMenuItem(value: item['site_code'], child: Text(item['site_name']))).toList(),
                onChanged: (value) {
                  setState(() {
                    _site_code = int.parse(value.toString());
                    var item = siteList.where( (item) => item['site_code'] == _site_code);
                    widget.function(_site_code, item.first['site_name']);
                  });
                },
                isExpanded: true,
                underline: Container(),
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.grey.shade400,
              )
            ),
          ],
      ),
    );
  }
}

class BuildingWidget extends StatefulWidget {
  const BuildingWidget({Key? key, required this.function }) : super(key: key);
  final Function function;

  @override
  State<BuildingWidget> createState() => BuildingWidgetState();
}

class BuildingWidgetState extends State<BuildingWidget> {
  final supabase = Supabase.instance.client;
  late String _building_no;
  List<dynamic> buildingList = [{'site_code': 0, 'building_no': '동 선택'}];

  Future<void> _getBuildings(int site_code) async {
    buildingList.clear();
    buildingList.add({'site_code': site_code, 'building_no': '동 선택'});
    var buildings = await supabase.from('building').select().eq('site_code', site_code);
    if (buildings.isNotEmpty) {
      buildingList.addAll(buildings.toList());
    }
  }

  Future<void> refreshList(int site)  async {
    _building_no = '동 선택';
    await _getBuildings(site);
    setState(() {});
  }

  void setList(String building)  {
    bool hasItem = buildingList.any((map) => map['building_no'] == building);
    if( hasItem )
      _building_no = building;
    else
      _building_no = "동 선택";
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _building_no = '동 선택';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('동', style: AppStyle.headingOne,),
            Gap(6),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8),),
                child: DropdownButton(
                  value: _building_no,
                  items: buildingList.map( (item) => DropdownMenuItem(value: item['building_no'], child: Text(item['building_no']))).toList(),
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

class HouseWidget extends StatefulWidget {
  const HouseWidget({Key? key, required this.function }) : super(key: key);
  final Function function;

  @override
  State<HouseWidget> createState() => HouseWidgetState();
}

class HouseWidgetState extends State<HouseWidget> {
  final supabase = Supabase.instance.client;
  late String _house_no;
  List<dynamic> houseList = [{'site_code': 0, 'building_no': '동 선택', 'house_no': '호 선택'}];
  bool _isProcessing = false;

  Future<void> _getHouses(int site_code, String building_no) async {
    houseList.clear();
    houseList.add({'site_code': site_code, 'building_no': '동 선택', 'house_no': '호 선택'});
    var houses = await supabase.from('house').select().match({'site_code':site_code, 'building_no':building_no});
    if (houses.isNotEmpty) {
      houseList.addAll(houses.toList());
    }
  }

  Future<void> refreshList(int site, String building)  async {
    _house_no = '호 선택';
    await _getHouses(site, building);
    setState(() {
    });
  }

  void setList(String house)  {
    bool hasItem = houseList.any((map) => map['house_no'] == house);
    if( hasItem )
      _house_no = house;
    else
      _house_no = "호 선택";
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _house_no = '호 선택';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('호', style: AppStyle.headingOne,),
            Gap(6),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8),),
                child: DropdownButton(
                  value: _house_no,
                  items: houseList.map( (item) => DropdownMenuItem(value: item['house_no'], child: Text(item['house_no']))).toList(),
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