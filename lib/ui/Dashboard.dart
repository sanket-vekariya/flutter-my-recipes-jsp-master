import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:Flavr/model/IngredientsDetailsFeed.dart';
import 'package:Flavr/model/InstructionDetailsFeed.dart';
import 'package:Flavr/model/ItemDetailsFeed.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:share/share.dart';
class DashBoard extends StatefulWidget {
  int index;
  List<ItemDetailsFeed> list;

  DashBoard(this.index, this.list);

  @override
  _DashBoardState createState() => new _DashBoardState(index, list);
}

class _DashBoardState extends State<DashBoard> {
  int data;
  int newindex;
  List<ItemDetailsFeed> list;

  var indegrents;
  var insturctions;

  GlobalKey<ScaffoldState> login_state = new GlobalKey<ScaffoldState>();

  _DashBoardState(this.data, this.list);

  var _ingredientsDetailsFeed = <IngredientsDetailsFeed>[];
  var _instructionDetails = <InstructionDetailsFeed>[];
  VideoPlayerController _videoController;

  Widget _listViewIndergents() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _ingredientsDetailsFeed.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            maxRadius: 12.0,
          ),
          title: Text(_ingredientsDetailsFeed[index].ingredient),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }


  Widget _listViewSteps() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _instructionDetails.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            maxRadius: 12.0,
          ),
          title: Text(_instructionDetails[index].instruction),
        );
      },
      separatorBuilder: (context, index) {
        return Divider();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(list[data].getName().toUpperCase()),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              if (list[data].youtubeUrl == ""){
                Share.share(
                    "Item Name : " + list[data].name +"\n" +
                        "Preparation Time : " + list[data].preparationTime +"\n" +
                        "Complexity : " + list[data].complexity +"\n" +
                        "Total Serving People : " + list[data].serves +"\n"
                );
              }

              if(list[data].youtubeUrl != ""){
                Share.share(
                    "Item Name : " + list[data].name +"\n" +
                        "Preparation Time : " + list[data].preparationTime +"\n" +
                        "Complexity : " + list[data].complexity +"\n" +
                        "Total Serving People : " + list[data].serves +"\n" +
                        "Youtube URL: " + list[data].youtubeUrl +"\n"
                );
              }

            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Card(
                child: list[data].youtubeUrl == ""
                    ? Image.network(list[data].photo)
                    : Stack(
                        children: <Widget>[
                          YoutubePlayer(
                            context: context,
                            controlsColor: ControlsColor(
                                buttonColor: Colors.amber,
                                playPauseColor: Colors.red,
                                progressBarBackgroundColor: Colors.pink,
                                seekBarPlayedColor: Colors.white),
                            source: list[data].youtubeUrl,
                            quality: YoutubeQuality.MEDIUM,
                            loop: true,
                            autoPlay: true,
                            keepScreenOn: false,
                            callbackController: (controller) {
                              _videoController = controller;
                            },
                          ),
                        ],
                      ),
              ),
            ),
            //Image.network(list[data].photo)
            Container(
              color: Colors.white30,
              padding: EdgeInsets.all(10.0),
              child: new Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        list[data].getName(),
                        style: TextStyle(fontSize: 15.0, color: Colors.grey),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        list[data].getName(),
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                            fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.timer),
                                  Text(
                                    list[data].preparationTime,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.library_books),
                                  Text(
                                    list[data].complexity,
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.fastfood),
                                  Text(
                                    list[data].serves + " people",
                                    style: TextStyle(
                                        fontSize: 15.0, color: Colors.grey),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),

            Container(
              color: Colors.orange,
              width: double.infinity,
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "INGREDIENTS",
                    style: TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold,color: Colors.white),
                  )
                ],
              ),
            ),

            FutureBuilder<dynamic>(
              key: login_state,
              future: _loadData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text(
                      'no data available',
                      textAlign: TextAlign.center,
                    );
                  case ConnectionState.active:
                    return Text(
                      'no data available',
                      textAlign: TextAlign.center,
                    );
                    return SpinKitFadingCircle(color: Colors.black);
                  case ConnectionState.waiting:
                    return SpinKitFadingCircle(color: Colors.pink);
                  case ConnectionState.done:
                    newindex = data;
                    return Text(
                      _ingredientsDetailsFeed[newindex].ingredient,
                      textAlign: TextAlign.center,style: TextStyle(fontSize: 15.0),
                    );
                    return _listViewIndergents();

                }
                return null;
              },
            ),

            Container(
              color: Colors.orange,
              width: double.infinity,
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "INSTRUCTIONS",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            FutureBuilder<dynamic>(
              future: _loadInstruction(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return Text(
                      'no data available',
                      textAlign: TextAlign.center,
                    );
                  case ConnectionState.active:
                    return Text(
                      'no data available',
                      textAlign: TextAlign.center,
                    );
                    return SpinKitFadingCircle(color: Colors.black);
                  case ConnectionState.waiting:
                    return SpinKitFadingCircle(color: Colors.pink);
                  case ConnectionState.done:
                    newindex = data;
                    return _listViewSteps();

                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  _loadData() async {
    print("${list[data].recipeId}=====recipeId is===");
    String ingredientsURL =
        "http://35.160.197.175:3006/api/v1/recipe/${list[data].recipeId}/ingredients";
    var dio = new Dio();
    Map<String, dynamic> map = {
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Mn0.MGBf-reNrHdQuwQzRDDNPMo5oWv4GlZKlDShFAAe16s"
    };
    var response1 =
        await dio.get(ingredientsURL, options: Options(headers: map));

    for (var memberJSON in response1.data) {
      final ingreditentfeed = new IngredientsDetailsFeed(
        memberJSON["id"],
        memberJSON["ingredient"],
      );
      _ingredientsDetailsFeed.add(ingreditentfeed);
    }

    print("data item response ingredient : ${_ingredientsDetailsFeed[0].ingredient}");
    indegrents = (_ingredientsDetailsFeed[0].ingredient.replaceAll('[', '')).toString();
    indegrents = (indegrents.replaceAll(']', '')).toString();

    print("${indegrents[0]}===at  0 ===${indegrents}");
    print("${indegrents[1]} ");
  }

  _loadInstruction() async {
    String instructionsURL =
        "http://35.160.197.175:3006/api/v1/recipe/${list[data].recipeId}/instructions";
    var dio = new Dio();
    Map<String, dynamic> map = {
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Mn0.MGBf-reNrHdQuwQzRDDNPMo5oWv4GlZKlDShFAAe16s"
    };
    var response1 =
        await dio.get(instructionsURL, options: Options(headers: map));

    for (var memberJSON in response1.data) {
      final instructionfeed = new InstructionDetailsFeed(
        memberJSON["id"],
        memberJSON["instruction"],
      );
      _instructionDetails.add(instructionfeed);
    }
    /*  print("response : $response1");
    print("data response : ${response1.data}");
    print("data item response : ${_feedDetails[0].ingredient}");
    print("length response : ${_feedDetails.length}");*/
  }

  @override
  void initState() {
    super.initState();
  }
}
