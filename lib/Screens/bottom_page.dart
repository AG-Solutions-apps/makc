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
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    controller.bottomIndex.value = 0;
  }

  Widget bottomItem({
    required int index,
    required String icon,
    required String title,
  }) {
    bool isSelected = controller.bottomIndex.value == index;

    return InkWell(
      onTap: () {
        controller.bottomIndex.value = index;
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  icon,
                  height: Get.width / 21,
                  width: Get.width / 21,
                  color: isSelected
                      ? const Color.fromARGB(255, 45, 50, 144)
                      : Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? const Color.fromARGB(255, 45, 50, 144)
                        : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Obx(
        () => controller.bottomIndex.value == 0
            ? HomePage()
            : controller.bottomIndex.value == 1
            ? ComplaintPage()
            : controller.bottomIndex.value == 2
            ? ProfilePage()
            : AboutUsPage(),
      ),
      bottomNavigationBar: Container(
        height: Get.width / 6,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020B24), // Midnight Navy
              Color(0xFF0A2A7D), // Cobalt/Royal Blue
              Color.fromARGB(255, 1, 111, 207), // Electric Neon Blue
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: bottomItem(
                    index: 0,
                    icon: "assets/bottom/home.svg",
                    title: "Home",
                  ),
                ),
                Expanded(
                  child: bottomItem(
                    index: 1,
                    icon: "assets/bottom/notification.svg",
                    title: "Requests",
                  ),
                ),
                Expanded(
                  child: bottomItem(
                    index: 2,
                    icon: "assets/bottom/profile.svg",
                    title: "Profile",
                  ),
                ),
                Expanded(
                  child: bottomItem(
                    index: 3,
                    icon: "assets/bottom/about.svg",
                    title: "About",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}