import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/services.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:rongcloud_im_plugin/rc_common_define.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    //以下数据可自行前往融云官网注册申请 https://www.rongcloud.cn/
    //融云 appkey
    String RongAppKey = 'Your appKey';
    //用户 id
    String userId = 'your Userid';
    //通过用户 id 生成的对应融云 token
    String RongIMToken = 'Your imtoken';

    //1.初始化 im SDK
    RongcloudImPlugin.init(RongAppKey);

    //2.配置 im SDK
    String confString = await DefaultAssetBundle.of(context).loadString("assets/RCFlutterConf.json");
    Map confMap = json.decode(confString.toString());
    RongcloudImPlugin.config(confMap);

    //3.连接 im SDK
    int rc = await RongcloudImPlugin.connect(RongIMToken);
    print('connect result');
    print(rc);

    //4.刷新当前用户的用户信息
    String portraitUrl = "https://www.rongcloud.cn/pc/images/huawei-icon.png";
    RongcloudImPlugin.updateCurrentUserInfo(userId, "李四", portraitUrl);

    //5.设置监听回调，处理 native 层传递过来的事件
    RongcloudImPlugin.setRCNativeMethodCallHandler(_handler);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    setState(() {

    });
  }

  //6.响应 native 的事件
  Future<dynamic> _handler(MethodCall methodCall) {
    //当 im SDK 需要展示用户信息的时候，会回调此方法
    if (MethodCallBackKeyFetchUserInfo == methodCall.method) {
      //开发者需要将用户信息传递给 SDK
      //如果本地有该用户的信息，那么直接传递给 SDK
      //如果本地没有该用户的信息，从 APP 服务获取后传递给 SDK
      String userId = methodCall.arguments;
      String name = "张三";
      String portraitUrl = "https://www.rongcloud.cn/pc/images/lizhi-icon.png";
      RongcloudImPlugin.refreshUserInfo(userId, name, portraitUrl);
    } 
  }

  onPushToConversationList()  {
    List conTypes = [RCConversationTypePrivate,RCConversationTypeGroup];
    RongcloudImPlugin.pushToConversationList(conTypes);
  }

  onPushToConversation() {
    RongcloudImPlugin.pushToConversation(RCConversationTypePrivate,"asdf");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 400,
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[]),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onPushToConversationList(),
                              child: Text("onPushToConversationList"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                        
                      )
                    ),
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () => onPushToConversation(),
                              child: Text("onPushToConversation"),
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                            ),
                          )
                        ],
                        
                      )
                    )
                ],
              )
              ),
        ),
      ),
    );
  }
  
}
