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
    super.initState();
    controller.getLoginToken().then((value) {
      ApiHelper.apiHelper.fetchComplaint(token: controller.isLoginToken.value).then((complaint) {
        List filterList = complaint["data"];
        controller.complaintList.value = filterList.map((e) => ComplaintDataModel.fromJson(e)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Attractive App Bar
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
                              "Requests / Complaints",
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section with Add Button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              const Text(
                                "History",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _buildAddComplaintButton(),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Complaints List
                    Obx(
                      () => controller.complaintList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.complaintList.length,
                              itemBuilder: (context, index) {
                                return _buildComplaintCard(index);
                              },
                            )
                          : _buildEmptyState(),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add Complaint Button
  Widget _buildAddComplaintButton() {
    return InkWell(
      onTap: () {
        controller.txtComplaintSubject.clear();
        controller.txtComplaintDescription.clear();
        showDialog(
          barrierDismissible: false,
          context: ConstHelper.navigatorKey.currentContext!,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    key: complaintKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.report_problem, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Raise a Request / Complaint",
                                style: TextStyle(
                                  color: Color(0xff2D3290),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDialogTextField(
                          controller: controller.txtComplaintSubject,
                          label: "Request / Complaint Subject",
                          hint: "Enter the request/complaint subject",
                          icon: Icons.title,
                        ),
                        const SizedBox(height: 16),
                        _buildDialogTextField(
                          controller: controller.txtComplaintDescription,
                          label: "Request / Complaint Description",
                          hint: "Enter the request/complaint description",
                          icon: Icons.description,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          onTap: () {
                            if (complaintKey.currentState!.validate()) {
                              Get.back();
                              Loader.showLoader(ConstHelper.navigatorKey.currentContext!, "Please wait...");
                              ApiHelper.apiHelper.insertComplaint(
                                token: controller.isLoginToken.value,
                                complaintSubject: controller.txtComplaintSubject.text,
                                complaintDescription: controller.txtComplaintDescription.text,
                              ).then((value) {
                                Loader.hideLoader(ConstHelper.navigatorKey.currentContext!);
                                if (value["code"] == 200) {
                                  controller.getComplaint();
                                  ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
                                    SnackBar(
                                      content: Text(value["message"], style: const TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(ConstHelper.navigatorKey.currentContext!).showSnackBar(
                                    SnackBar(
                                      content: Text(value["message"], style: const TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                "Submit Complaint",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff2D3290).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Add new",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff4D4D4D),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xff2D3290), size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xff2D3290), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter the $label";
            }
            return null;
          },
        ),
      ],
    );
  }

  // Complaint Card - Reduced Height Version
  Widget _buildComplaintCard(int index) {
    final complaint = controller.complaintList[index];
    final statusColor = _getStatusColor(complaint.complaintStatus ?? "");
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _showComplaintDetails(complaint);
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Icon, Subject, Status
                  Row(
                    children: [
                      // Complaint Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.report_problem, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      // Subject
                      Expanded(
                        child: Text(
                          complaint.complaintSubject ?? "",
                          style: const TextStyle(
                            color: Color(0xff2D3290),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              complaint.complaintStatus ?? "",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Row 2: Description and View Details in Single Line
                  Row(
                    children: [
                      // Description (flexible, single line)
                      Expanded(
                        child: Text(
                          complaint.complaintDescription ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // View Details Link
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "View Details",
                            style: TextStyle(
                              color: const Color(0xff2D3290),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.arrow_forward, color: const Color(0xff2D3290), size: 10),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Complaint Details Dialog
  void _showComplaintDetails(ComplaintDataModel complaint) {
    final statusColor = _getStatusColor(complaint.complaintStatus ?? "");
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff2D3290), Color(0xff4B4FC9)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.report_problem, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        complaint.complaintSubject ?? "",
                        style: const TextStyle(
                          color: Color(0xff2D3290),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: statusColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Status: ${complaint.complaintStatus ?? "Pending"}",
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Color(0xff4D4D4D),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    complaint.complaintDescription ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff2D3290).withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Color(0xff2D3290),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Get status color based on status text
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "resolved":
      case "completed":
        return Colors.green;
      case "in progress":
      case "processing":
        return Colors.blue;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xff2D3290).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.report_problem_outlined,
              size: 60,
              color: Color(0xff2D3290),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Requests / Complaints Yet",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the 'New Request /New Complaint' button to raise a Request/Complaint",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}