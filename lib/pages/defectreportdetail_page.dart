import 'package:firereport/controls/default_control.dart';
import 'package:firereport/models/models.dart';
import 'package:firereport/notifier/defectreportdetail_notifier.dart';
import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:firereport/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefectReportDetailPage extends ConsumerWidget {
  final DefectReportModel? report;
  final List<AppUserModel> lsUsers;
  final int? index;

  const DefectReportDetailPage({
    super.key,
    this.report,
    required this.lsUsers,
    this.index,
  });

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Wirklich verlassen?"),
        content: const Text("Die Änderungen gehen verloren!"),
        actions: [
          TextButton(
            child: const Text('Ja'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text('Nein'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(defectReportDetailProvider(report));
    final formKey = GlobalKey<FormState>();

    final userItems = [
      AppUserModel(id: null, firstName: "Kein Benutzer", lastName: ""),
      ...lsUsers
    ];
    final createdUser = lsUsers
        .where((user) => user.id == viewModel.report.createdBy)
        .firstOrNull;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        final navigator = Navigator.of(context);
        if (!didPop) {
          if (viewModel.isReportChanged()) {
            final shouldExit = await _showExitConfirmationDialog(context);
            if (!shouldExit) return;
          }
          navigator.pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(index == null
              ? 'Neuer Mängelbericht'
              : 'Mängelbericht bearbeiten'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.of(context).pop(viewModel.report);
                }
              },
            ),
          ],
        ),
        body: _DetailForm(
            formKey: formKey,
            viewModel: viewModel,
            userItems: userItems,
            createdUser: createdUser),
      ),
    );
  }
}

class _DetailForm extends StatelessWidget {
  const _DetailForm({
    required this.formKey,
    required this.viewModel,
    required this.userItems,
    required this.createdUser,
  });

  final GlobalKey<FormState> formKey;
  final DefectReportDetailNotifier viewModel;
  final List<AppUserModel> userItems;
  final AppUserModel? createdUser;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          children: [
            ListTile(
              leading: const SizedBox(),
              title: TextFormField(
                initialValue: viewModel.report.title,
                decoration: defaultInputDecoration("Titel"),
                onChanged: (value) => viewModel.report.title = value,
                // onSaved: (value) {
                //   viewModel.report.title = value!;
                // },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte einen Titel eingeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              leading: const DefaultIcon(icon: Icons.edit_document),
              title: TextFormField(
                initialValue: viewModel.report.description,
                decoration: defaultInputDecoration("Beschreibung"),
                onChanged: (value) => viewModel.report.description = value,
                // onSaved: (value) {
                //   viewModel.report.description = value!;
                // },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte eine Beschreibung eingeben';
                  }
                  return null;
                },
                minLines: 1,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const DefaultDivider(),
            ListTile(
              leading: const SizedBox(),
              title: _DropdownStatus(report: viewModel.report),
            ),
            ListTile(
              leading: const SizedBox(),
              title:
                  _DropdownUser(userItems: userItems, report: viewModel.report),
            ),
            const DefaultDivider(),
            ListTile(
              leading: const DefaultIcon(icon: Icons.calendar_month),
              title: Text(viewModel.report.dueDate == null
                  ? 'Bitte Fälligkeitsdatum auswählen'
                  : 'Fälligkeitsdatum: ${formatDate(viewModel.report.dueDate!.toLocal())}'),
              onTap: () => viewModel.selectDueDate(context),
            ),
            SwitchListTile(
              secondary: const DefaultIcon(icon: Icons.notifications),
              title: const Text("Benachrichtige mich bei Änderungen"),
              value: viewModel.report.isNotifyUser,
              onChanged: (value) {
                viewModel.setNotifyUser(value);
              },
            ),
            const DefaultDivider(),
            if (createdUser != null)
              ListTile(
                leading: const DefaultIcon(icon: Icons.person_add),
                title: Text(
                  "Ersteller: ${createdUser?.firstName} ${createdUser?.lastName}",
                ),
              ),
            const DefaultDivider(),
            viewModel.isImagesFetched
                ? ListTile(
                    leading: const DefaultIcon(icon: Icons.attachment),
                    title: const Text("Neues Bild hinzufügen"),
                    trailing: const DefaultIcon(icon: Icons.add),
                    onTap: () => viewModel.addImage(context),
                  )
                : ListTile(
                    leading: const DefaultIcon(icon: Icons.attachment),
                    title: Text(
                        "Anhänge herunterladen (${viewModel.report.lsImages.length})"),
                    trailing: const DefaultIcon(icon: Icons.download),
                    onTap: () => viewModel.downloadImages(),
                  ),
            ListTile(
              leading: const SizedBox(),
              title: _ReportAttachement(viewModel: viewModel),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}

class _ReportAttachement extends StatelessWidget {
  const _ReportAttachement({
    required this.viewModel,
  });

  final DefectReportDetailNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return viewModel.isLoadImagesInProgress
        ? const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Bilder werden geladen..."),
              ],
            ),
          )
        : viewModel.isImagesFetched
            ? Column(
                children: [
                  viewModel.report.lsImages
                          .where((x) => x.imageBytes != null)
                          .isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: viewModel.report.lsImages.length,
                          itemBuilder: (context, index) {
                            return _ReportImage(
                              imageModel: viewModel.report.lsImages[index],
                            );
                          },
                        )
                      : const Text("Keine Bilder vorhanden"),
                ],
              )
            : const SizedBox();
  }
}

class _DropdownStatus extends StatelessWidget {
  final DefectReportModel report;

  const _DropdownStatus({required this.report});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ReportState>(
      value: report.status,
      decoration: defaultInputDecoration("Status"),
      items: ReportState.values.map((status) {
        return DropdownMenuItem(
            value: status, child: Text(formatReportState(status)));
      }).toList(),
      onChanged: (newValue) {
        report.status = newValue!;
      },
    );
  }
}

class _DropdownUser extends StatelessWidget {
  final List<AppUserModel> userItems;
  final DefectReportModel report;

  const _DropdownUser(
      {required this.userItems, required this.report});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AppUserModel>(
      value:
          userItems.where((user) => user.id == report.assignedUser).firstOrNull,
      decoration: defaultInputDecoration("Zugewiesener Benutzer"),
      items: userItems.map((user) {
        return DropdownMenuItem(
            value: user, child: Text('${user.firstName} ${user.lastName}'));
      }).toList(),
      onChanged: (newValue) {
        report.assignedUser = newValue!.id;
      },
    );
  }
}

class _ReportImage extends StatelessWidget {
  final ImageModel imageModel;
  const _ReportImage({required this.imageModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return _ImageFullScreenPage(imageModel: imageModel);
        }));
      },
      child: SizedBox(
        height: 60,
        width: 100,
        child: Hero(
          tag: imageModel.id,
          child: Image.memory(imageModel.imageBytes!),
        ),
      ),
    );
  }
}

class _ImageFullScreenPage extends StatelessWidget {
  const _ImageFullScreenPage({required this.imageModel});
  final ImageModel imageModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: InteractiveViewer(
          child: Center(
            child: Hero(
              tag: imageModel.id,
              child: Image.memory(imageModel.imageBytes!),
            ),
          ),
        ),
      ),
    );
  }
}
