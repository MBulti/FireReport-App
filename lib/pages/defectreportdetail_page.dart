import 'package:firereport/cubit/cubit.dart';
import 'package:firereport/models/models.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DefectReportDetailPage extends StatefulWidget {
  const DefectReportDetailPage(
      {super.key, this.report, this.index, required this.lsUsers, required this.onSave});
  final DefectReport? report;
  final List<AppUser> lsUsers;
  final int? index;
  final void Function(DefectReport) onSave;

  @override
  State<DefectReportDetailPage> createState() => _DefectReportDetailPageState();
}

class _DefectReportDetailPageState extends State<DefectReportDetailPage> {
  final formKey = GlobalKey<FormState>();

  late DefectReport report;
  late DateTime firstDate;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      report = widget.report!;
    } else {
      report = DefectReport(
        id: DateTime.now().millisecondsSinceEpoch,
        title: "",
        description: "",
        status: ReportState.open,
      );
    }
    if (report.dueDate != null && report.dueDate!.isBefore(DateTime.now())) {
        firstDate = report.dueDate!;
      } else {
        firstDate = DateTime.now();
      }
  }

  Future<void> selectDueDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
        context: context,
        initialDate: report.dueDate ?? DateTime.now(),
        firstDate: firstDate,
        lastDate: DateTime(2101),
        locale: const Locale('de', 'DE'));
    if (selectedDate != null) {
      setState(() {
        report.dueDate = selectedDate;
      });
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    widget.onSave(report);
    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final userItems = [AppUser(id: null, firstName: "Kein Benutzer", lastName: ""), ...widget.lsUsers];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null
            ? 'Neuer Mängelbericht'
            : 'Mängelbericht bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: report.title,
                decoration: const InputDecoration(labelText: "Titel"),
                onSaved: (value) {
                  report.title = value!;
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte einen Titel eingeben';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: report.description,
                decoration: const InputDecoration(labelText: "Beschreibung"),
                onSaved: (value) {
                  report.description = value!;
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte eine Beschreibung eingeben';
                  }
                  return null;
                },
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              DropdownButtonFormField(
                value: report.status,
                decoration: const InputDecoration(labelText: "Status"),
                items: ReportState.values.map((status) {
                  return DropdownMenuItem(
                      value: status, child: Text(formatReportState(status)));
                }).toList(),
                onChanged: (newValue) {
                  report.status = newValue!;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: userItems.where((user) => user.id == report.assignedUser).firstOrNull,
                decoration: const InputDecoration(labelText: "Zugewiesener Benutzer"),
                items: userItems.map((user) {
                  return DropdownMenuItem(
                      value: user, child: Text('${user.firstName} ${user.lastName}'));
                }).toList(),
                onChanged: (newValue) {
                  report.assignedUser = newValue!.id;
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(report.dueDate == null
                    ? 'Bitte Fälligkeitsdatum auswählen'
                    : 'Datum: ${formatDate(report.dueDate!.toLocal())}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => selectDueDate(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: context.read<AuthCubit>().isAnonymousUser ? null : save,
                  child: Text(
                      widget.index == null ? 'Hinzufügen' : 'Aktualisieren')),
            ],
          ),
        ),
      ),
    );
  }
}
