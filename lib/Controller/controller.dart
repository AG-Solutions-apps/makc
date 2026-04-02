import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:makc/Model/banner_model.dart';
import 'package:makc/Model/company_model.dart';
import 'package:makc/Model/complaint_model.dart';
import 'package:makc/Model/family_member_model.dart';
import 'package:makc/Model/profile_model.dart';
import 'package:makc/Model/service_,odel.dart';
import 'package:makc/Utils/shared_pref.dart';

import '../Utils/api_helper.dart';

class Controller extends GetxController{

  RxBool isLogin = false.obs;
  RxString isLoginToken = "".obs;
  RxString noImagePath = "".obs;
  RxString imagePath = "".obs;
  RxList<BannerDataModel> bannerList = <BannerDataModel>[].obs;
  Rx<ProfileModel> profileData = ProfileModel().obs;

  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtMobile = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtRelation = TextEditingController();

  TextEditingController txtComplaintSubject = TextEditingController();
  TextEditingController txtComplaintDescription = TextEditingController();
  RxList<ComplaintDataModel> complaintList = <ComplaintDataModel>[].obs;

  RxList<FamilyMemberDataModel> familyMemberList = <FamilyMemberDataModel>[].obs;

  RxList<ServiceDataModel> serviceList = <ServiceDataModel>[].obs;
  RxString serviceImagePath = "".obs;
  RxString serviceNOImagePath = "".obs;
  Rx<CompanyDataModel> companyData = CompanyDataModel().obs;
  RxString noCompanyImage = "".obs;
  RxString companyImage = "".obs;
  RxBool imageLoader = false.obs;

  Future<bool> getLogin()
  async{
    isLogin.value =await SharedPref.isLoggedIn()??false;
    return isLogin.value;
  }

  Future<String> getLoginToken()
  async{
    isLoginToken.value =await SharedPref.isLoggedToken()??"";
    print("KKKKKKKKKK ${isLoginToken.value}");
    return isLoginToken.value;
  }

  Future getComplaint()
  async{
    ApiHelper.apiHelper.fetchComplaint(token: isLoginToken.value).then((complaint) {
      List filterList = complaint["data"];
      complaintList.value = filterList.map((e) => ComplaintDataModel.fromJson(e),).toList();
    },);
  }

  Future getFamilyMembers()
  async{
    ApiHelper.apiHelper.fetchFamilyMember(token: isLoginToken.value).then((family) {
      List filterList = family["data"];
      familyMemberList.value = filterList.map((e) => FamilyMemberDataModel.fromJson(e),).toList();
    },);
  }

  Future getCompanyData()
  async{
    companyData.value =await SharedPref.getCompanyData()??CompanyDataModel();
  }

  Future getCompanyImage()
  async{
    noCompanyImage.value =await SharedPref.getNoImagePath()??"";
    companyImage.value =await SharedPref.getImagePath()??"";
    imageLoader.value = true;
  }





}