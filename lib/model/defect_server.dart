import 'dart:convert';

class DefectEx {
  final int? id;
  int? local_id;
  String uid;
  String did;
  int site_code;
  String building_no;
  String house_no;
  String reg_name;
  String reg_phone;
  String space_name;
  String area_name;
  String work_name;
  String sort_name;
  String claim;
  String? remarks;
  String? note;
  String? pic1;
  String? pic2;
  String gentime;
  String sent_date;
  String? close_date;
  int? completed;
  int deleted;
  int work_status;
  String? work_pic;
  String? server_work_pic;
  String? work_date;
  String? worker_name;
  String? worker_comment;
  String? owner_sign;

  DefectEx({
    this.id,
    required this.local_id,
    required this.uid,
    required this.did,
    required this.site_code,
    required this.building_no,
    required this.house_no,
    required this.reg_name,
    required this.reg_phone,
    required this.space_name,
    required this.area_name,
    required this.work_name,
    required this.sort_name,
    required this.claim,
    this.remarks,
    this.note,
    this.pic1,
    this.pic2,
    required this.gentime,
    required this.sent_date,
    this.close_date,
    this.completed,
    required this.deleted,
    required this.work_status,
    this.work_pic,
    this.server_work_pic,
    this.work_date,
    this.worker_name,
    this.worker_comment,
    this.owner_sign
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'local_id' : local_id,
      'uid' : uid,
      'did' : did,
      'site_code' : site_code,
      'building_no' : building_no,
      'house_no' : house_no,
      'reg_name' : reg_name,
      'reg_phone' : reg_phone,
      'space_name' : space_name,
      'area_name' : area_name,
      'work_name' : work_name,
      'sort_name' : sort_name,
      'claim' : claim,
      'remarks' : remarks,
      'note' : note,
      'pic1' : pic1,
      'pic2' : pic2,
      'gentime' : gentime,
      'sent_date' : sent_date,
      'close_date' : close_date,
      'completed' : completed,
      'deleted' : deleted,
      'work_status' : work_status,
      'work_pic' : work_pic,
      'server_work_pic' : server_work_pic,
      'work_date' : work_date,
      'worker_name' : worker_name,
      'worker_comment' : worker_comment,
      'owner_sign' : owner_sign
    };
  }

  factory DefectEx.fromMap(Map<String, dynamic> map)  {
    return DefectEx(
      id: map['id']?.toInt() ?? 0,
      local_id: map['local_id'] ?? '',
      uid: map['uid'] ?? '',
      did: map['did'] ?? '',
      site_code: map['site_code']?.toInt() ?? '',
      building_no: map['building_no'] ?? '',
      house_no: map['house_no'] ?? '',
      reg_name: map['reg_name'] ?? '',
      reg_phone: map['reg_phone'] ?? '',
      space_name: map['space_name'] ?? '',
      area_name: map['area_name'] ?? '',
      work_name: map['work_name'] ?? '',
      sort_name: map['sort_name'] ?? '',
      claim: map['claim'] ?? '',
      remarks: map['remarks'] ?? '',
      note: map['note'] ?? '',
      pic1: map['pic1'] ?? '',
      pic2: map['pic2'] ?? '',
      gentime: map['gentime'] ?? '',
      sent_date: map['sent_date'] ?? '',
      close_date: map['close_date'] ?? '',
      completed: map['completed']?.toInt() ?? 0,
      deleted: map['deleted'].toInt() ?? 0,
      work_status: map['work_status']?.toInt() ?? 0,
      work_pic: map['work_pic'] ?? '',
      server_work_pic: map['server_work_pic'] ?? '',
      work_date: map['work_date'] ?? '',
      worker_name: map['worker_name'] ?? '',
      worker_comment: map['worker_comment'] ?? '',
      owner_sign: map['owner_sign'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DefectEx.fromJson(String source) => DefectEx.fromMap(json.decode(source));

  @override
  String toString() {
    return 'DefectEx(id: $id, local_id:$local_id, uid: $uid, did: $did, site: $site_code, building: $building_no, house: $house_no, reg_name: $reg_name, reg_phone: $reg_phone, space: $space_name, area: $area_name, work: $work_name, sort: $sort_name, claim: $claim, pic1: $pic1, pic2: $pic2, gentime: $gentime, sent: $sent_date, close: $close_date, completed: $completed, deleted: $deleted, work_status: $work_status, work_pic: $work_pic, server_work_pic: $server_work_pic, work_date: $work_date, worker_name: $worker_name, worker_comment: $worker_comment, owner_sign: $owner_sign)';
  }
}