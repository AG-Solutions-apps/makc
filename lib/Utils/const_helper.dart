import 'package:flutter/cupertino.dart';

class ConstHelper{

  ConstHelper._();
  static ConstHelper constHelper = ConstHelper._();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

}