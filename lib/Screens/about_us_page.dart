import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  Controller controller  = Get.put(Controller());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getCompanyData();
    controller.getCompanyImage();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () =>  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("About Us",style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.w500),),
              SizedBox(height: Get.width/50,),
              Center(
                child: controller.imageLoader.value == false?SizedBox(
                    height: Get.width/5,
                    width: Get.width/5,
                    child: CircularProgressIndicator()):Container(
                  height: Get.width/1.5,
                  width: Get.width/1.5,
                  color: Colors.transparent,
                  child: controller.companyData.value.companyLogo == null || controller.companyData.value.companyLogo!.isEmpty?Image.network(controller.noCompanyImage.value):Image.network("${controller.companyImage.value}${controller.companyData.value.companyLogo}",fit: BoxFit.contain),
                ),
              ),
              Center(child: Text(controller.companyData.value.companyName??"---",style: TextStyle(color: Color(0xff2D3290),fontSize: 20,fontWeight: FontWeight.w500),)),
              SizedBox(height: Get.width/50,),
              Padding(
                padding: const EdgeInsets.only(left: 100,right: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/profile/call.svg",fit: BoxFit.cover,height: Get.width/12,width: Get.width/12,),
                        SizedBox(width: Get.width/30,),
                        Flexible(child: Text(controller.companyData.value.companyMobileNo??"**********",style: TextStyle(color: Color(0xff373839),fontSize: 14,fontWeight: FontWeight.w400),))
                      ],
                    ),
                    SizedBox(height: Get.width/20,),
                    Row(
                      children: [
                        SvgPicture.asset("assets/profile/email.svg",fit: BoxFit.cover,height: Get.width/12,width: Get.width/12,),
                        SizedBox(width: Get.width/30,),
                        Flexible(child: Text(controller.companyData.value.companyEmail??"abc@gmail.com",style: TextStyle(color: Color(0xff373839),fontSize: 14,fontWeight: FontWeight.w400),))
                      ],
                    ),
                    SizedBox(height: Get.width/20,),
                    Row(
                      children: [
                        SvgPicture.asset("assets/profile/area.svg",fit: BoxFit.cover,height: Get.width/12,width: Get.width/12,),
                        SizedBox(width: Get.width/30,),
                        Flexible(child: Text("${controller.companyData.value.companyAddress??"--"}",style: TextStyle(color: Color(0xff373839),fontSize: 14,fontWeight: FontWeight.w400),))
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }
}
