import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Model/complaint_model.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/loader.dart';

import '../Utils/const_helper.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  Controller controller = Get.put(Controller());
  GlobalKey<FormState> complaintKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getLoginToken().then((value) {
      ApiHelper.apiHelper.fetchComplaint(token: controller.isLoginToken.value).then((complaint) {
        List filterList = complaint["data"];
        controller.complaintList.value = filterList.map((e) => ComplaintDataModel.fromJson(e),).toList();
      },);
    },);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Complaint",style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.w500),),
            SizedBox(height: Get.width/40,),
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  controller.txtComplaintSubject.clear();
                  controller.txtComplaintDescription.clear();
                  showDialog(
                    barrierDismissible: false,
                    context: ConstHelper.navigatorKey.currentContext!, builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Form(
                            key: complaintKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Text("Add Complaint",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),),
                                    Spacer(),
                                    InkWell(
                                        onTap: () {
                                          Get.back();
                                        },
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: SvgPicture.asset("assets/profile/close2.svg",height: Get.width/18,width: Get.width/18,fit: BoxFit.cover))
                                  ],
                                ),
                                SizedBox(height: Get.width/50,),
                                Text("Complaint Subject",style: TextStyle(color: Color(0xff4D4D4D),fontSize: 14,fontWeight: FontWeight.w400),),
                                SizedBox(height: Get.width/80,),
                                TextFormField(
                                  controller: controller.txtComplaintSubject,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Color(0xff141414))
                                    ),
                                    hintText: "Enter The Complaint Subject",
                                    hintStyle: TextStyle(color: Color(0xff909090),fontWeight: FontWeight.w400),
                                    contentPadding: EdgeInsets.symmetric(horizontal: Get.width/30),
                                  ),
                                  validator: (value) {
                                    if(value!.isEmpty)
                                    {
                                      return "Please enter the complaint subject";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.width/50,),
                                Text("Complaint Description",style: TextStyle(color: Color(0xff4D4D4D),fontSize: 14,fontWeight: FontWeight.w400),),
                                SizedBox(height: Get.width/80,),
                                TextFormField(
                                  controller: controller.txtComplaintDescription,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(color: Color(0xff141414))
                                    ),
                                    hintText: "Enter The Complaint Description",
                                    hintStyle: TextStyle(color: Color(0xff909090),fontWeight: FontWeight.w400),
                                    contentPadding: EdgeInsets.symmetric(horizontal: Get.width/30),
                                  ),
                                  validator: (value) {
                                    if(value!.isEmpty)
                                    {
                                      return "Please enter the complaint description";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Get.width/20,),
                                InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if(complaintKey.currentState!.validate())
                                    {
                                      Get.back();
                                      Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Please wait...");
                                      ApiHelper.apiHelper.insertComplaint(
                                          token: controller.isLoginToken.value,
                                          complaintSubject: controller.txtComplaintSubject.text,
                                          complaintDescription: controller.txtComplaintDescription.text).then((value) {
                                        if(value["code"] == 200)
                                        {
                                          Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                          controller.getComplaint();
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
                                        color: Color(0xff2D3290),
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Center(child: Text("Submit",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 14),)),
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
                  },);
                },
                child: Container(
                  width: Get.width/3,
                  decoration: BoxDecoration(
                      color: Color(0xff2D3290),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: Text("+ Add Complaint",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 14),)),
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.width/20,),
            Expanded(
              child: Obx(
                () =>  ListView.builder(
                  itemCount: controller.complaintList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.shade300,blurRadius: 2,spreadRadius: 1)
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(controller.complaintList[index].complaintSubject??"",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),),
                                  Text(controller.complaintList[index].complaintStatus??"",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.amberAccent),)
                                ],
                              ),
                              Text(controller.complaintList[index].complaintDescription??"",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),),
                            ],
                          ),
                        ),
                      ),
                    );
                  },),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
