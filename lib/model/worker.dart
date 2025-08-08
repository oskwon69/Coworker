class WorkerInfo {
  int? worker_id;
  int? site_code;
  String? site_name;
  String? worker_name;
  String? phone_no;
  String? birth_date;
  String? work_name;
  int? level;

  WorkerInfo({
    this.worker_id,
    this.site_code,
    this.site_name,
    this.worker_name,
    this.phone_no,
    this.birth_date,
    this.work_name,
    this.level
  });

  @override
  String toString() {
    return 'WorkerInfo(worker_id: $worker_id, site_code: $site_code, site_name: $site_name, worker_name: $worker_name, phone_no: $phone_no, birth_date: $birth_date, work_name: $work_name, level: $level)';
  }
}