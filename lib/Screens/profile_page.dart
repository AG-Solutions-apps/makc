import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Model/family_member_model.dart';
import 'package:makc/Model/profile_model.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/const_helper.dart';
import 'package:makc/Utils/loader.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Controller controller = Get.put(Controller());
  GlobalKey<FormState> familyKey = GlobalKey();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.getLoginToken();
    ApiHelper.apiHelper.fetchProfile(token: controller.isLoginToken.value).then((value) {
      // print("DDDDDD ${value["data"]}");
      controller.profileData.value = ProfileModel.fromJson(value["data"]);
      // print("PPPPPPPPP ${controller.profileData.value.name}");
      ApiHelper.apiHelper.fetchFamilyMember(token: controller.isLoginToken.value).then((family) {
        print("FFFFFF ${family["data"]}");
        List filterList = family["data"];
        controller.familyMemberList.value = filterList.map((e) => FamilyMemberDataModel.fromJson(e),).toList();
        print("FFFFFF ${controller.familyMemberList.length}");
      },);
    },);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Obx(
            () =>  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Profile",style: TextStyle(color: Colors.black,fontSize: 24,fontWeight: FontWeight.w500),),
                SizedBox(height: Get.width/30,),
                Row(
                  children: [
                    SvgPicture.asset("assets/profile/profile.svg",fit: BoxFit.cover,height: Get.width/15,width: Get.width/15,),
                    SizedBox(width: Get.width/30,),
                    Text(controller.profileData.value.name??"Name",style: TextStyle(color: Color(0xff373839),fontSize: 16,fontWeight: FontWeight.w400),)
                  ],
                ),
                SizedBox(height: Get.width/20,),
                Row(
                  children: [
                    SvgPicture.asset("assets/profile/call.svg",fit: BoxFit.cover,height: Get.width/15,width: Get.width/15,),
                    SizedBox(width: Get.width/30,),
                    Text(controller.profileData.value.mobile??"**********",style: TextStyle(color: Color(0xff373839),fontSize: 16,fontWeight: FontWeight.w400),)
                  ],
                ),
                SizedBox(height: Get.width/20,),
                Row(
                  children: [
                    SvgPicture.asset("assets/profile/email.svg",fit: BoxFit.cover,height: Get.width/15,width: Get.width/15,),
                    SizedBox(width: Get.width/30,),
                    Text(controller.profileData.value.email??"abc@gmail.com",style: TextStyle(color: Color(0xff373839),fontSize: 16,fontWeight: FontWeight.w400),)
                  ],
                ),
                SizedBox(height: Get.width/20,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset("assets/profile/area.svg",fit: BoxFit.cover,height: Get.width/15,width: Get.width/15,),
                    SizedBox(width: Get.width/30,),
                    Flexible(child: Text(controller.profileData.value.area??"--",style: TextStyle(color: Color(0xff373839),fontSize: 16,fontWeight: FontWeight.w400),))
                  ],
                ),
                SizedBox(height: Get.width/10,),
                Row(
                  children: [
                    Text("Family Members",style: TextStyle(color: Color(0xff000000),fontSize: 16,fontWeight: FontWeight.w400),),
                    Spacer(),
                    TextButton(onPressed: () {
                      controller.txtFullName.clear();
                      controller.txtEmail.clear();
                      controller.txtMobile.clear();
                      controller.txtRelation.clear();
                      showDialog(
                        barrierDismissible: false,
                        context: ConstHelper.navigatorKey.currentContext!, builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(25),
                            child: SingleChildScrollView(
                              child: Form(
                                key: familyKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Add Your Family Member",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 16),),
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
                                    Text("Full Name",style: TextStyle(color: Color(0xff4D4D4D),fontSize: 14,fontWeight: FontWeight.w400),),
                                    SizedBox(height: Get.width/80,),
                                    TextFormField(
                                      controller: controller.txtFullName,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          borderSide: BorderSide(color: Color(0xff141414))
                                        ),
                                        hintText: "Enter Your Name",
                                        hintStyle: TextStyle(color: Color(0xff909090),fontWeight: FontWeight.w400),
                                        contentPadding: EdgeInsets.symmetric(horizontal: Get.width/30),
                                      ),
                                      validator: (value) {
                                        if(value!.isEmpty)
                                        {
                                          return "Please enter the full name";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Get.width/50,),
                                    Text("Mobile",style: TextStyle(color: Color(0xff4D4D4D),fontSize: 14,fontWeight: FontWeight.w400),),
                                    SizedBox(height: Get.width/80,),
                                    TextFormField(
                                      controller: controller.txtMobile,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(color: Color(0xff141414))
                                        ),
                                        hintText: "Enter Your Mobile Number",
                                        hintStyle: TextStyle(color: Color(0xff909090),fontWeight: FontWeight.w400),
                                        contentPadding: EdgeInsets.symmetric(horizontal: Get.width/30),
                                      ),
                                      validator: (value) {
                                        if(value!.isEmpty)
                                        {
                                          return "Please enter the mobile";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Get.width/50,),
                                    Text("Email",style: TextStyle(color: Color(0xff4D4D4D),fontSize: 14,fontWeight: FontWeight.w400),),
                                    SizedBox(height: Get.width/80,),
                                    TextFormField(
                                      controller: controller.txtEmail,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(color: Color(0xff141414))
                                        ),
                                        hintText: "Enter Your Email ID",
                                        hintStyle: TextStyle(color: Color(0xff909090),fontWeight: FontWeight.w400),
                                        contentPadding: EdgeInsets.symmetric(horizontal: Get.width/30),
                                      ),
                                      validator: (value) {
                                        if(value!.isEmpty)
                                        {
                                          return "Please enter the email";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Get.width/50,),
                                    Text("Relation",style: TextStyle(color: Color(0xff4D4D4D),fontSize: 14,fontWeight: FontWeight.w400),),
                                    SizedBox(height: Get.width/80,),
                                    TextFormField(
                                      controller: controller.txtRelation,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(5),
                                            borderSide: BorderSide(color: Color(0xff141414))
                                        ),
                                        hintText: "Enter Your Relation",
                                        hintStyle: TextStyle(color: Color(0xff909090),fontWeight: FontWeight.w400),
                                        contentPadding: EdgeInsets.symmetric(horizontal: Get.width/30),
                                      ),
                                      validator: (value) {
                                        if(value!.isEmpty)
                                          {
                                            return "Please enter the relation";
                                          }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: Get.width/20,),
                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        if(familyKey.currentState!.validate())
                                          {
                                            Get.back();
                                            Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Please wait...");
                                            ApiHelper.apiHelper.insertFamilyMember(
                                                token: controller.isLoginToken.value,
                                                fullName: controller.txtFullName.text,
                                                email: controller.txtEmail.text,
                                                mobile: controller.txtMobile.text,
                                                whatsapp: controller.txtMobile.text,
                                                area: controller.profileData.value.area??"",
                                                description: controller.profileData.value.description??"",
                                                relation: controller.txtRelation.text).then((value) {
                                                  if(value["code"] == 200)
                                                    {
                                                      Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                                      controller.getFamilyMembers();
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
                    }, child: Text("+Add",style: TextStyle(color: Color(0xff1563FA)),))
                  ],
                ),
                SizedBox(height: Get.width/50,),
                Container(
                  color: Colors.white,
                  height: Get.width/0.92,
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(
                          () =>  controller.familyMemberList.isNotEmpty?ListView.builder(
                            itemCount: controller.familyMemberList.length,
                            itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadiusGeometry.circular(10),
                                    border: Border.all(color: Colors.grey.shade400)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(controller.familyMemberList[index].name??"",style: TextStyle(color: Color(0xff373839),fontSize: 16,fontWeight: FontWeight.w400),),
                                              Text(controller.familyMemberList[index].mobile??"",style: TextStyle(color: Color(0xff75777B),fontSize: 14,fontWeight: FontWeight.w400),),
                                            ],
                                          )),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Active",
                                              style: TextStyle(
                                                color: Color(0xff2D3290),
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Text("Delete"),
                                                      content: Text("Are you sure you want to delete this member?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context); // close dialog
                                                          },
                                                          child: Text("Cancel",style: TextStyle(color: Color(0xff2D3290),fontSize: 14,fontWeight: FontWeight.w400),),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Get.back();
                                                            Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Please wait...");
                                                            ApiHelper.apiHelper.removeFamilyMember(token: controller.isLoginToken.value, memberID: "${controller.familyMemberList[index].id}").then((remove) {
                                                              if(remove["code"] == 200)
                                                                {
                                                                  Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                                                  controller.getFamilyMembers();
                                                                  ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(remove["message"],style: TextStyle(color: Colors.white),),backgroundColor: Colors.green,duration: Duration(seconds: 2),));
                                                                }
                                                              else
                                                                {
                                                                  Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                                                  ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(SnackBar(content: Text(remove["message"],style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,duration: Duration(seconds: 2),));
                                                                }
                                                            },);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                          ),
                                                          child: Text("Delete",style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.w400),),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: SvgPicture.asset("assets/profile/close.svg"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },):Center(child: Text("No member available!",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color: Colors.grey.shade400),)),
                        ),
                      ),
                      SizedBox(height: Get.width/50,),
                    ],
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    ));
  }
}
