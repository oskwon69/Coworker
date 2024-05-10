class UserInfo {
  String? uid;
  String? did;
  int? site_code;
  String? site_name;
  String? building_no;
  String? house_no;
  String? user_name;
  String? user_phone;
  String? birth_date;
  String? type;

  UserInfo({
    this.uid,
    this.did,
    this.site_code,
    this.site_name,
    this.building_no,
    this.house_no,
    this.user_name,
    this.user_phone,
    this.birth_date,
    this.type,
  });

  @override
  String toString() {
    return 'UserInfo(uid: $uid, mid: $did, site_code: $site_code, site_name: $site_name, building_no: $building_no, house_no: $house_no, user_name: $user_name, user_phone: $user_phone, birth_date: $birth_date, type: $type)';
  }
}