import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:makc/Screens/splash_screen.dart';
import 'package:makc/Utils/const_helper.dart';

void main()
{
  runApp(
    GetMaterialApp(
      navigatorKey: ConstHelper.navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: "home",
      routes: {
        "home":(p0) => SplashScreen()
      },
    )
  );
}