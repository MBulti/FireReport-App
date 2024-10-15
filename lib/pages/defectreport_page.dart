import 'package:firereport/models/models.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/notifier/notifier.dart';
import 'pages.dart';

class DefectReportPage extends ConsumerWidget {
  const DefectReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final defectReportState = ref.watch(defectReportNotifierProvider);

    // Get the current list of users (for assignment)
    final stateLsUser = defectReportState is DefectReportLoaded
        ? defectReportState.users
        : List<AppUser>.empty();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktuelle Mängelberichte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<FilterStatus>(
                value: defectReportState is DefectReportLoaded
                    ? defectReportState.filterStatus
                    : FilterStatus.all,
                items: FilterStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(formatFilterState(status)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  ref
                      .read(defectReportNotifierProvider.notifier)
                      .setFilter(newValue!);
                },
                decoration: const InputDecoration(
                  labelText: 'Nach Status filtern',
                  border: OutlineInputBorder(),
                ),
              )),
          // Report List
          Expanded(
            child: defectReportState is DefectReportLoading
                ? const Center(child: CircularProgressIndicator())
                : defectReportState is DefectReportError
                    ? Center(child: Text(defectReportState.message))
                    : defectReportState is DefectReportLoaded
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(defectReportNotifierProvider.notifier)
                                  .fetchReports();
                            },
                            child: ListView.builder(
                              itemCount: ref
                                  .read(defectReportNotifierProvider.notifier)
                                  .filteredReports
                                  .length,
                              itemBuilder: (context, index) {
                                final report = ref
                                    .read(defectReportNotifierProvider.notifier)
                                    .filteredReports[index];

                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DefectReportDetailPage(
                                          report: report,
                                          index: index,
                                          lsUsers: stateLsUser,
                                        ),
                                      ),
                                    );
                                  },
                                  child: DefectReportListItem(report: report),
                                );
                              },
                            ),
                          )
                        : const Center(child: Text('Keine Mängeberichte verfügbar')),
          ),
        ],
      ),
      floatingActionButton: ref.read(authProvider.notifier).isAnonymousUser
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DefectReportDetailPage(
                      lsUsers: stateLsUser,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}

class DefectReportListItem extends StatelessWidget {
  final DefectReport report;
  const DefectReportListItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status: ${formatReportState(report.status)}'),
                  Text(
                      'Fällig am: ${report.dueDate != null ? formatDate(report.dueDate!.toLocal()) : 'Kein Datum'}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}