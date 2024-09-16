import 'package:firereport/pages/pages.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:firereport/utils/helper_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firereport/models/models.dart';
import 'package:firereport/cubit/cubit.dart';

class DefectReportPage extends StatelessWidget {
  const DefectReportPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Column(children: [
        // dropdown
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              BlocSelector<DefectReportCubit, DefectReportState, FilterStatus>(
                  selector: (state) {
            if (state is DefectReportLoaded) {
              return state.filterStatus;
            }
            return FilterStatus.all;
          }, builder: (context, state) {
            return DropdownButtonFormField<FilterStatus>(
              value: state,
              items: FilterStatus.values.map((status) {
                return DropdownMenuItem(
                    value: status, child: Text(formatFilterState(status)));
              }).toList(),
              onChanged: (newValue) {
                context.read<DefectReportCubit>().setFilter(newValue!);
              },
              decoration: const InputDecoration(
                labelText: 'Nach Status filtern',
                border: OutlineInputBorder(),
              ),
            );
          }),
        ),
        // list
        Expanded(
          child: BlocBuilder<DefectReportCubit, DefectReportState>(
            builder: (context, state) {
              if (state is DefectReportLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DefectReportError) {
                return Center(child: Text(state.message));
              } else if (state is DefectReportLoaded) {
                var lsReports =
                    context.read<DefectReportCubit>().filteredReports;
                //lsReports.sort((a, b) => b.id.compareTo(a.id));

                lsReports.sort((a, b) {
                  int statusComparison = a.status.compareToEnum(b.status);
                  if (statusComparison != 0) {
                    return statusComparison;
                  } else {
                    return a.dueDate.compareNullableTo(b.dueDate);
                  }
                });

                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DefectReportCubit>().fetchReports();
                  },
                  child: ListView.builder(
                    itemCount: lsReports.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DefectReportDetailPage(
                                  report: lsReports[index],
                                  index: index,
                                  onSave: (report) => context
                                      .read<DefectReportCubit>()
                                      .updateReport(report),
                                ),
                              ),
                            );
                          },
                          child:
                              DefectReportListItem(report: lsReports[index]));
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ),
      ]),
      floatingActionButton: context.read<AuthCubit>().isAnonymousUser
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DefectReportDetailPage(
                      onSave: (report) =>
                          context.read<DefectReportCubit>().addReport(report),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8),
            Text(report.description),
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
    );
  }
}
