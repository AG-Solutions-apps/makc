import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:makc/Screens/login_page.dart';
import 'package:makc/Utils/shared_pref.dart';
import 'bottom_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  void checkLogin()
  async{
    bool login = await SharedPref.isLoggedIn()??false;
    Timer(Duration(seconds: 3), () async {
      if(login == true)
        {
          Get.offAll(BottomPage());
        }
      else
        {
          Get.offAll(LoginPage());
        }
      // Get.offAll(LoginPage());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/appicon.jpeg"), context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("WELCOME TO",style: TextStyle(color: Color(0xff2D3290),fontSize: 25,fontWeight: FontWeight.bold),),
            SizedBox(height: Get.width/50,),
            Center(
              child: SizedBox(
                  width: Get.width/1.5,
                  height: Get.width/1.5,
                  // color: ConstHelper.transparent,
                  child: Image.asset("assets/appicon.jpeg",fit: BoxFit.contain,)),
            ),
            SizedBox(height: Get.width/30,),
            Text("MAKc",style: TextStyle(color: Color(0xff2D3290),fontSize: 25,fontWeight: FontWeight.bold),),
            Text("Solutions",style: TextStyle(color: Color(0xff2D3290),fontSize: 18,fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}
