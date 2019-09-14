import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission/permission.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:Flavr/model/FeedListDetailsModel.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:Flavr/ui/RecipeDetailsScreen.dart';

class FeedListScreen extends StatefulWidget {
  int loginData;
  var likedFeed = <ItemDetailsFeed>[];
  @override
  _FeedListScreenState createState() => new _FeedListScreenState();
}

class _FeedListScreenState extends State<FeedListScreen>  {
  var _feedDetails = <ItemDetailsFeed>[];
  Future<ItemDetailsFeed> feed;

  var likedList = FeedListScreen().likedFeed;
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
          (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
          () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
          (String speech) => setState(() => filter.text = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
          () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
    );
  }

  var names = <ItemDetailsFeed>[]; // names we get from API
  var filteredNames = <ItemDetailsFeed>[];
  Icon _searchIcon = new Icon(Icons.search);
  Icon _voiceSearchIcon = new Icon(Icons.keyboard_voice);

  Widget _appBarTitle = new Text('Home');

  final TextEditingController filter = new TextEditingController();

  GlobalKey<ScaffoldState> login_state = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        centerTitle: true,
        actions: <Widget>[
          new IconButton(
            icon: _searchIcon,
            onPressed: () {
              _searchPressed();
            },
          ),
          new IconButton(
            icon: _voiceSearchIcon,
            onPressed: () {
              microphonePermission();
              _voiceSearchPressed();
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      key: login_state,
      body: FutureBuilder<dynamic>(
        future: _loadData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text(
                'no data available',
                textAlign: TextAlign.center,
              );
            case ConnectionState.active:
              return null;
            case ConnectionState.waiting:
              return SpinKitFadingCircle(color: Colors.pink);
            case ConnectionState.done:
              return _buildRow();
          }
          return null;
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushReplacementNamed('/AddRecipeScreen');
        },
        tooltip: 'Add Recipe',
        child: new Icon(Icons.note_add, color: Colors.black,),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future _loadData() async {
//    _feedDetails = HomeFeedAPI(context);
//    HomeFeedAPI(context);
    String feedDetailsURL = "http://35.160.197.175:3006/api/v1/recipe/feeds";
    var dio = new Dio();
    Map<String, dynamic> map = {
      HttpHeaders.authorizationHeader:
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6Mn0.MGBf-reNrHdQuwQzRDDNPMo5oWv4GlZKlDShFAAe16s"
    };
    var response1 =
    await dio.get(feedDetailsURL, options: Options(headers: map));

    for (var memberJSON in response1.data) {
      final itemDetailsfeed = new ItemDetailsFeed(
          memberJSON["recipeId"],
          memberJSON["name"],
          memberJSON["photo"],
          memberJSON["preparationTime"],
          memberJSON["serves"],
          memberJSON["complexity"],
          false,
          memberJSON["ytUrl"]);
      _feedDetails.add(itemDetailsfeed);
      names.add(itemDetailsfeed);
      filteredNames = names;
    }
  }

  _LikeState(index) {
    setState(() {
      _feedDetails[index].like = !_feedDetails[index].like;
      likedList.add(filteredNames[index]);
    });
  }

  _HomeScreenState() {
    filter.addListener(() {
      setState(() {
        _searchText = filter.text;
      });
    });
  }

  void _voiceSearchPressed() {
    if (_isAvailable && !_isListening)
      _speechRecognition
          .listen(locale: "en_US")
          .then((result) => filter.text = result);

    setState(() {
      if (this._voiceSearchIcon.icon == Icons.keyboard_voice) {
        this._voiceSearchIcon = new Icon(Icons.close);
        this._appBarTitle = TextFormField(
          textInputAction: TextInputAction.done,
          controller: filter,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: new Icon(Icons.settings_voice),
            hintText: 'Listening...',
          ),
          onFieldSubmitted: (term) {
            filter.text = _searchText;
            FocusScope.of(context).unfocus();
          },
        );
        _HomeScreenState();
      } else {
        _isAvailable = true;
        this._searchIcon = Icon(Icons.search);
        this._voiceSearchIcon = new Icon(Icons.keyboard_voice);
        this._appBarTitle = Text('Home');
        filter.clear();
        _searchText = "";
      }
    });
  }

  Future microphonePermission() async {
    var permissions =
    await Permission.getPermissionsStatus([PermissionName.Microphone]);
    if (permissions != PermissionStatus.allow) {
      Permission.requestPermissions([PermissionName.Microphone]);
    } else {}
  }

  Future _searchPressed() async {
    await setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = TextFormField(
          textInputAction: TextInputAction.done,
          controller: filter,
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: new Icon(Icons.search),
            hintText: 'Search...',
          ),
          onFieldSubmitted: (term) {
            _searchText = filter.text;
            FocusScope.of(context).unfocus();
          },
        );
        _HomeScreenState();
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = Text('Home');
        filter.clear();
        _searchText = "";
      }
    });
  }

  Widget _buildRow() {
    if (!(_searchText.isEmpty)) {
      var tempList = <ItemDetailsFeed>[];
      for (int i = 0; i < filteredNames.length; i++) {
        if (filteredNames[i]
            .getName()
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(filteredNames[i]);
        }
      }
      filteredNames = tempList;
    }
    return new ListView.builder(
      itemCount: filteredNames.length,
      itemBuilder: (BuildContext context, int index) {
//        var counter = Provider.of<Counter>(context);
//        counter.setCounter(false);
        if (filteredNames.length == 0) {
          return Scaffold(
            body: new FadeInImage.assetNetwork(
              placeholder: 'images/loaderfood.gif',
              image: filteredNames[index].photo,
              fit: BoxFit.fitWidth,
              width: double.infinity,
              height: 175,
            ),
          );
        } else
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              child: new ListTile(
                onTap: () {
                  navigateToSubPage(context, index, filteredNames);
                },
                title: new Card(
                  margin: EdgeInsets.only(left: 0, right: 0, top: 5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Stack(
                        children: <Widget>[
                          new FadeInImage.assetNetwork(
                            placeholder: 'images/loaderfood.gif',
                            image: filteredNames[index].photo,
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            height: 175,
                          ),
                          IconButton(
                            alignment: Alignment.topRight,
                            icon: Icon(
                                _feedDetails[index].like
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _feedDetails[index].like
                                    ? Colors.red
                                    : Colors.grey),
                            onPressed: () {
                              _feedDetails[index].like =
                              !_feedDetails[index].like;
                              likedList.add(filteredNames[index]);
                              _LikeState(index);
                             },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, top: 10),
                        child: new Text(filteredNames[index].name,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, top: 5),
                        child: new Text(filteredNames[index].name,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: new Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      filteredNames[index].preparationTime,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.library_books,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      filteredNames[index].complexity,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.local_dining,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      "${filteredNames[index].serves} people",
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
      },
    );
  }
}

Future navigateToSubPage(context, int, list) async {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => RecipeDetailsScreen(int, list)));
}