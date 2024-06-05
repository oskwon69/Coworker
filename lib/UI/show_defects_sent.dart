import 'package:coworker/UI/show_defect_card.dart';
import 'package:coworker/database/defect_from_server.dart';
import 'package:coworker/model/defect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:coworker/model/user.dart';
import '../model/defect_server.dart';

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
  static const _pageSize = 20;
  int _total=0;

  final PagingController<int, DefectEx> _pagingController = PagingController(firstPageKey: 0);

/*
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
*/

  Future<void> _getDefectsCount() async {
    _total = await _databaseService.getTotalDefectsCount(_user.site_code!, _user.building_no!, _user.house_no!);
    setState(() {
    });
  }

  @override
  void initState() {
    _user = widget.user;
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _getDefectsCount();

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _databaseService.getAllDefects(_user.site_code!, _user.building_no!, _user.house_no!, pageKey, _pageSize);
      //final newItems = await _databaseService.getAllDefects(3, '207', '201', pageKey, _pageSize);
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
          title: Text('하자 접수 내역 ($_total건)', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
          subtitle: Text(_houseName, style: TextStyle(fontSize: 13, color: Colors.black)),
        ),
        actions: [
        ],
      ),
      body: PagedListView<int, DefectEx>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<DefectEx>(
          itemBuilder: (context, item, index) => DefectCardWidget(index: index, defect: item),
          firstPageErrorIndicatorBuilder: (context) => const Center(child: Text('Error loading data!'),),
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No items found.'),),
        ),
      ),
    );
  }
}