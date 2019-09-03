import 'package:flutter/material.dart';
import 'homeScreen.dart';
import 'splashScreen.dart';
import 'loginScreen.dart';
import 'FeedListPage.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "MyRecipes",
       debugShowCheckedModeBanner : false,
      routes: <String,WidgetBuilder>{
        "/HomeScreen": (BuildContext context) => HomeScreen(),
        "/LoginScreen": (BuildContext context) => LoginScreen(),
        "/FeedListPage": (BuildContext context) => FeedListPage(),
      },
      home:
      SplashScreen(),



    );
  }
}
