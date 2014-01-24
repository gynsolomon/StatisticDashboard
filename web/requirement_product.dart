part of statistic;

map_login() => {
                 "title":"已登录",
                 "type":"mixpanel",
                 "schema":"http://mixpanel.com/api/2.0/segmentation/",
                 "args":[
                         "limit=10000",
                         "event=Login",
                         "from_date=2014-01-14",
                         "to_date=$dateNow",
                         "on=properties[\"Name\"]",
                         "where=\"$_roomName\" in properties[\"UserName\"]",
                         "type=unique",
                         "expire=$timeFuture",
                         "api_key=$apiKey"
                         ],
                         "api_secret":apiSecret
};

map_enterLesson(String lessonTitle) => {
                        "title":"进入$lessonTitle",
                        "type":"mixpanel",
                        "schema":"http://mixpanel.com/api/2.0/segmentation/",
                        "args":[
                                "limit=10000",
                                "event=EnterLesson",
                                "from_date=2014-01-14",
                                "to_date=$dateNow",
                                "on=properties[\"Name\"]",
                                "where=\"$_roomName\" in properties[\"UserName\"] and \"$lessonTitle\" == properties[\"LessonTitle\"]",
                                "type=unique",
                                "expire=$timeFuture",
                                "api_key=$apiKey"
                                ],
                                "api_secret":apiSecret                     
};


map_finishLesson(String lessonTitle) => {
                        "title":"完成$lessonTitle",
                        "type":"mixpanel",
                        "schema":"http://mixpanel.com/api/2.0/segmentation/",
                        "args":[
                                "limit=10000",
                                "event=FinishLesson",
                                "from_date=2014-01-14",
                                "to_date=$dateNow",
                                "on=properties[\"Name\"]",
                                "where=\"$_roomName\" in properties[\"UserName\"] and \"$lessonTitle\" == properties[\"LessonTitle\"]",
                                "type=unique",
                                "expire=$timeFuture",
                                "api_key=$apiKey"
                                ],
                                "api_secret":apiSecret                     
};