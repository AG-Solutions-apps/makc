import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:makc/Screens/splash_screen.dart';
import 'package:makc/Utils/const_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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