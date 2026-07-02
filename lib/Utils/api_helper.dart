import 'package:dio/dio.dart';
import 'package:makc/Utils/api_const.dart';

class ApiHelper {
  ApiHelper._();
  static ApiHelper apiHelper = ApiHelper._();
  final dio = Dio();

  Future getLogin({
    required String mobile,
    required String password,
    required String deviceID
  }) async {
    try {
      var data = FormData.fromMap({
        "mobile": mobile,
        "password": password,
        "device_id": deviceID
      });

      print("Login URL: ${ApiConst.login}");
      print("Login Data: mobile=$mobile, password=$password, deviceID=$deviceID");

      Response response = await dio.post(ApiConst.login, data: data);
      
      print("Login Response Status: ${response.statusCode}");
      print("Login Response Data: ${response.data}");
      
      if (response.statusCode == 200) {
        // Make sure response.data is a Map
        if (response.data is Map) {
          return {
            "code": response.data["code"] ?? 200,
            "message": response.data["message"] ?? "Success",
            "data": response.data["data"] ?? "",
            "company": response.data["company_detils"] ?? response.data["company"] ?? "",
            "image_url": response.data["image_url"] ?? "",
          };
        } else {
          return {
            "code": 200,
            "message": "Success",
            "data": response.data,
            "company": "",
            "image_url": "",
          };
        }
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Server returned ${response.statusCode}",
          "data": "",
          "company": "",
          "image_url": "",
        };
      }
    } catch (error) {
      print("Login Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
        "data": "",
        "company": "",
        "image_url": "",
      };
    }
  }

  Future checkMobile({required String mobile}) async {
    try {
      var data = FormData.fromMap({
        "mobile": mobile,
      });

      print("CheckMobile URL: ${ApiConst.checkMobile}");
      print("CheckMobile Data: mobile=$mobile");

      Response response = await dio.post(ApiConst.checkMobile, data: data);
      
      print("CheckMobile Response Status: ${response.statusCode}");
      print("CheckMobile Response Data: ${response.data}");
      
      if (response.statusCode == 200) {
        if (response.data is Map) {
          return {
            "code": response.data["code"] ?? 200,
            "message": response.data["message"] ?? "Success",
            "data": response.data["data"] ?? "",
            "company": response.data["company"] ?? response.data["company_detils"] ?? "",
            "image_url": response.data["image_url"] ?? "",
          };
        } else {
          return {
            "code": 200,
            "message": "Success",
            "data": response.data,
            "company": "",
            "image_url": "",
          };
        }
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Server returned ${response.statusCode}",
          "data": "",
          "company": "",
          "image_url": "",
        };
      }
    } on DioException catch (dioError) {
      print("CheckMobile DioError: ${dioError.message}");
      if (dioError.response != null) {
        try {
          if (dioError.response!.data is Map) {
            return {
              "code": dioError.response!.data["code"] ?? dioError.response!.statusCode ?? 400,
              "message": dioError.response!.data["message"] ?? "Error occurred",
              "data": "",
              "company": "",
              "image_url": "",
            };
          } else {
            return {
              "code": dioError.response!.statusCode ?? 400,
              "message": "Server error: ${dioError.response!.statusCode}",
              "data": "",
              "company": "",
              "image_url": "",
            };
          }
        } catch (e) {
          return {
            "code": dioError.response!.statusCode ?? 400,
            "message": "Server error occurred",
            "data": "",
            "company": "",
            "image_url": "",
          };
        }
      }
      return {
        "code": 500,
        "message": dioError.message ?? "Connection timeout",
        "data": "",
        "company": "",
        "image_url": "",
      };
    } catch (error) {
      print("CheckMobile Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
        "data": "",
        "company": "",
        "image_url": "",
      };
    }
  }

  Future signUp({
    required String name,
    required String email,
    required String mobile,
  }) async {
    try {
      var data = FormData.fromMap({
        "r_id": "",
        "name": name,
        "email": email,
        "mobile": mobile,
        "whatsapp": "",
        "area": "",
        "description": "",
        "relation": "",
        "services": "",
        "hide_services": "",
        "password": "",
      });

      print("SignUp URL: ${ApiConst.signup}");
      print("SignUp Data: name=$name, email=$email, mobile=$mobile");

      Response response = await dio.post(ApiConst.signup, data: data);
      
      print("SignUp Response Status: ${response.statusCode}");
      print("SignUp Response Data: ${response.data}");
      
      // Handle all status codes properly
      if (response.data is Map) {
        return {
          "code": response.data["code"] ?? response.statusCode ?? 200,
          "message": response.data["message"] ?? "Success",
        };
      } else {
        // If response.data is not a Map (like a String error message)
        return {
          "code": response.statusCode ?? 500,
          "message": response.data?.toString() ?? "Unknown response format",
        };
      }
    } on DioException catch (dioError) {
      print("SignUp DioError: ${dioError.message}");
      
      // Handle Dio errors properly
      if (dioError.response != null) {
        try {
          if (dioError.response!.data is Map) {
            return {
              "code": dioError.response!.data["code"] ?? dioError.response!.statusCode ?? 400,
              "message": dioError.response!.data["message"] ?? "Signup failed",
            };
          } else {
            // If response data is a String (error message)
            return {
              "code": dioError.response!.statusCode ?? 400,
              "message": dioError.response!.data?.toString() ?? "Server error occurred",
            };
          }
        } catch (e) {
          return {
            "code": dioError.response!.statusCode ?? 400,
            "message": "Server error occurred",
          };
        }
      }
      return {
        "code": 500,
        "message": dioError.message ?? "Connection timeout",
      };
    } catch (error) {
      print("Signup Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
      };
    }
  }

  Future fetchServiceBanner({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.fetchServiceBanner,
        options: Options(headers: headers)
      );

      print("fetchServiceBanner Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? [],
          "image_url": response.data["image_url"] ?? "",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": [],
          "image_url": "",
        };
      }
    } catch (error) {
      print("fetchServiceBanner Error: $error");
      return {
        "code": 500,
        "data": [],
        "image_url": "",
      };
    }
  }

  Future fetchProfile({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.fetchProfile,
        options: Options(headers: headers)
      );

      print("fetchProfile Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? {},
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": {},
        };
      }
    } catch (error) {
      print("fetchProfile Error: $error");
      return {
        "code": 500,
        "data": {},
      };
    }
  }

  Future insertComplaint({
    required String token,
    required String complaintSubject,
    required String complaintDescription
  }) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      var data = FormData.fromMap({
        "complaint_subject": complaintSubject,
        "complaint_description": complaintDescription
      });

      Response response = await dio.post(
        ApiConst.addComplaint,
        data: data,
        options: Options(headers: headers)
      );

      print("insertComplaint Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.data["code"] ?? 200,
          "message": response.data["message"] ?? "Complaint submitted successfully",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Failed to submit complaint",
        };
      }
    } catch (error) {
      print("insertComplaint Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
      };
    }
  }

  Future fetchComplaint({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.fetchComplaint,
        options: Options(headers: headers)
      );

      print("fetchComplaint Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? [],
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": [],
        };
      }
    } catch (error) {
      print("fetchComplaint Error: $error");
      return {
        "code": 500,
        "data": [],
      };
    }
  }

  Future fetchFamilyMember({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.fetchFamilyMember,
        options: Options(headers: headers)
      );

      print("fetchFamilyMember Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? [],
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": [],
        };
      }
    } catch (error) {
      print("fetchFamilyMember Error: $error");
      return {
        "code": 500,
        "data": [],
      };
    }
  }

  Future removeFamilyMember({required String token, required memberID}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.put(
        "${ApiConst.removeMember}$memberID",
        options: Options(headers: headers)
      );

      print("removeFamilyMember Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.data["code"] ?? 200,
          "message": response.data["message"] ?? "Member removed successfully",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Failed to remove member",
        };
      }
    } catch (error) {
      print("removeFamilyMember Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
      };
    }
  }

  Future insertFamilyMember({
    required String token,
    required String fullName,
    required String email,
    required String mobile,
    required String whatsapp,
    required String area,
    required String description,
    required String relation
  }) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      var data = FormData.fromMap({
        "name": fullName,
        "email": email,
        "mobile": mobile,
        "whatsapp": whatsapp,
        "area": area,
        "description": description,
        "relation": relation,
      });

      Response response = await dio.post(
        ApiConst.addFamilyMember,
        data: data,
        options: Options(headers: headers)
      );

      print("insertFamilyMember Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.data["code"] ?? 200,
          "message": response.data["message"] ?? "Family member added successfully",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Failed to add family member",
        };
      }
    } catch (error) {
      print("insertFamilyMember Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
      };
    }
  }

  Future fetchService({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.fetchService,
        options: Options(headers: headers)
      );

      print("fetchService Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? [],
          "image_url": response.data["image_url"] ?? "",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": [],
          "image_url": "",
        };
      }
    } catch (error) {
      print("fetchService Error: $error");
      return {
        "code": 500,
        "data": [],
        "image_url": "",
      };
    }
  }

  Future getPackageName({required String url}) async {
    try {
      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        String html = response.data.toString();
        RegExp regExp = RegExp(r'id=([a-zA-Z0-9._]+)');
        var match = regExp.firstMatch(html);

        if (match != null) {
          print("Package: ${match.group(1)}");
          return match.group(1);
        }
      }
    } catch (e) {
      print("getPackageName Error: $e");
    }
    return null;
  }

  Future fetchActiveServicesForRequest({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.activeServicesForRequest,
        options: Options(headers: headers),
      );

      print("fetchActiveServicesForRequest Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? [],
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": [],
        };
      }
    } catch (error) {
      print("fetchActiveServicesForRequest Error: $error");
      return {
        "code": 500,
        "data": [],
      };
    }
  }

  Future fetchServiceRequestList({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      Response response = await dio.get(
        ApiConst.fetchServiceRequestList,
        options: Options(headers: headers),
      );

      print("fetchServiceRequestList Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.statusCode,
          "data": response.data["data"] ?? [],
          "image_url": response.data["image_url"] ?? "",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "data": [],
          "image_url": "",
        };
      }
    } catch (error) {
      print("fetchServiceRequestList Error: $error");
      return {
        "code": 500,
        "data": [],
        "image_url": "",
      };
    }
  }

  Future addServiceRequest({
    required String token,
    required String serviceIds
  }) async {
    try {
      var headers = {
        "Authorization": "Bearer $token"
      };

      var data = FormData.fromMap({
        "service_id": serviceIds,
      });

      Response response = await dio.post(
        ApiConst.addServiceRequest,
        data: data,
        options: Options(headers: headers),
      );

      print("addServiceRequest Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.data["code"] ?? 200,
          "message": response.data["message"] ?? "Service request added successfully",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Failed to add service request",
        };
      }
    } catch (error) {
      print("addServiceRequest Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
      };
    }
  }

  Future appLogout({required String token}) async {
    try {
      var headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      };

      Response response = await dio.post(
        "https://agsdemo.in/macapi/public/api/app-logout",
        options: Options(headers: headers),
      );

      print("appLogout Response: ${response.data}");

      if (response.statusCode == 200 && response.data is Map) {
        return {
          "code": response.data["code"] ?? 200,
          "message": response.data["message"] ?? "Logged out successfully",
        };
      } else {
        return {
          "code": response.statusCode ?? 500,
          "message": "Failed to logout",
        };
      }
    } catch (error) {
      print("Logout Error: $error");
      return {
        "code": 500,
        "message": error.toString(),
      };
    }
  }
}