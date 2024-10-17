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
    final viewModel = ref.watch(defectReportNotifierProvider);

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
      body: viewModel.isSaveInProgress
          ? const DefectReportSaving()
          : Column(
              children: [
                // Filter Dropdown
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<FilterStatus>(
                      value: viewModel.filterStatus,
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
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                          ? Center(child: Text(viewModel.errorMessage!))
                          : RefreshIndicator(
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
                                      .read(
                                          defectReportNotifierProvider.notifier)
                                      .filteredReports[index];

                                  return GestureDetector(
                                    onTap: () async {
                                      var updatedReport = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DefectReportDetailPage(
                                            report: report,
                                            index: index,
                                            lsUsers: viewModel.users,
                                          ),
                                        ),
                                      );
                                      if (updatedReport != null) {
                                        ref
                                            .read(defectReportNotifierProvider
                                                .notifier)
                                            .upsertReport(updatedReport);
                                      }
                                    },
                                    child: DefectReportListItem(report: report),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
      floatingActionButton: ref.read(authProvider.notifier).isAnonymousUser
          ? null
          : FloatingActionButton(
              onPressed: () async {
                var newReport = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DefectReportDetailPage(
                      lsUsers: viewModel.users,
                    ),
                  ),
                );
                if (newReport != null) {
                  ref
                      .read(defectReportNotifierProvider.notifier)
                      .upsertReport(newReport);
                }
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

class DefectReportSaving extends StatelessWidget {
  const DefectReportSaving({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text("Bericht wird gespeichert ..."),
      ],
    ));
  }
}
