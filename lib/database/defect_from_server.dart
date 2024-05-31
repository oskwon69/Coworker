import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/defect_server.dart';

class DefectServer {
  final supabase = Supabase.instance.client;

  Future<List<DefectEx>> getAllDefects(int site_code, String building_no,
      String house_no) async {
    final List<Map<String, dynamic>> data = await supabase.from('defects').select().match({
      'site_code': site_code,
      'building_no': building_no,
      'house_no': house_no,
      'deleted': 0
    }).order('id');

    return List.generate(data.length, (index) => DefectEx.fromMap(data[index]));
  }
}
