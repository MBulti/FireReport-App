import 'package:firereport/models/models.dart';
import 'package:firereport/notifier/defectreportdetail_notifier.dart';
import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/utils/controls.dart';
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(index == null
              ? 'Neuer Mängelbericht'
              : 'Mängelbericht bearbeiten'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Eigenschaften",
              ),
              Tab(
                text: "Bilder",
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              Navigator.of(context).pop(viewModel.report);
            }
          },
          child: const Icon(Icons.save),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  TabProperties(
                      formKey: formKey,
                      viewModel: viewModel,
                      userItems: userItems,
                      createdUser: createdUser),
                  TabImages(viewModel: viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TabProperties extends StatelessWidget {
  const TabProperties({
    super.key,
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
              leading: const SizedBox(), // Icon auf der linken Seite
              title: TextFormField(
                initialValue: viewModel.report.title,
                decoration: defaultInputDecoration("Titel"),
                onSaved: (value) {
                  viewModel.report.title = value!;
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bitte einen Titel eingeben';
                  }
                  return null;
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_document),
              title: TextFormField(
                initialValue: viewModel.report.description,
                decoration: defaultInputDecoration("Beschreibung"),
                onSaved: (value) {
                  viewModel.report.description = value!;
                },
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
            const Divider(color: Colors.grey),
            ListTile(
              leading: const SizedBox(),
              title: DropdownStatus(report: viewModel.report),
            ),
            ListTile(
              leading: const SizedBox(),
              title:
                  DropdownUser(userItems: userItems, report: viewModel.report),
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(viewModel.report.dueDate == null
                  ? 'Bitte Fälligkeitsdatum auswählen'
                  : 'Fälligkeitsdatum: ${formatDate(viewModel.report.dueDate!.toLocal())}'),
              onTap: () => viewModel.selectDueDate(context),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text("Benachrichtige mich bei Änderungen"),
              value: viewModel.report.isNotifyUser,
              onChanged: (value) {
                viewModel.setNotifyUser(value);
              },
            ),
            const SizedBox(height: 20),
            if (createdUser != null)
              Text(
                  "Bericht erstellt von: ${createdUser?.firstName} ${createdUser?.lastName}"),
          ],
        ),
      ),
    );
  }
}

class TabImages extends StatelessWidget {
  const TabImages({
    super.key,
    required this.viewModel,
  });

  final DefectReportDetailNotifier viewModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondary,
            elevation: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: viewModel.isLoadImagesInProgress
                      ? const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20),
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
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 4.0,
                                          crossAxisSpacing: 4.0,
                                          childAspectRatio: 1.0,
                                        ),
                                        itemCount:
                                            viewModel.report.lsImages.length,
                                        itemBuilder: (context, index) {
                                          return ReportImage(
                                              imageModel: viewModel
                                                  .report.lsImages[index]);
                                        },
                                      )
                                    : const Text("Keine Bilder vorhanden"),
                                const SizedBox(height: 10),
                                Button(
                                  onPressed: () => viewModel.addImage(context),
                                  text: "Neues Bild",
                                ),
                              ],
                            )
                          : Center(
                              child: Button(
                                  onPressed: viewModel.downloadImages,
                                  text:
                                      "Bilder herunterladen (${viewModel.report.lsImages.length})"),
                            ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownStatus extends StatelessWidget {
  final DefectReportModel report;

  const DropdownStatus({super.key, required this.report});

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

class DropdownUser extends StatelessWidget {
  final List<AppUserModel> userItems;
  final DefectReportModel report;

  const DropdownUser(
      {super.key, required this.userItems, required this.report});

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

class ReportImage extends StatelessWidget {
  final ImageModel imageModel;
  const ReportImage({super.key, required this.imageModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ImageFullScreenPage(imageModel: imageModel);
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

class ImageFullScreenPage extends StatelessWidget {
  const ImageFullScreenPage({super.key, required this.imageModel});
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
