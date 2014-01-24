library statistic;

import 'dart:html';
import 'dart:js';
import 'dart:convert';
import "package:js/js.dart" as js;
import "dart:async";
import "package:jsonp/jsonp.dart" as jsonp;
import 'package:crypto/crypto.dart';
import 'package:angular/angular.dart';
import 'package:intl/intl.dart';
import 'package:message/message.dart';

part 'requirement_product.dart';

String apiKey = '1291ff9d8ceb337db6a0069d88079474';
String apiSecret = '05b9aae8d5305855b1cdfec0db2db140';
DateTime now = new DateTime.now();
String dateNow = new DateFormat("yyyy-MM-dd").format(now);
int timeFuture = now.add(new Duration(minutes:1)).millisecondsSinceEpoch;
String _roomName;
StringBuffer strHtml = new StringBuffer();


@NgController(
    selector: '[board]',
    publishAs: 'ctrl')
class BoardController {

  List<Student> students;
  List<Event> events;
  
  BoardController() {
  //  students = _loadUserData();
  //  events = _loadEvents();
  }
  
  void giveRoom(){ 
    (querySelector('#right-panel') as DivElement).innerHtml="";
    _roomName = (querySelector("#inputRoomName") as InputElement).value;
    events = _loadEvents();    
  }
  
  void showUsers(Event event){
    Map users = event.info['result']['data']['values'];
    strHtml.clear();
    users.forEach(appendUser);
    (querySelector('#right-panel') as DivElement).innerHtml = strHtml.toString();  
  }
  
  appendUser(String key, Map value){
    strHtml.write('<p>'+key+'</p></br><p>'+value.toString()+'</p></br>');
  }
   
  // Give requirements and load all the data.
  _loadEvents() {
    List<String> lessons = ["章节预习","对顶角基础","邻补角基础","同位角基础"]; // TODO: should get available lessons from api.
    List mixpanelEvents = [map_login()];
    for (String lesson in lessons){
      mixpanelEvents.add(map_enterLesson(lesson));
      mixpanelEvents.add(map_finishLesson(lesson));
    }
    
    List<Event> result = new List<Event>();
    
    for(var event in mixpanelEvents ){
      if(event['type']=="mixpanel"){
        MixpanelExportDataAPI mixpanel =new MixpanelExportDataAPI(event['schema'],event['args'],event['api_secret']);
        result.add(new Event(event['title'],mixpanel:mixpanel));
      }else{
        assert(event['type']=="selfMade");
        result.add(new Event(event['title']));
      }
    }     
    return result;
  }
  
  String jsonDataAsString = '''
[
  {
    "id":0,
    "name":"孙媛媛"
  },
  {"id":1,"name":"王昊轩","number":"xw130301"},
  {"id":2,"name":"王泰岩","number":"xw130302"},
  {"id":3,"name":"王紫涵","number":"xw130303"},
  {"id":4,"name":"王嘉慧","number":"xw130304"},
  {"id":5,"name":"王熙来","number":"xw130305"},
  {"id":6,"name":"尹泽睿","number":"xw130306"},
  {"id":7,"name":"白宸玮","number":"xw130307"},
  {"id":8,"name":"刘加隆","number":"xw130308"},
  {"id":9,"name":"刘泓睿","number":"xw130309"},
  {"id":10,"name":"汤智博","number":"xw130310"},
  {"id":11,"name":"孙文然","number":"xw130311"},
  {"id":12,"name":"李乐颜","number":"xw130312"},
  {"id":13,"name":"李思源","number":"xw130313"},
  {"id":14,"name":"杨逸尘","number":"xw130314"},
  {"id":15,"name":"杨翊凡","number":"xw130315"},
  {"id":16,"name":"杨瑞","number":"xw130316"},
  {"id":17,"name":"肖鑫培","number":"xw130317"},
  {"id":18,"name":"闵锐","number":"xw130318"},
  {"id":19,"name":"张家宁","number":"xw130319"},
  {"id":20,"name":"陈尚","number":"xw130320"},
  {"id":21,"name":"陈誉宁","number":"xw130321"},
  {"id":22,"name":"姜宜轩","number":"xw130322"},
  {"id":23,"name":"徐佳璐","number":"xw130323"},
  {"id":24,"name":"陶睿","number":"xw130324"},
  {"id":25,"name":"黄梓凝","number":"xw130325"},
  {"id":26,"name":"曹茗轩","number":"xw130326"},
  {"id":27,"name":"麻天晗","number":"xw130327"},
  {"id":28,"name":"章明慧","number":"xw130328"},
  {"id":29,"name":"董昊运","number":"xw130329"},
  {"id":30,"name":"韩祎博","number":"xw130330"},
  {"id":31,"name":"温浩喆","number":"xw130331"},
  {"id":32,"name":"解雨知","number":"xw130332"},
  {"id":33,"name":"熊楚涵","number":"xw130333"},
  {"id":34,"name":"滕英言","number":"xw130334"},
  {"id":35,"name":"滕媛媛","number":"xw130335"}
]
''';
  
  List<Student> _loadUserData() {
   // File allUserFile = new File("../all_user_xw1303.json");
   // Future<String> future = allUserFile.readAsString(UTF8);
   // future.then((value)=>handleValue(value))
         // .catchError((error)=>context['console'].callMethod('log', [error.toString()]));
    return handleValue(jsonDataAsString);
  }
  
  List<Student> handleValue(value){
    List parsedList = JSON.decode(value);
    List<Student> result = new List<Student>();;
    
    for(var i=0;i<parsedList.length;i++){
        result.add(new Student(parsedList[i]["id"],
            parsedList[i]["name"],parsedList[i]["number"]));
    }
    return result;
  }
}

class Student{
  int userId;
  String name;
  String userName;
  Student(this.userId,this.name,this.userName);
}

class Event{
  Map info;
  //Student _student;
  
  Event(String eventName,{MixpanelExportDataAPI mixpanel}){
    info = new Map();
    info['event_name'] = eventName;
    if(mixpanel!=null);{
      fetJson(mixpanel);
    }
  }
  
  void fetJson(MixpanelExportDataAPI mixpanel) {
    Future<js.Proxy> result = jsonp.fetch(
        uriGenerator: (callback) =>
            mixpanel.apiUri+"&callback=$callback");

    result.then((js.Proxy proxy) {
      String jsonValue = js.context.JSON.stringify(proxy);
      Map dartJson = JSON.decode(jsonValue);
      info['result'] = dartJson; 
    }); 
  } 
}    

class MixpanelExportDataAPI{
  String _sig;
  String _apiUri;
  
  String _sigGenerator(List<String> args, String api_secret){ 
    var md5 = new MD5();
    args.sort();
    List<int> bytes = UTF8.encode(args.join()+api_secret);  
    md5.add(bytes);
    return CryptoUtils.bytesToHex(md5.close());
  }

  MixpanelExportDataAPI(String schema, List<String> args, String api_secret){
    _sig = _sigGenerator(args,api_secret);
    args.add("sig="+_sig);
    _apiUri = schema + "?" + args.join('&');
    print(_apiUri);
  }
  
  String get apiUri => Uri.encodeFull(_apiUri);
  
}
class MyAppModule extends Module {
  MyAppModule() {
    type(BoardController);
  }
}

main() {
  ngBootstrap(module: new MyAppModule());
}