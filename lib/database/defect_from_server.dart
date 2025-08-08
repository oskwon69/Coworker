import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/defect_server.dart';

class DefectServer {
  final supabase = Supabase.instance.client;

  Future<List<DefectEx>> getAllDefects(int site_code, String building_no, String house_no, int pagekey, int pagesize) async {
    final List<Map<String, dynamic>> data = await supabase.from('defects').select().match({
      'site_code': site_code,
      'building_no': building_no,
      'house_no': house_no,
      'deleted': 0
    }).order('id').range(pagekey, pagekey+pagesize-1);

    //print('pagekey: $pagekey, pagesize: $pagesize length:${data.length}');

    if( data.length < pagesize )  {
      return List.generate(data.length, (index) => DefectEx.fromMap(data[index]));
    } else {
      return List.generate(pagesize, (index) => DefectEx.fromMap(data[index]));
    }
  }

  Future<int> getTotalDefectsCount(int site_code, String building_no, String house_no) async {
    final result = await supabase.from('defects').count().match({
      'site_code': site_code,
      'building_no': building_no,
      'house_no': house_no,
      'deleted': 0});

    return result;
  }

  Future<List<DefectEx>> getAllDefectsforWorker(int site_code, String building_no, String house_no, String work, String status, int pagekey, int pagesize) async {
    var _query = {
      'site_code' : site_code.toString(),
      'work_name' : work,
      'deleted' : 0
    };
    if( building_no != "동 전체" ) _query['building_no'] = building_no;
    if( house_no != "호 전체" ) _query['house_no'] = house_no;
    if( status != "전체" ) _query['work_status'] = status == "완료" ? 1:0;

    final List<Map<String, dynamic>> data = await supabase.from('defects_view').select().match(_query).range(pagekey, pagekey+pagesize-1);

    if( data.length < pagesize )  {
      return List.generate(data.length, (index) => DefectEx.fromMap(data[index]));
    } else {
      return List.generate(pagesize, (index) => DefectEx.fromMap(data[index]));
    }
  }

  Future<int> getTotalDefectsCountforWorker(int site_code, String building_no, String house_no, String work, String status) async {
    var _query = {
      'site_code': site_code.toString(),
      'work_name': work,
      'deleted': 0
    };
    if( building_no != "동 전체" ) _query['building_no'] = building_no;
    if( house_no != "호 전체" ) _query['house_no'] = house_no;
    if( status != "전체" ) _query['work_status'] = status == "완료" ? 1:0;

    final result = await supabase.from('defects').count().match(_query);

    return result;
  }

  Future<String> getWorkforWorker(int worker_id) async {
    final List<Map<String, dynamic>> data = await supabase.from('worker_works').select().match({'worker_id': worker_id});
    if (data.length > 0)
      return data[0]['work_name'].toString();
    else
      return "";
  }
}
