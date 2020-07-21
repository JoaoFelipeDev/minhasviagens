import 'dart:async';

import 'package:flutter/material.dart';

import 'Home.dart';


class SplashScreem extends StatefulWidget {
  @override
  _SplashScreemState createState() => _SplashScreemState();
}

class _SplashScreemState extends State<SplashScreem> {
  @override
  void didChangeDependencies() {
   
    super.didChangeDependencies();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(context,
       MaterialPageRoute(builder: (_)=>  Home() )
       );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff0066cc),
        padding: EdgeInsets.all(60),
        child: Center(
          child: Image.asset("imagens/logo.png"),
        ),
      ),
    );
  }
}
