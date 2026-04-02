import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Model/company_model.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/const_helper.dart';
import 'package:makc/Utils/loader.dart';
import 'package:makc/Utils/shared_pref.dart';
import 'package:makc/Screens/bottom_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  Controller controller = Get.put(Controller());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    txtMobile.clear();
    txtPassword.clear();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              children: [
                Container(
                  height: Get.width/2,
                  width: Get.width/2,
                  decoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                  child: Image.asset("assets/appicon.jpeg",fit: BoxFit.cover,),
                ),
                SizedBox(height: Get.height/30,),
                TextFormField(
                  controller: txtMobile,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff2D3290)),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: "Mobile No",
                    hintText: "Enter the mobile no",
                    labelStyle: TextStyle(color: Color(0xff2D3290))
                  ),
                  validator: (value) {
                    if(value!.isEmpty)
                      {
                        return "Please enter the mobile no";
                      }
                    return null;
                  },
                ),
                SizedBox(height: Get.height/30,),
                TextFormField(
                  controller: txtPassword,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff2D3290)),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    labelText: "Password",
                    hintText: "Enter the password",
                  ),
                  validator: (value) {
                    if(value!.isEmpty)
                    {
                      return "Please enter the password";
                    }
                    return null;
                  },
                ),
                SizedBox(height: Get.height/50,),
                Align(
                  alignment: AlignmentGeometry.centerRight,
                  child: TextButton(onPressed: () {

                  }, child: Text("Forgot password?",style: TextStyle(color: Color(0xff2D3290)),)),
                ),
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    if(key.currentState!.validate())
                      {
                        Loader.showLoader(ConstHelper.navigatorKey.currentContext!,"Please wait...");
                        ApiHelper.apiHelper.getLogin(mobile: txtMobile.text, password: txtPassword.text, deviceID: "121dfsfddsfsf").then((value) async {
                          if(value["code"] == 200)
                            {
                              Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                              List companyImageList = value["image_url"];

                              // print("ccccccc ${companyImageList[0]["image_url"]}");

                              CompanyDataModel company = CompanyDataModel.fromJson(value["company"]);
                              String token = value["data"]["token"];
                              SharedPref.saveCompanyData(company);
                              SharedPref.saveImagePath(companyImageList[0]["image_url"]);
                              SharedPref.saveNoImagePath(companyImageList[1]["image_url"]);
                              SharedPref.saveLogin(true);
                              SharedPref.saveLoginToken(token);
                              Get.offAll(BottomPage(),transition: Transition.fadeIn);
                              ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(value["message"],style: TextStyle(color: Colors.white),),backgroundColor: Colors.green,duration: Duration(seconds: 2),));



                            }
                          else
                            {
                              Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                              ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(value["message"],style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,duration: Duration(seconds: 2),));
                            }
                        },);
                      }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xff2D3290),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Center(child: Text("Login",style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
