import 'package:coworker/model/worker.dart';
import 'package:coworker/UI/show_defect_detail_for_worker.dart';
import 'package:coworker/UI/show_defect_detail_sent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:coworker/database/defect_database.dart';
import 'package:coworker/API/globals.dart' as globals;
import '../model/defect_server.dart';

class WorkerDefectCardWidget extends StatefulWidget {
  const WorkerDefectCardWidget({Key? key, required this.index, required this.defect, required this.worker, required this.function}) : super(key: key);

  final int index;
  final DefectEx defect;
  final WorkerInfo worker;
  final Function function;

  @override
  State<WorkerDefectCardWidget> createState() => _WorkerDefectCardWidgetState();
}

class _WorkerDefectCardWidgetState extends State<WorkerDefectCardWidget> {
  late DefectEx _defect;
  late WorkerInfo _worker;
  String _imagePath = '';

  final DefectDatabase _databaseService = DefectDatabase();

  @override
  void initState() {
    super.initState();

    _defect = widget.defect;
    _worker = widget.worker;

    if( widget.defect.pic1 != '' )  {
      _imagePath = widget.defect.pic1!;
    }
  }

  returnList() {
    setState(() {
      widget.function();
    });
  }

  @override
  Widget build(BuildContext context) {
    String _title = '${widget.index+1}. ${widget.defect.building_no}/${widget.defect.house_no} ${widget.defect.space_name} ${widget.defect.sort_name}';

    String _status = '  상태 : ';
    _status += widget.defect.work_status == 0 ?  '접수' : '작업완료';
    _status += ' | ';
    _status += widget.defect.work_status == 0 ?  ' 전송날짜 : ${widget.defect.sent_date!.split('-').first}' : '작업날짜 : ${widget.defect.work_date!.split('-').first}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: widget.defect.work_status==0 ? Colors.red : Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                )
            ),
            width: 10,
          ),
          Gap(10),
          InkWell(
            onTap: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => ShowWorkerDefect(defect: _defect, worker: _worker, function: returnList),
              );
            },
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width/2*0.40,
                  height: MediaQuery.of(context).size.width/2*0.40*3/4,
                  decoration: BoxDecoration( borderRadius: BorderRadius.circular(8.0), color: Colors.grey.shade200),
                  child: _imagePath != '' ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(globals.serverImagePath+'/'+_imagePath),
                  ) :
                  Center(child: Icon(CupertinoIcons.photo_fill_on_rectangle_fill)),
                ),
                Gap(10),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
                        width: MediaQuery.of(context).size.width*0.6,
                        color: Colors.white,
                        child:      Text(_title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                        width: MediaQuery.of(context).size.width*0.6,
                        color: Colors.white,
                        child:  Text(widget.defect.claim, style: TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis,),

                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        width: MediaQuery.of(context).size.width*0.6,
                        child: Divider(thickness: 1.5, color: Colors.grey.shade300,),
                      ),
                      Text(_status, style: TextStyle(fontSize: 13)),
                    ]
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
