import 'dart:convert';

class Defect {
  final int? id;
  String uid;
  String did;
  int site;
  String building;
  String house;
  String reg_name;
  String reg_phone;
  String space;
  String area;
  String work;
  String sort;
  String claim;
  String pic1;
  String pic2;
  String gentime;
  String? sent;
  int synced;
  int? completed;
  int deleted;

  Defect({
    this.id,
    required this.uid,
    required this.did,
    required this.site,
    required this.building,
    required this.house,
    required this.reg_name,
    required this.reg_phone,
    required this.space,
    required this.area,
    required this.work,
    required this.sort,
    required this.claim,
    required this.pic1,
    required this.pic2,
    required this.gentime,
    this.sent,
    required this.synced,
    this.completed,
    required this.deleted
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'uid' : uid,
      'did' : did,
      'site' : site,
      'building' : building,
      'house' : house,
      'reg_name' : reg_name,
      'reg_phone' : reg_phone,
      'space' : space,
      'area' : area,
      'work' : work,
      'sort' : sort,
      'claim' : claim,
      'pic1' : pic1,
      'pic2' : pic2,
      'gentime' : gentime,
      'sent' : sent,
      'synced' : synced,
      'completed' : completed,
      'deleted' : deleted,
    };
  }

  factory Defect.fromMap(Map<String, dynamic> map)  {
    return Defect(
      id: map['id']?.toInt() ?? 0,
      uid: map['uid'] ?? '',
      did: map['did'] ?? '',
      site: map['site']?.toInt() ?? '',
      building: map['building'] ?? '',
      house: map['house'] ?? '',
      reg_name: map['reg_name'] ?? '',
      reg_phone: map['reg_phone'] ?? '',
      space: map['space'] ?? '',
      area: map['area'] ?? '',
      work: map['work'] ?? '',
      sort: map['sort'] ?? '',
      claim: map['claim'] ?? '',
      pic1: map['pic1'] ?? '',
      pic2: map['pic2'] ?? '',
      gentime: map['gentime'] ?? '',
      sent: map['sent'] ?? '',
      synced: map['synced'].toInt() ?? 0,
      completed: map['completed']?.toInt() ?? 0,
      deleted: map['deleted'].toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Defect.fromJson(String source) => Defect.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Defect(id: $id, uid: $uid, did: $did, site: $site, building: $building, house: $house, reg_name: $reg_name, reg_phone: $reg_phone, space: $space, area: $area, work: $work, sort: $sort, claim: $claim, pic1: $pic1, gentime: $gentime, sent: $sent, synced: $synced, completed: $completed, deleted: $deleted)';
  }
}