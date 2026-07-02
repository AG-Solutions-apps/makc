import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:makc/Controller/controller.dart';
import 'package:makc/Model/banner_model.dart';
import 'package:makc/Model/profile_model.dart';
import 'package:makc/Model/service_,odel.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/api_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Controller controller = Get.put(Controller());
  PageController pageController = PageController(viewportFraction: 1.0);
  RxInt currentPage = 0.obs;
  Timer? timer;
  bool isLoaded = false;
  bool _isLoading = false;
  final Set<String> _selectedServiceIds = {};
  bool _isRequestSubmitting = false;
  bool _showUpdateBar = false;
  
  // Cached request data - loaded once in initState
  Map<String, List<dynamic>>? _cachedRequestData;
  bool _isRequestDataLoading = false;
  
  Future<void> _checkForUpdate() async {
  final newVersion = NewVersionPlus(
    androidId: "com.makc.agsolutions",
  );

  final status = await newVersion.getVersionStatus();

  if (status == null) return;

  if (status.canUpdate && mounted) {
    setState(() {
      _showUpdateBar = true;
    });
  }
}
  @override
  void initState() {
    super.initState();
    _loadHomePageData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkForUpdate();
  });
  }

  // Load request data after token is ready
  Future<void> _loadRequestData() async {
    if (_isRequestDataLoading) return;
    _isRequestDataLoading = true;
    
    try {
      // Ensure token is available
      await controller.getLoginToken();
      if (controller.isLoginToken.value.isNotEmpty) {
        _cachedRequestData = await _fetchRequestDetails();
      } else {
        print("Token not available for request data");
      }
    } catch (e) {
      print("Error loading request data: $e");
    } finally {
      _isRequestDataLoading = false;
      if (mounted) setState(() {});
    }
  }

  // Refresh cached request data (called after submitting a request)
  Future<void> _refreshRequestData() async {
    try {
      await controller.getLoginToken();
      if (controller.isLoginToken.value.isNotEmpty) {
        _cachedRequestData = await _fetchRequestDetails();
        if (mounted) setState(() {});
      }
    } catch (e) {
      print("Error refreshing request data: $e");
    }
  }

  // Method to load all home page data
  Future<void> _loadHomePageData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      isLoaded = false;
    });

    try {
      await controller.getLoginToken().then((value) async {
        try {
          // Fetch profile data first to get user name and allowed services
          var profile = await ApiHelper.apiHelper.fetchProfile(token: controller.isLoginToken.value);
          if (profile != null && profile["data"] != null) {
            controller.profileData.value = ProfileModel.fromJson(profile["data"]);
          }

          // Fetch banners and services
          var banner = await ApiHelper.apiHelper.fetchServiceBanner(token: controller.isLoginToken.value);
          var service = await ApiHelper.apiHelper.fetchService(token: controller.isLoginToken.value);

          String servicesString = controller.profileData.value.services ?? "";
          String cleanedServices = servicesString
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('{', '')
              .replaceAll('}', '')
              .replaceAll('"', '')
              .replaceAll("'", '');

          List<String> allowedServiceIds = cleanedServices
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e.toLowerCase() != "null")
              .toList();

          if (service != null) {
            List serviceFilterList = service["data"] ?? [];
            List<ServiceDataModel> allServices = serviceFilterList.map((e) => ServiceDataModel.fromJson(e)).toList();

            if (allowedServiceIds.isNotEmpty) {
              controller.serviceList.value = allServices.where((s) {
                String logoName = s.serviceLogo ?? "";
                String id = logoName.contains('_') ? logoName.split('_')[0] : "";
                return allowedServiceIds.contains(id);
              }).toList();
            } else {
              controller.serviceList.value = [];
            }
            // Safe index access for image_url list
            List serviceImgList = service["image_url"] ?? [];
            if (serviceImgList.length > 1) {
              controller.serviceImagePath.value = "${serviceImgList[1]["image_url"]}";
              controller.serviceNOImagePath.value = "${serviceImgList[0]["image_url"]}";
            } else if (serviceImgList.isNotEmpty) {
              controller.serviceImagePath.value = "${serviceImgList[0]["image_url"]}";
            }
          } else {
            controller.serviceList.value = [];
          }

          if (banner != null) {
            List filterList = banner["data"] ?? [];
            List<BannerDataModel> allBanners = filterList.map((e) => BannerDataModel.fromJson(e)).toList();

            controller.bannerList.value = allBanners;

            List bannerImgList = banner["image_url"] ?? [];
            if (bannerImgList.length > 1) {
              controller.imagePath.value = "${bannerImgList[1]["image_url"]}";
              controller.noImagePath.value = "${bannerImgList[0]["image_url"]}";
            } else if (bannerImgList.isNotEmpty) {
              controller.imagePath.value = "${bannerImgList[0]["image_url"]}";
            }
          } else {
            controller.bannerList.value = [];
          }

          // Fetch service requests
          await controller.getServiceRequestList();
          
          // Load request data after token is ready
          await _loadRequestData();
          
        } catch (e) {
          print("Error loading home page data: $e");
        } finally {
          if (mounted) {
            setState(() {
              isLoaded = true;
              _isLoading = false;
            });
          }
        }
      });
    } catch (e) {
      print("Error in loadHomePageData: $e");
      if (mounted) {
        setState(() {
          isLoaded = true;
          _isLoading = false;
        });
      }
    }
  }

  void startAutoSlide() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (controller.bannerList.isNotEmpty && pageController.hasClients) {
        int nextPage = pageController.page!.round() + 1;
        if (nextPage >= controller.bannerList.length) {
          nextPage = 0;
        }
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> checkApp({
    required String packageName,
    required String url,
  }) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  String getPackageName(String url) {
    Uri uri = Uri.parse(url);
    return uri.queryParameters['id'] ?? '';
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadHomePageData,
          color: const Color(0xff2D3290),
          backgroundColor: Colors.white,
          strokeWidth: 3,
          displacement: 40,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Custom Header with User Greeting
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff1E2265),
                        Color(0xff2D3290),
                                                Color.fromARGB(255, 1, 111, 207)
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row with Greeting and Profile Icon
                      Row(
                        children: [
                          Container(
  padding: const EdgeInsets.all(0),
  child: Image.asset(
    'assets/bulb.png', // your asset path
    width: 50,
    height: 50,
    fit: BoxFit.contain,
  ),
),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back!",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Obx(
                                  () => Text(
                                    controller.profileData.value.name?.isNotEmpty == true 
                                        ? controller.profileData.value.name! 
                                        : "User",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Profile Icon Button - Navigates to Profile Page
                          InkWell(
                            onTap: () {
                              controller.bottomIndex.value = 2;
                            },
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              
              // Main Content
              SliverToBoxAdapter(
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Section Title - Our Services
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Our Services",
                              style: TextStyle(
                                color: Color(0xff2D3290),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            // "Add new Service" button - Only show if services exist
                            if (controller.serviceList.isNotEmpty)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  foregroundColor: const Color(0xff2D3290),
                                  backgroundColor: const Color.fromARGB(255, 42, 49, 181).withOpacity(0.20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  // Pass cached data to dialog
                                  _showServiceRequestDialog(context, cachedData: _cachedRequestData);
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text(
                                  "Add New Services",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Service Grid
                      controller.serviceList.isNotEmpty
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: controller.serviceList.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.9,
                              ),
                              itemBuilder: (context, index) {
                                return _buildServiceCard(index);
                              },
                            )
                          : (isLoaded
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        
                                       
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xff2D3290),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 2,
                                          ),
                                          onPressed: () {
                                            _showServiceRequestDialog(context, cachedData: _cachedRequestData);
                                          },
                                          icon: const Icon(Icons.add_circle_outline, size: 18),
                                          label: const Text(
                                            "Request for Services",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : _buildShimmerGrid()),

                      // Service Requests Section
                      Obx(() {
                        if (controller.serviceRequestList.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "My Service Requests",
                                    style: TextStyle(
                                      color: Color(0xff2D3290),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: controller.serviceRequestList.length,
                              itemBuilder: (context, index) {
                                final request = controller.serviceRequestList[index];
                                final status = request["services_request_status"] ?? "Pending";
                                final statusColor = _getStatusColor(status);
                                final dateStr = request["services_request_date"] ?? "";
                                final serviceName = request["service_name"] ?? "";
                                final logoName = request["service_logo"] ?? "";
                                final logoUrl = "${controller.serviceRequestImagePath.value}$logoName";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: Border.all(color: Colors.grey.shade100),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Service Logo
                                        Container(
                                          child: logoName.isNotEmpty
                                              ? Image.network(
                                                  logoUrl,
                                                  width: 52,
                                                  height: 52,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.build, color: Color(0xff2D3290), size: 20);
                                                  },
                                                )
                                              : const Icon(Icons.build, color: Color(0xff2D3290), size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        // Service Name & Date
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                serviceName,
                                                style: const TextStyle(
                                                  color: Color(0xff2D3290),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Requested: $dateStr",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      
                      // Banner Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Offers & Updates",
                              style: TextStyle(
                                color: Color(0xff2D3290),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      controller.bannerList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: controller.bannerList.length,
                              itemBuilder: (context, index) {
                                final banner = controller.bannerList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      final link = banner.serviceSubLink;
                                      if (link != null && link.toString().trim().isNotEmpty) {
                                        _launchBannerLink(link.toString());
                                      }
                                    },
                                    child: Container(
                                      height: screenWidth / 2.2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          "${controller.imagePath.value}${banner.serviceSubBanner}",
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade200,
                                              child: const Center(
                                                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : (isLoaded ? const SizedBox.shrink() : _buildShimmerBanner()),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Service Card Widget
  Widget _buildServiceCard(int index) {
    return InkWell(
      onTap: () {
        String package = getPackageName(controller.serviceList[index].serviceUrl!);
        checkApp(
          packageName: package,
          url: controller.serviceList[index].serviceUrl!,
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              child: Image.network(
                "${controller.serviceImagePath.value}${controller.serviceList[index].serviceLogo}",
                width: Get.width / 3.5,
                height: Get.width / 3.5,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.build, color: const Color(0xff2D3290), size: 28);
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Shimmer Effect for Loading State
  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Get.width / 8,
                height: Get.width / 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 50,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Shimmer Banner
  Widget _buildShimmerBanner() {
    return Container(
      height: Get.width / 2.5,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xff2D3290)),
      ),
    );
  }

  Future<Map<String, List<dynamic>>> _fetchRequestDetails() async {
    try {
      // Make sure token is available
      if (controller.isLoginToken.value.isEmpty) {
        print("Token is empty in _fetchRequestDetails");
        return {"active": [], "requested": []};
      }
      
      final activeResponse = await ApiHelper.apiHelper.fetchActiveServicesForRequest(
        token: controller.isLoginToken.value,
      );
      final requestListResponse = await ApiHelper.apiHelper.fetchServiceRequestList(
        token: controller.isLoginToken.value,
      );

      List<dynamic> activeServices = [];
      List<dynamic> requestedServices = [];

      if (activeResponse != null && activeResponse["data"] != null) {
        activeServices = activeResponse["data"] as List<dynamic>;
        print("Active services count: ${activeServices.length}");
      }
      if (requestListResponse != null && requestListResponse["data"] != null) {
        requestedServices = requestListResponse["data"] as List<dynamic>;
        print("Requested services count: ${requestedServices.length}");
      }

      return {
        "active": activeServices,
        "requested": requestedServices,
      };
    } catch (e) {
      print("Error fetching request details: $e");
      return {"active": [], "requested": []};
    }
  }

  // Updated method with cached data support
  void _showServiceRequestDialog(BuildContext context, {Map<String, List<dynamic>>? cachedData}) {
    _selectedServiceIds.clear();
    _isRequestSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: _buildDialogContent(context, setSheetState, cachedData),
            );
          },
        );
      },
    );
  }

  // Extract dialog content to separate method for cleaner code
  Widget _buildDialogContent(
    BuildContext context,
    StateSetter setSheetState,
    Map<String, List<dynamic>>? cachedData,
  ) {
    // If cached data is null, show loading
    if (cachedData == null) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xff2D3290),
          ),
        ),
      );
    }

    final activeServices = cachedData["active"] ?? [];
    final requestedServices = cachedData["requested"] ?? [];

    print("Dialog - Active services: ${activeServices.length}, Requested: ${requestedServices.length}");

    if (activeServices.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                "No services available for request.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                "Please check back later.",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2D3290),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      );
    }

    // Parse requested service IDs
    final requestedIds = requestedServices
        .map((r) => (r["service_id"] ?? r["id"] ?? "").toString())
        .toSet();

    // Filter out already requested services
    final availableServices = activeServices.where((service) {
      final serviceId = (service["id"] ?? service["service_id"] ?? "").toString();
      return !requestedIds.contains(serviceId);
    }).toList();

    print("Available services after filtering: ${availableServices.length}");

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Request Service",
              style: TextStyle(
                color: Color(0xff2D3290),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Select the services you would like to request:",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 16),
        if (availableServices.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 50, color: Colors.green.shade300),
                  const SizedBox(height: 12),
                  Text(
                    "All services have been requested!",
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Your requests are pending approval.",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableServices.length,
              itemBuilder: (context, index) {
                final service = availableServices[index];
                final serviceId = (service["id"] ?? service["service_id"] ?? "").toString();
                final serviceName = service["service_name"] ?? "";
                final isChecked = _selectedServiceIds.contains(serviceId);

                return CheckboxListTile(
                  activeColor: const Color(0xff2D3290),
                  title: Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setSheetState(() {
                      if (value == true) {
                        _selectedServiceIds.add(serviceId);
                      } else {
                        _selectedServiceIds.remove(serviceId);
                      }
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 20),
        if (availableServices.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2D3290),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isRequestSubmitting || _selectedServiceIds.isEmpty
                  ? null
                  : () async {
                      setSheetState(() {
                        _isRequestSubmitting = true;
                      });

                      bool allSuccess = true;
                      String? successMessage;
                      String? errorMessage;

                      for (final serviceId in _selectedServiceIds) {
                        final response = await ApiHelper.apiHelper.addServiceRequest(
                          token: controller.isLoginToken.value,
                          serviceIds: serviceId,
                        );
                        if (response != null && response["code"] == 200) {
                          successMessage = response["message"];
                        } else {
                          allSuccess = false;
                          errorMessage = response?["message"] ?? "Failed to submit request.";
                        }
                      }

                      // Refresh request list and cached data
                      await controller.getServiceRequestList();
                      await _refreshRequestData();

                      if (!context.mounted) return;

                      if (allSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(successMessage ?? "Service request(s) submitted successfully!"),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        setSheetState(() {
                          _isRequestSubmitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage ?? "Failed to submit request."),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
              child: _isRequestSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Submit Request",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
      case "active":
      case "completed":
        return Colors.green;
      case "rejected":
      case "cancelled":
        return Colors.red;
      case "pending":
      default:
        return Colors.orange;
    }
  }

  Future<void> _launchBannerLink(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith("http://") && !formattedUrl.startsWith("https://")) {
      formattedUrl = "https://$formattedUrl";
    }
    final Uri uri = Uri.parse(formattedUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print("Could not launch $formattedUrl");
      }
    } catch (e) {
      print("Error launching banner URL: $e");
    }
  }
}