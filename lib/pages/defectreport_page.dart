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
    final filteredReports = ref.watch(filteredDefectReportProvider);

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
                    value: ref.watch(
                        filterStatusProvider), // Aktuellen Filterstatus anzeigen
                    items: FilterStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(formatFilterState(status)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      ref.read(filterStatusProvider.notifier).state = newValue!;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nach Status filtern',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                    ),
                  ),
                ),
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
                                itemCount: filteredReports.length,
                                itemBuilder: (context, index) {
                                  final report = filteredReports[index];

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
  final DefectReportModel report;
  const DefectReportListItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = report.isNew
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.secondary;
    final Color textColor = report.isNew
        ? Theme.of(context).colorScheme.onError
        : Theme.of(context).colorScheme.onSecondary;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        color: backgroundColor,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: textColor),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status: ${formatReportState(report.status)}',
                      style: TextStyle(color: textColor)),
                  Text(
                      'Fällig am: ${report.dueDate != null ? formatDate(report.dueDate!.toLocal()) : 'Kein Datum'}',
                      style: TextStyle(color: textColor)),
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
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(
          "Bericht wird gespeichert ...",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    ));
  }
}
