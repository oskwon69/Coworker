import 'dart:io';

import 'package:coworker/UI/worker_dropdown_widget.dart';
import 'package:coworker/model/worker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:coworker/UI/send_page.dart';
import 'package:coworker/model/user.dart';
import 'package:coworker/UI/login_page.dart';
import 'package:coworker/UI/show_model.dart';
import 'package:coworker/model/defect_server.dart';
import 'package:coworker/database/defect_from_server.dart';
import 'package:coworker/UI/worker_defect_card.dart';
import 'package:coworker/API/globals.dart' as globals;

import 'dropdown_widget.dart';


class WorkerPage extends StatefulWidget {
  const WorkerPage({Key? key, required this.worker}) : super(key: key);

  final WorkerInfo worker;

  @override
  State<WorkerPage> createState() => _WorkerPageState();
}

class _WorkerPageState extends State<WorkerPage> {
  late WorkerInfo _worker;
  List<DefectEx> defectList = [];

  final GlobalKey<WorkerBuildingWidgetState> _buildingKey = GlobalKey<WorkerBuildingWidgetState>();
  final GlobalKey<WorkerHouseWidgetState> _houseKey = GlobalKey<WorkerHouseWidgetState>();
  final GlobalKey<WorkerWorkWidgetState> _workKey = GlobalKey<WorkerWorkWidgetState>();
  final GlobalKey<WorkerStatusWidgetState> _statusKey = GlobalKey<WorkerStatusWidgetState>();

  final DefectServer _databaseService = DefectServer();
  static final storage = FlutterSecureStorage();

  static const _pageSize = 20;
  final PagingController<int, DefectEx> _pagingController = PagingController(firstPageKey: 0);

  int _total=0;
  int _closed=0;
  int _site_code = 0;
  String _building_no = "동 전체";
  String _house_no = "호 전체";
  String _work_name = "";
  String _status = "미처리";

  Future<void> changeBuilding(String building) async {
    if( _building_no != building ) _house_no = '호 전체';
    _building_no = building;
    if( _building_no == '동 전체') _house_no = '호 전체';
    await _houseKey.currentState?.refreshList(_site_code, _building_no);
    setState(() {
      _pagingController.refresh();
    });
  }

  Future<void> changeHouse(String house) async {
    _house_no = house;
    setState(() {
      _pagingController.refresh();
    });
  }

  Future<void> changeWork(String work_name) async {
    print('changeWork:$work_name');
    _work_name = work_name;
    setState(() {
      _pagingController.refresh();
    });
  }

  Future<void> changeStatus(String status) async {
    _status = status;
    setState(() {
      _pagingController.refresh();
    });
  }

  refreshScreen() {
    setState(() {
      _pagingController.refresh();
    });
  }

  Future<int> _getDefectsCount() async {
    _total = await _databaseService.getTotalDefectsCountforWorker(_site_code, _building_no, _house_no, _work_name, '전체');
    _closed = await _databaseService.getTotalDefectsCountforWorker(_site_code, _building_no, _house_no, _work_name, '완료');
    if( _work_name == "")
      _work_name = await _databaseService.getWorkforWorker(_worker.worker_id!);

    return 0;
  }

  Future<void> setDropdown() async {
    await _buildingKey.currentState?.refreshList(_site_code);
    _buildingKey.currentState?.setList(_building_no);

    await _houseKey.currentState?.refreshList(_site_code, _building_no);
    _houseKey.currentState?.setList(_house_no);

    await _workKey.currentState?.refreshList();
    _workKey.currentState?.setList(_work_name);

    await _statusKey.currentState?.refreshList();
    _statusKey.currentState?.setList(_status);
  }

  @override
  void initState() {
    super.initState();

    _worker = widget.worker;
    _site_code = _worker.site_code!;
    _work_name = _worker.work_name!;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () => setDropdown());
    });

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      print('fetch - site_code:$_site_code, building_no:$_building_no, house_no:$_house_no, work_name:$_work_name, status:$_status');
      final newItems = await _databaseService.getAllDefectsforWorker(_site_code, _building_no, _house_no, _work_name, _status, pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context)  {
    var f = NumberFormat('###,###,###,###');
    return Scaffold(
      drawer: NavigationWorkerDrawer(worker: _worker),
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: -5,
        title: ListTile(
          title: Text('${_worker.worker_name} 님', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          subtitle: Text('${_worker.site_name}에 오신걸 환영합니다!', style: TextStyle(fontSize: 13, color: Colors.grey)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Gap(5),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WorkerBuildingWidget(key: _buildingKey, function: changeBuilding),
                  Gap(10),
                  WorkerHouseWidget(key: _houseKey, function: changeHouse),
                ],
            ),
            Gap(5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WorkerWorkWidget(key: _workKey, worker_id: _worker.worker_id!, work_name: _work_name, function: changeWork),
                Gap(10),
                WorkerStatusWidget(key: _statusKey, function: changeStatus),
              ],
            ),
            Gap(5),
            Container(
              margin: EdgeInsets.symmetric(vertical: 1),
              padding: EdgeInsets.all(5),
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(7),
              ),
              child: FutureBuilder(
                  future: _getDefectsCount(),
                  builder: (context, snapshot) {
                    if ( snapshot.hasData ) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Text('전체'),
                                Gap(5),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.all(Radius.circular(7))),
                                  width: 50,
                                  child: Text(f.format(_total), style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('완료'),
                                Gap(5),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.all(Radius.circular(7))),
                                  width: 50,
                                  child: Text(f.format(_closed), style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('미처리'),
                                Gap(5),
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(7))),
                                  width: 50,
                                  child: Text(f.format(_total-_closed), style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ]
                      );
                    }
                    return Center();
                    //return Center(child: CircularProgressIndicator());
                  }
              ),
            ),
            Gap(5),
            Expanded(
              child: PagedListView<int, DefectEx>(
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<DefectEx>(
                  itemBuilder: (context, item, index) => WorkerDefectCardWidget(index: index, defect: item, worker: _worker, function: refreshScreen),
                  firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('Error loading data!'),),
                  noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No items found.'),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationWorkerDrawer extends StatelessWidget {
  const NavigationWorkerDrawer({Key? key, required this.worker}) : super(key: key);
  final WorkerInfo worker;

  @override
  Widget build(BuildContext context)  => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    ),
  );

  Widget buildHeader(BuildContext context) => Container(
    color: Colors.blue.shade700,
    padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top,),
    child: Column(
      children: [
        CircleAvatar(
          radius: 40,
          child: Icon(CupertinoIcons.house),
        ),
        Gap(10),
        Text('${worker.worker_name!} 님', style: TextStyle(fontSize: 25, color: Colors.white),),
        Text('${worker.site_name!}', style: TextStyle(fontSize: 16, color: Colors.white),),
        Gap(10),
      ],
    ),
  );

  Widget buildMenuItems(BuildContext context) => Container(
      padding: EdgeInsets.all(4),
      child : Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('로그아웃'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('로그아웃 하시겠습니까?', style: TextStyle(fontSize: 15)),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text("취소", style: TextStyle(fontSize: 15))
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                          },
                          child: Text("로그아웃", style: TextStyle(fontSize: 15))
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      )
  );
}