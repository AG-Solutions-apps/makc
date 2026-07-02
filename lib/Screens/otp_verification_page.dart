import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makc/Model/company_model.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/loader.dart';
import 'package:makc/Utils/shared_pref.dart';
import 'bottom_page.dart';
import 'package:uuid/uuid.dart';

Future<String> getOrCreateDeviceId() async {
  String? deviceId = await SharedPref.getDeviceId();

  if (deviceId == null || deviceId.isEmpty) {
    deviceId = const Uuid().v4();
    await SharedPref.saveDeviceId(deviceId);
  }

  return deviceId;
}

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String mobile;
  final bool isSignup;
  final String signupName;
  final String signupEmail;
  final String loginPassword;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.mobile,
    required this.isSignup,
    this.signupName = "",
    this.signupEmail = "",
    this.loginPassword = "",
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _txtOtp = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  
  late String _currentVerificationId;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _currentVerificationId = widget.verificationId;

    print("================================");
    print("OTP SCREEN OPENED");
    print("VerificationId: ${widget.verificationId}");
    print("CurrentVerificationId: $_currentVerificationId");
    print("Mobile: ${widget.mobile}");
    print("Is Signup: ${widget.isSignup}");
    print("================================");

    _txtOtp.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _canResend = true;
            _timer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _txtOtp.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    
    setState(() => _isLoading = true);

    String formattedMobile = widget.mobile.trim();
    if (!formattedMobile.startsWith("+")) formattedMobile = "+91$formattedMobile";

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedMobile,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Resend failed. Try again."), backgroundColor: Colors.red));
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _currentVerificationId = verificationId;
            _isLoading = false;
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP has been resent successfully."), backgroundColor: Colors.green));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _verifyAndProceed() async {
    if (!_formKey.currentState!.validate()) {
      if (_txtOtp.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter all 6 digits of the OTP."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    Loader.showLoader(context, "Verifying OTP...");

    try {
      print("================================");
      print("VERIFY BUTTON CLICKED");
      print("VerificationId: $_currentVerificationId");
      print("Entered OTP: ${_txtOtp.text.trim()}");
      print("================================");

      final credential = PhoneAuthProvider.credential(
        verificationId: _currentVerificationId,
        smsCode: _txtOtp.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      print("OTP VERIFIED SUCCESSFULLY");

      if (widget.isSignup) {
        await _handleSignupFlow();
      } else {
        await _handleLoginFlow(widget.loginPassword);
      }
    } on FirebaseAuthException catch (e) {
      print("================================");
      print("FIREBASE OTP ERROR");
      print("Code: ${e.code}");
      print("Message: ${e.message}");
      print("VerificationId: $_currentVerificationId");
      print("OTP: ${_txtOtp.text.trim()}");
      print("================================");

      if (!mounted) return;

      Loader.hideLoader(context);
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Code: ${e.code}\n${e.message}",
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
        ),
      );
    } catch (e) {
      print("GENERAL ERROR: $e");

      if (!mounted) return;

      Loader.hideLoader(context);
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSignupFlow() async {
    try {
      print("=== SIGNUP FLOW START ===");

      final signupResponse = await ApiHelper.apiHelper.signUp(
        name: widget.signupName, 
        email: widget.signupEmail, 
        mobile: widget.mobile,
      );

      print("SignupResponse: $signupResponse");
      print("SignupResponse type: ${signupResponse.runtimeType}");

      if (signupResponse == null) {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup failed: no response"), backgroundColor: Colors.red));
        return;
      }

      // Check if it's a Map
      if (signupResponse is! Map) {
        print("ERROR: signupResponse is not a Map! Type: ${signupResponse.runtimeType}");
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid server response format"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final signupCode = signupResponse["code"];
      print("Signup code: $signupCode (type: ${signupCode.runtimeType})");

      if (signupCode == 200 || signupCode.toString() == "200") {
        print("Signup SUCCESS - fetching mobile check...");

        final checkMobileResponse = await ApiHelper.apiHelper.checkMobile(mobile: widget.mobile);
        print("CheckMobileResponse: $checkMobileResponse");

        if (checkMobileResponse == null) {
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not fetch login credentials."), backgroundColor: Colors.orange));
          return;
        }

        if (checkMobileResponse is! Map) {
          print("ERROR: checkMobileResponse is not a Map!");
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid server response format"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final checkCode = checkMobileResponse["code"];
        print("CheckMobile code: $checkCode (type: ${checkCode.runtimeType})");

        if (checkCode == 200 || checkCode.toString() == "200") {
          final rawData = checkMobileResponse["data"];
          final String autoPassword = rawData?.toString() ?? "";
          print("AutoPassword: $autoPassword");

          await _handleLoginFlow(autoPassword);
        } else {
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(checkMobileResponse["message"]?.toString() ?? "Failed to fetch credentials."),
              backgroundColor: Colors.orange
            )
          );
        }
      } else {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(signupResponse["message"]?.toString() ?? "Registration failed."),
            backgroundColor: Colors.red
          )
        );
      }
    } catch (e, stackTrace) {
      print("=== SIGNUP FLOW ERROR ===");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      if (!mounted) return;
      Loader.hideLoader(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLoginFlow(String password) async {
    try {
      print("=== LOGIN FLOW START ===");
      print("Mobile: ${widget.mobile}, Password: $password");

      String deviceId = await getOrCreateDeviceId();
      print("DeviceId: $deviceId");

      final loginResponse = await ApiHelper.apiHelper.getLogin(
        mobile: widget.mobile,
        password: password,
        deviceID: deviceId,
      );

      print("LoginResponse: $loginResponse");
      print("LoginResponse type: ${loginResponse.runtimeType}");

      if (!mounted) return;
      Loader.hideLoader(context);
      setState(() => _isLoading = false);

      if (loginResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login failed: no response"), backgroundColor: Colors.red));
        return;
      }

      if (loginResponse is! Map) {
        print("ERROR: loginResponse is not a Map!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid server response format"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final loginCode = loginResponse["code"];
      print("Login code: $loginCode (type: ${loginCode.runtimeType})");

      if (loginCode == 200 || loginCode.toString() == "200") {
        // SAFELY HANDLE companyImageList
        dynamic imageData = loginResponse["image_url"];
        List companyImageList = [];
        
        if (imageData is List) {
          companyImageList = imageData;
        } else if (imageData != null) {
          companyImageList = [imageData];
        }
        
        print("CompanyImageList: $companyImageList");
        print("CompanyImageList type: ${companyImageList.runtimeType}");

        // Safely build CompanyDataModel
        final companyRaw = loginResponse["company"];
        print("Company raw: $companyRaw (type: ${companyRaw.runtimeType})");
        
        CompanyDataModel company;
        try {
          if (companyRaw is Map<String, dynamic>) {
            company = CompanyDataModel.fromJson(companyRaw);
          } else if (companyRaw is Map) {
            company = CompanyDataModel.fromJson(Map<String, dynamic>.from(companyRaw));
          } else if (companyRaw is List && companyRaw.isNotEmpty) {
            company = CompanyDataModel.fromJson(Map<String, dynamic>.from(companyRaw[0]));
          } else {
            company = CompanyDataModel();
          }
        } catch (e) {
          print("Error parsing company: $e");
          company = CompanyDataModel();
        }

        // Safely extract token
        String token = "";
        dynamic dataField = loginResponse["data"];
        print("Data field: $dataField (type: ${dataField.runtimeType})");
        
        try {
          if (dataField is Map) {
            token = dataField["token"]?.toString() ?? "";
          } else if (dataField is List && dataField.isNotEmpty) {
            final first = dataField[0];
            if (first is Map) {
              token = first["token"]?.toString() ?? "";
            } else {
              token = first?.toString() ?? "";
            }
          } else if (dataField is String) {
            token = dataField;
          }
        } catch (e) {
          print("Error extracting token: $e");
          token = "";
        }

        print("Final token: $token");

        await SharedPref.saveCompanyData(company);
        
        // SAFELY SAVE IMAGE PATHS - FIXED
        try {
          if (companyImageList.isNotEmpty) {
            var firstImage = companyImageList[0];
            if (firstImage is Map) {
              // If it's a Map, get the image_url
              await SharedPref.saveImagePath(firstImage["image_url"]?.toString() ?? "");
            } else if (firstImage is String) {
              // If it's directly a string URL
              await SharedPref.saveImagePath(firstImage);
            } else {
              print("First image is neither Map nor String: ${firstImage.runtimeType}");
            }
          }
          
          if (companyImageList.length > 1) {
            var secondImage = companyImageList[1];
            if (secondImage is Map) {
              await SharedPref.saveNoImagePath(secondImage["image_url"]?.toString() ?? "");
            } else if (secondImage is String) {
              await SharedPref.saveNoImagePath(secondImage);
            } else {
              print("Second image is neither Map nor String: ${secondImage.runtimeType}");
            }
          }
        } catch (e) {
          print("Error saving image paths: $e");
        }
        
        await SharedPref.saveLogin(true);
        await SharedPref.saveLoginToken(token);

        if (!mounted) return;
        Get.offAll(() => const BottomPage(), transition: Transition.fadeIn);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loginResponse["message"]?.toString() ?? "Logged in successfully",
              style: const TextStyle(color: Colors.white)
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResponse["message"]?.toString() ?? "Login failed."),
            backgroundColor: Colors.red
          )
        );
      }
    } catch (e, stackTrace) {
      print("=== LOGIN FLOW ERROR ===");
      print("Error: $e");
      print("StackTrace: $stackTrace");
      if (!mounted) return;
      Loader.hideLoader(context);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String otpText = _txtOtp.text;

    return Scaffold(
      backgroundColor: const Color(0xFF02040A), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF060B15), 
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1C3E8A).withOpacity(0.9), 
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C3E8A).withOpacity(0.55), 
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFF0056FF).withOpacity(0.3), 
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "OTP Verification",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "We have sent a verification code to your phone number +91 ${widget.mobile}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 40),

                    // 6-Square OTP Input UI WITH GLOW
                    SizedBox(
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              bool isFocused = _focusNode.hasFocus && (otpText.length == index || (otpText.length == 6 && index == 5));
                              
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                height: 55,
                                width: 45,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1522),
                                  border: Border.all(
                                    color: isFocused ? const Color(0xFF0056FF) : const Color(0xFF1E253A),
                                    width: isFocused ? 1.5 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isFocused 
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF0056FF).withOpacity(0.5),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          )
                                        ] 
                                      : [],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  index < otpText.length ? otpText[index] : "",
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              );
                            }),
                          ),
                          
                          TextFormField(
                            controller: _txtOtp,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.transparent, 
                            style: const TextStyle(color: Colors.transparent, fontSize: 1), 
                            autofocus: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) return ""; 
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _canResend ? "Didn't receive code? " : "Resend code in ${_secondsRemaining}s",
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                        if (_canResend)
                          GestureDetector(
                            onTap: _isLoading ? null : _resendOtp,
                            child: const Text("Resend OTP", style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0061FF), Color(0xFF0044CC)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Verify & Proceed", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            if (_isLoading) ...[
                              const SizedBox(width: 12),
                              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}