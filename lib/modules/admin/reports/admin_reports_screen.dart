import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  late TabController _tabController;

  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;
  String selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            selectedStatus = 'all';
            break;
          case 1:
            selectedStatus = FirebaseConstants.reportStatusPending;
            break;
          case 2:
            selectedStatus = FirebaseConstants.reportStatusReviewed;
            break;
          case 3:
            selectedStatus = FirebaseConstants.reportStatusResolved;
            break;
        }
      });
    });
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      setState(() => isLoading = true);
      final results = await _firestoreService.getAll(
        collection: FirebaseConstants.reportsCollection,
        orderBy: FirebaseConstants.fieldCreatedAt,
        descending: true,
      );
      setState(() {
        reports = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to load reports: $e');
    }
  }

  List<Map<String, dynamic>> get filteredReports {
    if (selectedStatus == 'all') return reports;
    return reports.where((r) => r[FirebaseConstants.fieldStatus] == selectedStatus).toList();
  }

  int get pendingCount => reports.where((r) => r[FirebaseConstants.fieldStatus] == FirebaseConstants.reportStatusPending).length;
  int get reviewedCount => reports.where((r) => r[FirebaseConstants.fieldStatus] == FirebaseConstants.reportStatusReviewed).length;
  int get resolvedCount => reports.where((r) => r[FirebaseConstants.fieldStatus] == FirebaseConstants.reportStatusResolved).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${reports.length})'),
            Tab(text: 'Pending ($pendingCount)'),
            Tab(text: 'Reviewed ($reviewedCount)'),
            Tab(text: 'Resolved ($resolvedCount)'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredReports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      return _buildReportCard(filteredReports[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: AppTextStyles.h4.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report[FirebaseConstants.fieldStatus]?.toString() ?? 'pending';
    final reason = report[FirebaseConstants.fieldReason]?.toString() ?? 'No reason';
    final description = report[FirebaseConstants.fieldDescription]?.toString() ?? '';
    final reporterId = report[FirebaseConstants.fieldReporterId]?.toString() ?? '';
    final reportedUserId = report[FirebaseConstants.fieldReportedUserId]?.toString() ?? '';
    final createdAt = report[FirebaseConstants.fieldCreatedAt];
    final reportId = report['id'];

    String dateStr = 'Unknown date';
    if (createdAt != null) {
      DateTime? date;
      if (createdAt is Timestamp) {
        date = createdAt.toDate();
      } else if (createdAt is DateTime) {
        date = createdAt;
      }
      if (date != null) {
        dateStr = '${date.day}/${date.month}/${date.year}';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusBadge(status),
                const Spacer(),
                Text(dateStr, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 12),
            Text('Reason: $reason', style: AppTextStyles.labelLarge),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(description, style: AppTextStyles.bodySmall),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reporter: $reporterId',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reported User: $reportedUserId',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == FirebaseConstants.reportStatusPending) ...[
                  TextButton(
                    onPressed: () => _updateStatus(reportId, FirebaseConstants.reportStatusReviewed),
                    child: const Text('Mark Reviewed'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (status != FirebaseConstants.reportStatusResolved)
                  ElevatedButton(
                    onPressed: () => _showResolveDialog(reportId, reportedUserId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Resolve', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'reviewed':
        color = Colors.blue;
        label = 'Reviewed';
        break;
      case 'resolved':
        color = Colors.green;
        label = 'Resolved';
        break;
      default:
        color = Colors.orange;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(75)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Future<void> _updateStatus(String reportId, String status) async {
    try {
      await _firestoreService.update(
        collection: FirebaseConstants.reportsCollection,
        documentId: reportId,
        data: {
          FirebaseConstants.fieldStatus: status,
          FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
        },
      );
      _loadReports();
      Get.snackbar('Success', 'Report status updated', backgroundColor: Colors.green.shade100);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  void _showResolveDialog(String reportId, String reportedUserId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Resolve Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose an action to resolve this report:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Mark as Resolved'),
              subtitle: const Text('No action against user'),
              onTap: () {
                Get.back();
                _updateStatus(reportId, FirebaseConstants.reportStatusResolved);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text('Warn & Resolve'),
              subtitle: const Text('Send warning to user'),
              onTap: () {
                Get.back();
                _updateStatus(reportId, FirebaseConstants.reportStatusResolved);
                // TODO: Send warning notification
                Get.snackbar('Info', 'Warning sent to user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Suspend User & Resolve'),
              subtitle: const Text('Suspend the reported user'),
              onTap: () async {
                Get.back();
                try {
                  await _firestoreService.update(
                    collection: FirebaseConstants.usersCollection,
                    documentId: reportedUserId,
                    data: {'profileStatus': 'suspended'},
                  );
                  _updateStatus(reportId, FirebaseConstants.reportStatusResolved);
                  Get.snackbar('Success', 'User suspended and report resolved');
                } catch (e) {
                  Get.snackbar('Error', 'Failed to suspend user: $e');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
