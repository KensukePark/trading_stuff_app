import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shopping_app/screens/login_page.dart';
import 'package:shopping_app/screens/home_page.dart';
import '../model/like_model.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPage createState() {
    return _LoadingPage();
  }
}

class _LoadingPage extends State<LoadingPage> {
  Future<bool> checkLogin() async {
    final like_provider = Provider.of<LikeProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLogin = prefs.getBool('isLogin') ?? false;
    String uid = prefs.getString('uid') ?? '';
    like_provider.fetchLikeItemsOrCreate(uid);
    return isLogin;
  }

  void moveScreen() async {
    await checkLogin().then((isLogin) {
      if (isLogin) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
  }
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 2000), () {
      moveScreen();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitFadingCircle(
          color: Colors.white,
          size: 80.0,
        ),
      ),
    );
  }
}