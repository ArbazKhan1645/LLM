import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportedListController extends GetxController {
  var selectedType = 'ALL'.obs;
  var selectedSeverity = 'ALL'.obs;
  var reportCount = 0.obs;

  var typeOptions = ['ALL', 'POST', 'IMAGE', 'COMMENT', 'USER'].obs;
  var severityOptions = ['ALL', 'HIGH', 'MEDIUM', 'LOW'].obs;

  var reportedItems =
      <ReportedItem>[
        // ReportedItem(
        //   id: '1',
        //   userName: 'LISA RAY',
        //   userImage: 'assets/lisa.jpg',
        //   reportType: 'POST',
        //   reportReason: 'INAPPROPRIATE CONTENT',
        //   reportedFor: 'INAPPROPRIATE CONTENT',
        //   reportedDate: 'FEB 16,2023',
        //   reportId: 'REPORT: 4',
        // ),
        // ReportedItem(
        //   id: '2',
        //   userName: 'SAM WILKINS',
        //   userImage: 'assets/sam.jpg',
        //   reportType: 'IMAGE',
        //   reportReason: 'COPYRIGHT INFRINGEMENT',
        //   reportedFor: 'COPYRIGHT INFRINGEMENT',
        //   reportedDate: 'FEB 16,2023',
        //   reportId: 'REPORT: 10',
        // ),
        // ReportedItem(
        //   id: '3',
        //   userName: 'MARK THOMPSON',
        //   userImage: 'assets/mark.jpg',
        //   reportType: 'COMMENT',
        //   reportReason: 'HARASSMENT',
        //   reportedFor: 'HARASSMENT',
        //   reportedDate: 'FEB 16,2023',
        //   reportId: 'REPORT: 10',
        // ),
      ].obs;

  void updateType(String type) {
    selectedType.value = type;
  }

  void updateSeverity(String severity) {
    selectedSeverity.value = severity;
  }

  void approveReport(String id) {
    // Handle approve action
    Get.snackbar(
      'Success',
      'Report approved successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void deleteReport(String id) {
    // Handle delete action
    reportedItems.removeWhere((item) => item.id == id);
    reportCount.value = reportedItems.length;
    Get.snackbar(
      'Success',
      'Report deleted successfully',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void ignoreReport(String id) {
    // Handle ignore action
    Get.snackbar(
      'Success',
      'Report ignored successfully',
      backgroundColor: Colors.grey,
      colorText: Colors.white,
    );
  }
}

class ReportedItem {
  final String id;
  final String userName;
  final String userImage;
  final String reportType;
  final String reportReason;
  final String reportedFor;
  final String reportedDate;
  final String reportId;

  ReportedItem({
    required this.id,
    required this.userName,
    required this.userImage,
    required this.reportType,
    required this.reportReason,
    required this.reportedFor,
    required this.reportedDate,
    required this.reportId,
  });
}
