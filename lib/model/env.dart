import 'dart:convert';

class Site {
  int id;
  int site_code;
  String site_name;
  int status;

  Site({
    required this.id,
    required this.site_code,
    required this.site_name,
    required this.status
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'site_code' : site_code,
      'site_name' : site_name,
      'status' : status
    };
  }

  factory Site.fromMap(Map<String, dynamic> map)  {
    return Site(
      id: map['id']?.toInt() ?? 0,
      site_code: map['site_code']?.toInt() ?? '',
      site_name: map['site_name'] ?? '',
      status: map['status']?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'Site(id: $id, site_code: $site_code, site_name: $site_name, status: $status)';
  }
}

class House {
  int id;
  int site_code;
  String site_name;
  String building_no;
  String house_no;
  String type;
  int line_no;

  House({
    required this.id,
    required this.site_code,
    required this.site_name,
    required this.building_no,
    required this.house_no,
    required this.type,
    required this.line_no
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'site_code' : site_code,
      'site_name' : site_name,
      'building_no' : building_no,
      'house_no' : house_no,
      'type' : type,
      'line_no' : line_no
    };
  }

  factory House.fromMap(Map<String, dynamic> map)  {
    return House(
      id: map['id']?.toInt() ?? 0,
      site_code: map['site_code']?.toInt() ?? '',
      site_name: map['site_name'] ?? '',
      building_no: map['building_no'] ?? '',
      house_no: map['house_no'] ?? '',
      type: map['type'] ?? '',
      line_no: map['line_no']?.toInt() ?? 0,
    );
  }

  @override
  String toString() {
    return 'House(id: $id, site_code: $site_code, site_name: $site_name, building_no: $building_no, house_no: $house_no, type: $type, line_no: $line_no)';
  }
}

class Space {
  int id;
  int site_code;
  String space_name;

  Space({
    required this.id,
    required this.site_code,
    required this.space_name
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'site_code' : site_code,
      'space_name' : space_name
    };
  }

  factory Space.fromMap(Map<String, dynamic> map)  {
    return Space(
      id: map['id']?.toInt() ?? 0,
      site_code: map['site_code']?.toInt() ?? '',
      space_name: map['space_name'] ?? ''
    );
  }

  @override
  String toString() {
    return 'Space(id: $id, site_code: $site_code, space_name: $space_name)';
  }
}

class Area {
  int id;
  int site_code;
  String area_name;

  Area({
    required this.id,
    required this.site_code,
    required this.area_name
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'site_code' : site_code,
      'area_name' : area_name
    };
  }

  factory Area.fromMap(Map<String, dynamic> map)  {
    return Area(
        id: map['id']?.toInt() ?? 0,
        site_code: map['site_code']?.toInt() ?? '',
        area_name: map['area_name'] ?? ''
    );
  }

  String toString() {
    return 'Area(id: $id, site_code: $site_code, area_name: $area_name)';
  }
}

class Work {
  int id;
  int site_code;
  String work_name;

  Work({
    required this.id,
    required this.site_code,
    required this.work_name
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'site_code' : site_code,
      'work_name' : work_name
    };
  }

  factory Work.fromMap(Map<String, dynamic> map)  {
    return Work(
        id: map['id']?.toInt() ?? 0,
        site_code: map['site_code']?.toInt() ?? '',
        work_name: map['work_name'] ?? ''
    );
  }

  String toString() {
    return 'Work(id: $id, site_code: $site_code, work_name: $work_name)';
  }
}

class Sort {
  int id;
  int site_code;
  String sort_name;

  Sort({
    required this.id,
    required this.site_code,
    required this.sort_name
  });

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'site_code' : site_code,
      'sort_name' : sort_name
    };
  }

  factory Sort.fromMap(Map<String, dynamic> map)  {
    return Sort(
        id: map['id']?.toInt() ?? 0,
        site_code: map['site_code']?.toInt() ?? '',
        sort_name: map['sort_name'] ?? ''
    );
  }

  String toString() {
    return 'Sort(id: $id, site_code: $site_code, sort_name: $sort_name)';
  }
}