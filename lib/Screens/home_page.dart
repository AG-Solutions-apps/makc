import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Model/banner_model.dart';
import 'package:makc/Model/service_,odel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/api_helper.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Controller controller = Get.put(Controller());
  PageController pageController = PageController(viewportFraction: 0.8);
  RxInt currentPage = 0.obs;
  Timer? timer;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getLoginToken().then((value) {
      ApiHelper.apiHelper.fetchServiceBanner(token: controller.isLoginToken.value).then((banner) {
        // print("DDDDDDD ${value["data"]}");
        // print("IIIIIII ${value["image_url"]}");

        ApiHelper.apiHelper.fetchService(token: controller.isLoginToken.value).then((service) {

          List filterList = banner["data"];
          List serviceFilterList = service["data"];
          controller.bannerList.value = filterList.map((e) => BannerDataModel.fromJson(e),).toList();
          controller.imagePath.value = "${banner["image_url"][1]["image_url"]}";
          controller.noImagePath.value = "${banner["image_url"][0]["image_url"]}";

          controller.serviceList.value = serviceFilterList.map((e) => ServiceDataModel.fromJson(e),).toList();
          controller.serviceImagePath.value = "${service["image_url"][1]["image_url"]}";
          controller.serviceNOImagePath.value = "${service["image_url"][0]["image_url"]}";
          print("SSSSSSSSSSS ${controller.serviceList.length}");
        },);

      },);

    },);
    startAutoSlide();
  }

  void startAutoSlide() {
    timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      int nextPage = pageController.page!.round() + 1;

      if (nextPage >= controller.bannerList.length) {
        nextPage = 0;
      }

      pageController.animateToPage(
        nextPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> checkApp({required String packageName,required String url}) async {
    bool? isInstalled = await InstalledApps.isAppInstalled(packageName);

    if (isInstalled!) {
      InstalledApps.startApp(packageName);
    } else {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Could not launch ${Uri.parse(url)}');
      }
    }
  }
  String getPackageName(String url) {
    Uri uri = Uri.parse(url);
    return uri.queryParameters['id'] ?? '';
  }


  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
            backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Home",style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.w500),),
                SizedBox(height: Get.width/40,),
                Obx(
                  () =>  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: controller.serviceList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        // ApiHelper.apiHelper.getPackageName(url: controller.serviceList[index].serviceUrl!);
                       String package =  getPackageName(controller.serviceList[index].serviceUrl!);
                       print("PPPPPPPP $package");
                       checkApp(packageName: package, url: controller.serviceList[index].serviceUrl!);
                        // print("${controller.serviceImagePath.value}${controller.serviceList[index].serviceLogo}");
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Container(
                        height: Get.width/3,
                        decoration: BoxDecoration(
                            color: Color(0xffF5FFF4),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.network("${controller.serviceImagePath.value}${controller.serviceList[index].serviceLogo}",width: Get.width/8,height: Get.width/8,fit: BoxFit.contain,),
                                ),
                              ),
                              SizedBox(height: Get.width/50,),
                              Text(controller.serviceList[index].serviceName??"",style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500),),
                            ],
                          ),
                        ),
                      ),
                    );
                  },),
                ),
                SizedBox(height: Get.width/20,),
                // Container(
                //   height: 155,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: Colors.blue,
                //     borderRadius: BorderRadius.circular(10)
                //   ),
                //   child: ClipRRect(
                //       borderRadius: BorderRadiusGeometry.circular(10),
                //       child: Image.asset("assets/demo.png",fit: BoxFit.cover,)),
                // ),
            SizedBox(
              height: Get.width/2.5,
              child: Obx(
                () =>  PageView.builder(
                  controller: pageController,
                  itemCount: controller.bannerList.length,
                  itemBuilder: (context, index) {

                    // double scale = (1 - (currentPage - index).abs() * 0.2).clamp(0.8, 1);

                    return Container(
                      // height: Get.width/3,
                      // width: Get.width/1,
                      // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(15),
                          child: Image.network("${controller.imagePath.value}${controller.bannerList[index].serviceSubBanner}",fit: BoxFit.cover,)),
                    );
                  },
                ),
              ),
            ),
                SizedBox(height: Get.width/30,),
              ],
            ),
          ),
        ),
          ),
    );
  }
}
