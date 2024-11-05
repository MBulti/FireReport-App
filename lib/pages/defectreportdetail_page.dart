import 'package:firereport/models/models.dart';
import 'package:firereport/notifier/defectreportdetail_notifier.dart';
import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/utils/controls.dart';
import 'package:firereport/utils/formatter.dart';
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
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  children: [
                    // First Tab: Eigenschaften (Properties)
                    TabProperties(
                        formKey: formKey,
                        viewModel: viewModel,
                        userItems: userItems,
                        createdUser: createdUser),
                    // Second Tab: Bilder (Images)
                    TabImages(viewModel: viewModel),
                  ],
                ),
              ),
            ],
          ),
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
            Card(
              color: Theme.of(context).colorScheme.secondary,
              elevation: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: viewModel.report.title,
                          decoration: const InputDecoration(
                            labelText: "Titel",
                          ),
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
                        TextFormField(
                          initialValue: viewModel.report.description,
                          decoration:
                              const InputDecoration(labelText: "Beschreibung"),
                          onSaved: (value) {
                            viewModel.report.description = value!;
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
                        DropdownStatus(report: viewModel.report),
                        const SizedBox(height: 10),
                        DropdownUser(
                            userItems: userItems, report: viewModel.report),
                        const SizedBox(height: 10),
                        ListTile(
                          title: Text(viewModel.report.dueDate == null
                              ? 'Bitte Fälligkeitsdatum auswählen'
                              : 'Datum: ${formatDate(viewModel.report.dueDate!.toLocal())}'),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => viewModel.selectDueDate(context),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                            title: const Text(
                                "Benachrichtige mich bei Änderungen"),
                            value: viewModel.report.isNotifyUser,
                            onChanged: (value) {
                              viewModel.setNotifyUser(value);
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (createdUser != null)
              Text(
                  "Erstellt von: ${createdUser?.firstName} ${createdUser?.lastName}"),
            const SizedBox(height: 20),
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
      decoration: InputDecoration(
        labelText: "Status",
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
      ),
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
      decoration: InputDecoration(
        labelText: "Zugewiesener Benutzer",
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
      ),
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
