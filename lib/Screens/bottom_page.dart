import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Screens/about_us_page.dart';
import 'package:makc/Screens/home_page.dart';
import 'package:makc/Screens/profile_page.dart';
import 'complaint_page.dart';

class BottomPage extends StatefulWidget {
  const BottomPage({super.key});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  RxInt bottomIndex = 0.obs;
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bottomIndex.value = 0;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => bottomIndex.value == 0?HomePage():bottomIndex.value == 1?ComplaintPage():bottomIndex.value == 2?ProfilePage():AboutUsPage(),),
      bottomNavigationBar: Container(
        height: Get.width/5,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200))
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(
            () =>  Row(
              children: [
                Expanded(
                  child: InkWell(
                  onTap: () {
                    bottomIndex.value = 0;
                  },
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/bottom/home.svg",fit: BoxFit.cover,height: Get.width/18,width: Get.width/18,color: bottomIndex.value == 0?Color(0xff2D3290):Color(0xff75777B),),
                      SizedBox(height: Get.width/50,),
                      Text("Home",style: TextStyle(fontSize: 12,color: bottomIndex.value == 0?Color(0xff2D3290):Color(0xff75777B),fontWeight: FontWeight.w400),)
                    ],
                  ),
                )),
                Expanded(child: InkWell(
                  onTap: () {
                    bottomIndex.value =1;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/bottom/notification.svg",fit: BoxFit.cover,height: Get.width/18,width: Get.width/18,color: bottomIndex.value == 1?Color(0xff2D3290):Color(0xff75777B),),
                      SizedBox(height: Get.width/50,),
                      Text("Complaint",style: TextStyle(fontSize: 12,color: bottomIndex.value == 1?Color(0xff2D3290):Color(0xff75777B),fontWeight: FontWeight.w400))
                    ],
                  ),
                )),
                Expanded(child: InkWell(
                  onTap: () {
                    bottomIndex.value = 2;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/bottom/profile.svg",fit: BoxFit.cover,height: Get.width/18,width: Get.width/18,color: bottomIndex.value == 2?Color(0xff2D3290):Color(0xff75777B),),
                      SizedBox(height: Get.width/50,),
                      Text("Profile",style: TextStyle(fontSize: 12,color: bottomIndex.value == 2?Color(0xff2D3290):Color(0xff75777B),fontWeight: FontWeight.w400),)
                    ],
                  ),
                )),
                Expanded(child: InkWell(
                  onTap: () {
                    bottomIndex.value = 3;
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/bottom/about.svg",fit: BoxFit.cover,height: Get.width/18,width: Get.width/18,color: bottomIndex.value == 3?Color(0xff2D3290):Color(0xff75777B),),
                      SizedBox(height: Get.width/50,),
                      Text("About Us",style: TextStyle(fontSize: 12,color: bottomIndex.value == 3?Color(0xff2D3290):Color(0xff75777B),fontWeight: FontWeight.w400),)
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
