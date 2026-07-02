import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:makc/Controller/controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    controller.getCompanyData();
    controller.getCompanyImage();
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Error',
        'Could not launch $url',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // Open dialer with phone number
  void _makePhoneCall(String phoneNumber) {
    if (phoneNumber.isNotEmpty && phoneNumber != "**********") {
      _launchUrl('tel:$phoneNumber');
    } else {
      Get.snackbar('Info', 'Phone number not available',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Open email app
  void _sendEmail(String email) {
    if (email.isNotEmpty && email != "abc@gmail.com") {
      _launchUrl('mailto:$email');
    } else {
      Get.snackbar('Info', 'Email address not available',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Open in browser
  void _openWebsite(String url) {
    if (url.isNotEmpty) {
      _launchUrl(url);
    } else {
      Get.snackbar('Info', 'Website URL not available',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Open in Google Maps / Apple Maps
  void _openAddress(String address) {
    if (address.isNotEmpty && address != "--") {
      final query = Uri.encodeComponent(address);
      _launchUrl('https://www.google.com/maps/search/?api=1&query=$query');
    } else {
      Get.snackbar('Info', 'Address not available',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Attractive App Bar with Gradient and Animation
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
                              "About Us",
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
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Logo Section without Shadow ---
                    _buildLogoSection(screenWidth),

                    const SizedBox(height: 1),

                     const SizedBox(height: 15),

                    // --- Contact Cards (Phone, Email, Website, Address) ---
                    // Phone Card
                    _buildContactCard(
                      icon: "assets/profile/call.svg",
                      title: "Phone",
                      value: controller.companyData.value.companyMobileNo ?? "**********",
                      onTap: () => _makePhoneCall(controller.companyData.value.companyMobileNo ?? ""),
                      isClickable: controller.companyData.value.companyMobileNo != null &&
                          controller.companyData.value.companyMobileNo!.isNotEmpty &&
                          controller.companyData.value.companyMobileNo != "**********",
                    ),

                    const SizedBox(height: 12),

                    // Email Card
                    _buildContactCard(
                      icon: "assets/profile/email.svg",
                      title: "Email",
                      value: controller.companyData.value.companyEmail ?? "abc@gmail.com",
                      onTap: () => _sendEmail(controller.companyData.value.companyEmail ?? ""),
                      isClickable: controller.companyData.value.companyEmail != null &&
                          controller.companyData.value.companyEmail!.isNotEmpty &&
                          controller.companyData.value.companyEmail != "abc@gmail.com",
                    ),

                    const SizedBox(height: 12),

                    // Website Card
                    _buildContactCard(
                      icon: "assets/profile/website.svg",
                      title: "Website",
                      value: (() {
                        final websiteUrl = controller.companyData.value.companyWebsite ?? "https://makcautomations.com/";
                        if (websiteUrl.toLowerCase().contains("makc")) {
                          return "makcautomations.com";
                        }
                        String clean = websiteUrl
                            .replaceAll("https://", "")
                            .replaceAll("http://", "")
                            .replaceAll("www.", "");
                        if (clean.endsWith("/")) {
                          clean = clean.substring(0, clean.length - 1);
                        }
                        return clean.isEmpty ? "makcautomations.com" : clean;
                      })(),
                      onTap: () => _openWebsite(controller.companyData.value.companyWebsite ?? "https://makcautomations.com/"),
                      isClickable: true,
                      customIcon: Icons.language,
                    ),

                    const SizedBox(height: 12),

                    // Address Card
                    _buildContactCard(
                      icon: "assets/profile/area.svg",
                      title: "Address",
                      value: controller.companyData.value.companyAddress ??
                          "141/6, 4th Main, 12th Cross Rd, BEML Layout, Brookefield, Bengaluru, Karnataka 560066",
                      onTap: () => _openAddress(
                        controller.companyData.value.companyAddress ??
                            "141/6, 4th Main, 12th Cross Rd, BEML Layout, Brookefield, Bengaluru, Karnataka 560066",
                      ),
                      isClickable: true,
                    ),

                    const SizedBox(height: 40),

                    // Footer Section
                    Column(
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite, color: const Color(0xff2D3290), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "Connecting You to Excellence",
                              style: TextStyle(
                                color: const Color(0xff2D3290),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "© ${DateTime.now().year} MAKC Automations. All rights reserved.",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Logo without shadow
  Widget _buildLogoSection(double screenWidth) {
    return Center(
      child: Container(
        height: screenWidth / 1.5,
        width: screenWidth / 1.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: controller.imageLoader.value == false
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xff2D3290)),
                )
              : (controller.companyData.value.companyLogo == null ||
                      controller.companyData.value.companyLogo!.isEmpty)
                  ? _buildErrorImage()
                  : Image.network(
                      "${controller.companyImage.value}${controller.companyData.value.companyLogo}",
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xff2D3290),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorImage();
                      },
                    ),
        ),
      ),
    );
  }

  // Fallback image if logo fails to load
  Widget _buildErrorImage() {
    return Container(
      color: const Color(0xffF5F7FF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business_center, size: 60, color: const Color(0xff2D3290).withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(
            "Company Logo",
            style: TextStyle(color: const Color(0xff2D3290).withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  // Reusable Contact Card
  Widget _buildContactCard({
    required String icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool isClickable,
    IconData? customIcon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isClickable ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        splashColor: isClickable ? const Color(0xff2D3290).withOpacity(0.1) : Colors.transparent,
        highlightColor: isClickable ? const Color(0xff2D3290).withOpacity(0.05) : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xff2D3290).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: customIcon != null
                    ? Icon(customIcon, color: const Color(0xff2D3290), size: 22)
                    : SvgPicture.asset(
                        icon,
                        height: 22,
                        width: 22,
                        colorFilter: const ColorFilter.mode(Color(0xff2D3290), BlendMode.srcIn),
                        placeholderBuilder: (context) =>
                            Icon(Icons.info, color: const Color(0xff2D3290)),
                      ),
              ),
              const SizedBox(width: 14),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xff2D3290),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: title == "Address" ? 3 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Clickable Indicator
              if (isClickable)
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xff2D3290),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}