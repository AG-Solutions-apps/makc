import 'package:dio/dio.dart';
import 'package:makc/Utils/api_const.dart';

class ApiHelper{
  ApiHelper._();
  static ApiHelper apiHelper = ApiHelper._();
  final dio = Dio();

  Future getLogin({required String mobile,required String password,required String deviceID})
  async{
    try{
      var data = FormData.fromMap({
        "mobile":mobile,
        "password":password,
        "device_id":deviceID
      });

      print("AAAAAAAA ${ApiConst.login}");

      Response response = await dio.post(ApiConst.login,data: data);
      if(response.statusCode == 200)
        {
          print("SSSSSSSSSS ${response.data["code"]}");
          return {
            "code":response.data["code"],
            "message":response.data["message"],
            "data":response.data["data"],
            "company":response.data["company_detils"],
            "image_url":response.data["image_url"],
          };
        }
    }
    catch(error)
    {
      print("EEEEEEEEE $error");
    }
  }

  Future fetchServiceBanner({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchServiceBanner,options: Options(
        headers: headers
      ));

      if(response.statusCode == 200)
        {
          return {
            "code":response.statusCode,
            "data":response.data["data"],
            "image_url":response.data["image_url"]
          };
        }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future fetchProfile({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchProfile,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"]
        };
      }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future insertComplaint({required String token,required String complaintSubject,required String complaintDescription})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      var data = FormData.fromMap({
        "complaint_subject":complaintSubject,
        "complaint_description":complaintDescription
      });

      Response response =await dio.post(ApiConst.addComplaint,data: data,options: Options(
        headers: headers
      ));

      if(response.statusCode == 200)
        {
          return {
            "code":response.data["code"],
            "message":response.data["message"]
          };
        }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future fetchComplaint({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchComplaint,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"],
        };
      }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future fetchFamilyMember({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchFamilyMember,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"],
        };
      }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future removeFamilyMember({required String token,required memberID})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.put("${ApiConst.removeMember}$memberID",options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.data["code"],
          "message":response.data["message"],
        };
      }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future insertFamilyMember({required String token,required String fullName,required String email,required String mobile,required String whatsapp,required String area,required String description,required String relation})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      var data = FormData.fromMap({
        "name":fullName,
        "email":email,
        "mobile":mobile,
        "whatsapp":whatsapp,
        "area":area,
        "description":description,
        "relation":relation,
      });

      Response response =await dio.post(ApiConst.addFamilyMember,data: data,options: Options(
        headers: headers
      ));

      if(response.statusCode == 200)
        {
          return {
            "code":response.data["code"],
            "message":response.data["message"]
          };
        }

    }catch(error)
    {
      print("EEEEEEEE $error");
    }
  }

  Future fetchService({required String token})
  async{
    try{
      var  headers = {
        "Authorization": "Bearer $token"
      };

      Response response =await dio.get(ApiConst.fetchService,options: Options(
          headers: headers
      ));

      if(response.statusCode == 200)
      {
        return {
          "code":response.statusCode,
          "data":response.data["data"],
          "image_url":response.data["image_url"],
        };
      }

    }
    catch(error)
    {
      print("EEEEEEE $error");
    }
  }

  Future getPackageName({required String url}) async {
    Response response = await dio.get(url);

    if (response.statusCode == 200) {
      String html = response.data.toString();

      // Basic regex to find package name
      RegExp regExp = RegExp(r'id=([a-zA-Z0-9._]+)');
      var match = regExp.firstMatch(html);

      if (match != null) {
        print("Package: ${match.group(1)}");
      }
    }
  }


}