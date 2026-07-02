import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Model/family_member_model.dart';
import 'package:makc/Model/profile_model.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/const_helper.dart';
import 'package:makc/Utils/loader.dart';
import 'package:makc/Screens/login_page.dart';

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
    super.initState();
    controller.getLoginToken();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      var value = await ApiHelper.apiHelper.fetchProfile(
        token: controller.isLoginToken.value,
      );
      if (value != null && value["data"] != null) {
        controller.profileData.value = ProfileModel.fromJson(value["data"]);
        await controller.getFamilyMembers();
      }
    } catch (e) {
      print("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium Gradient App Bar
            SliverAppBar(
              expandedHeight: 77,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,

              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF020B24), // Midnight Navy
                      Color(0xFF0A2A7D), // Cobalt/Royal Blue
                      Color.fromARGB(255, 1, 111, 207), // Electric Neon Blue
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => controller.bottomIndex.value = 0,
                        ),

                        const Expanded(
                          child: Center(
                            child: Text(
                              "My Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 48, // balances the back button
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Obx(
                () => Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Card
                      _buildProfileHeader(),

                      const SizedBox(height: 28),

                      // Contact Information Title
                      const Text(
                        "Contact Information",
                        style: TextStyle(
                          color: Color(0xff1E2265),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Cards with Copy Feature
                      _buildContactInfoCard(
                        icon: "assets/profile/call.svg",
                        title: "Phone Number",
                        value:
                            controller.profileData.value.mobile ?? "**********",
                      ),

                      const SizedBox(height: 12),

                      _buildContactInfoCard(
                        icon: "assets/profile/email.svg",
                        title: "Email Address",
                        value:
                            controller.profileData.value.email ??
                            "abc@gmail.com",
                      ),

                      const SizedBox(height: 12),

                      _buildContactInfoCard(
                        icon: "assets/profile/area.svg",
                        title: "Area",
                        value:
                            controller.profileData.value.area ??
                            "Not Specified",
                      ),

                      if (controller.profileData.value.services != null &&
                          controller.profileData.value.services!.isNotEmpty &&
                          controller.profileData.value.services!.trim().toLowerCase() != "null") ...[
                        const SizedBox(height: 32),

                        // Family Members Section Header
                        Row(
                          children: [
                            const Text(
                              "Family Members",
                              style: TextStyle(
                                color: Color(0xff1E2265),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const Spacer(),
                            _buildAddButton(),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Family Members List
                        controller.familyMemberList.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.familyMemberList.length,
                                itemBuilder: (context, index) {
                                  return _buildFamilyMemberCard(index);
                                },
                              )
                            : _buildEmptyState(),
                      ],

                      const SizedBox(height: 30),

                      // Logout Button
                      _buildLogoutButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============== Build Methods ==============

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff2D3290).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xff2D3290).withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Profile Icon with Gradient Background
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xff2D3290),
                  Color(0xff4B4FC9),
                  Color(0xff6B6FDC),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff2D3290).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  "assets/profile/profile.svg",
                  colorFilter: const ColorFilter.mode(
                    Color(0xff2D3290),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            controller.profileData.value.name ?? "User Profile",
            style: const TextStyle(
              color: Color(0xff1E2265),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _showLogoutDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show Logout Dialog with proper navigation handling
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 10),
              const Text(
                "Logout",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E2265),
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout from your account?",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                // Close the dialog first
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }

                // Show loading indicator
                Loader.showLoader(
                  ConstHelper.navigatorKey.currentContext!,
                  "Logging out...",
                );

                try {
                  // Call logout API (fire-and-forget/safe call)
                  await ApiHelper.apiHelper.appLogout(
                    token: controller.isLoginToken.value,
                  );
                } catch (e) {
                  print("Logout API error: $e");
                } finally {
                  // Hide loader
                  Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);

                  // Perform complete local logout - clear all SharedPreferences data & controller state
                  await controller.performLogout();

                  // Redirect to Login Page and remove all previous routes
                  Get.offAll(() => const LoginPage());

                  // Show success snackbar
                  Get.snackbar(
                    "Success",
                    "Logged out successfully",
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Contact Information Card Widget
  Widget _buildContactInfoCard({
    required String icon,
    required String title,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        if (value.isNotEmpty &&
            value != "**********" &&
            value != "Not Specified") {
          Clipboard.setData(ClipboardData(text: value));
          Get.snackbar(
            "Copied",
            "$title copied to clipboard",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xff2D3290),
            colorText: Colors.white,
            borderRadius: 12,
            margin: const EdgeInsets.all(15),
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.copy_all, color: Colors.white),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff2D3290).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                icon,
                height: 20,
                width: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xff2D3290),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xff1E2265),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.copy_outlined, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // Add Family Member Button
  Widget _buildAddButton() {
    final String? services = controller.profileData.value.services;
    final bool hasNoServices = services == null || services.isEmpty || services.trim().toLowerCase() == "null";

    if (hasNoServices) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 6),
            Text(
              "Add Member",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        controller.txtFullName.clear();
        controller.txtEmail.clear();
        controller.txtMobile.clear();
        controller.txtRelation.clear();
        showDialog(
          barrierDismissible: false,
          context: ConstHelper.navigatorKey.currentContext!,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: familyKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff2D3290),
                                    Color(0xff4B4FC9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SvgPicture.asset(
                                "assets/profile/profile.svg",
                                height: 18,
                                width: 18,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Add Family Member",
                                style: TextStyle(
                                  color: Color(0xff1E2265),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Inputs
                        _buildDialogTextField(
                          controller: controller.txtFullName,
                          label: "Full Name",
                          hint: "Enter full name",
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: controller.txtMobile,
                          label: "Mobile Number",
                          hint: "Enter mobile number",
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: controller.txtEmail,
                          label: "Email Address",
                          hint: "Enter email address",
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: controller.txtRelation,
                          label: "Relation",
                          hint: "Spouse, Child, Parent etc.",
                        ),
                        const SizedBox(height: 28),

                        // Action Button
                        InkWell(
                          onTap: () {
                            if (familyKey.currentState!.validate()) {
                              Get.back();
                              Loader.showLoader(
                                ConstHelper.navigatorKey.currentContext!,
                                "Please wait...",
                              );
                              ApiHelper.apiHelper
                                  .insertFamilyMember(
                                    token: controller.isLoginToken.value,
                                    fullName: controller.txtFullName.text,
                                    email: controller.txtEmail.text,
                                    mobile: controller.txtMobile.text,
                                    whatsapp: controller.txtMobile.text,
                                    area:
                                        controller.profileData.value.area ?? "",
                                    description:
                                        controller
                                            .profileData
                                            .value
                                            .description ??
                                        "",
                                    relation: controller.txtRelation.text,
                                  )
                                  .then((value) {
                                    Loader.hideLoader(
                                      ConstHelper.navigatorKey.currentContext!,
                                    );
                                    if (value["code"] == 200) {
                                      controller.getFamilyMembers();
                                      ScaffoldMessenger.of(
                                        ConstHelper
                                            .navigatorKey
                                            .currentContext!,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            value["message"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor:
                                              Colors.green.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        ConstHelper
                                            .navigatorKey
                                            .currentContext!,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            value["message"],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.red.shade600,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xff2D3290,
                                  ).withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "Add Member",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2D3290).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              "Add Member",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog TextField
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff1E2265),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff1E2265),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xff2D3290),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter $label";
            }
            return null;
          },
        ),
      ],
    );
  }

  // Helper method for relationship badge colors
  Color _getRelationColor(String? relation) {
    final rel = (relation ?? "").toLowerCase().trim();
    if (rel.contains("spouse") ||
        rel.contains("wife") ||
        rel.contains("husband")) {
      return Colors.purple;
    } else if (rel.contains("child") ||
        rel.contains("son") ||
        rel.contains("daughter")) {
      return Colors.teal;
    } else if (rel.contains("father") ||
        rel.contains("mother") ||
        rel.contains("parent")) {
      return Colors.orange.shade700;
    } else if (rel.contains("brother") ||
        rel.contains("sister") ||
        rel.contains("sibling")) {
      return Colors.blue.shade700;
    }
    return const Color(0xff2D3290);
  }

  // Family Member Card
  Widget _buildFamilyMemberCard(int index) {
    final member = controller.familyMemberList[index];
    final relationLabel = member.relation ?? member.rId ?? "Family";
    final badgeColor = _getRelationColor(relationLabel);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            // Colored left indicator bar
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: badgeColor, width: 5)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/profile/profile.svg",
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(badgeColor, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name ?? "",
                        style: const TextStyle(
                          color: Color(0xff1E2265),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.mobile ?? "",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Relation Badge & Delete Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: badgeColor.withOpacity(0.15)),
                      ),
                      child: Text(
                        relationLabel.toUpperCase(),
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        _showDeleteConfirmation(member);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(FamilyMemberDataModel member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade600,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                "Delete Member",
                style: TextStyle(
                  color: Color(0xff1E2265),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to remove ${member.name} from your family list?",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Loader.showLoader(
                  ConstHelper.navigatorKey.currentContext!,
                  "Please wait...",
                );
                ApiHelper.apiHelper
                    .removeFamilyMember(
                      token: controller.isLoginToken.value,
                      memberID: "${member.id}",
                    )
                    .then((remove) {
                      Loader.hideLoader(
                        ConstHelper.navigatorKey.currentContext!,
                      );
                      if (remove["code"] == 200) {
                        controller.getFamilyMembers();
                        ScaffoldMessenger.of(
                          ConstHelper.navigatorKey.currentContext!,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              remove["message"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(
                          ConstHelper.navigatorKey.currentContext!,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              remove["message"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.red.shade600,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xff2D3290).withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/profile/profile.svg",
                height: 48,
                width: 48,
                colorFilter: const ColorFilter.mode(
                  Color(0xff2D3290),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Family Members Yet",
              style: TextStyle(
                color: Color(0xff1E2265),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the 'Add Member' button above to add family members to your profile",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
