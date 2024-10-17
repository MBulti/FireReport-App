import 'package:firereport/models/models.dart';
import 'package:firereport/notifier/defectreportdetail_notifier.dart';
import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class DefectReportDetailPage extends ConsumerWidget {
  final DefectReport? report;
  final List<AppUser> lsUsers;
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
      AppUser(id: null, firstName: "Kein Benutzer", lastName: ""),
      ...lsUsers
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
            index == null ? 'Neuer Mängelbericht' : 'Mängelbericht bearbeiten'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Text(
                        "Eigenschaften",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const Divider(),
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
                            decoration: const InputDecoration(
                                labelText: "Beschreibung"),
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
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Text(
                        "Bilder",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                                        ? SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: viewModel
                                                  .report.lsImages.length,
                                              itemBuilder: (context, index) {
                                                return ReportImage(
                                                    imageModel: viewModel.report
                                                        .lsImages[index]);
                                              },
                                            ),
                                          )
                                        : const Text("Keine Bilder vorhanden"),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                viewModel.pickImage(context,
                                                    ImageSource.camera),
                                            child: const Row(
                                              children: [
                                                Icon(
                                                    Icons.add_a_photo_outlined),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("Kamera"),
                                              ],
                                            )),
                                        ElevatedButton(
                                            onPressed: () =>
                                                viewModel.pickImage(context,
                                                    ImageSource.gallery),
                                            child: const Row(
                                              children: [
                                                Icon(Icons
                                                    .add_photo_alternate_outlined),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("Galerie"),
                                              ],
                                            ))
                                      ],
                                    ),
                                  ],
                                )
                              : Center(
                                  child: ElevatedButton(
                                    onPressed: viewModel.downloadImages,
                                    child: Text(
                                        "Bilder herunterladen (${viewModel.report.lsImages.length})"),
                                  ),
                                ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      Navigator.of(context).pop(viewModel.report);
                    }
                  },
                  child: const Text("Speichern")),
            ],
          ),
        ),
      ),
    );
  }
}

class DropdownStatus extends StatelessWidget {
  final DefectReport report;

  const DropdownStatus({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ReportState>(
      value: report.status,
      decoration: const InputDecoration(labelText: "Status"),
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
  final List<AppUser> userItems;
  final DefectReport report;

  const DropdownUser(
      {super.key, required this.userItems, required this.report});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AppUser>(
      value:
          userItems.where((user) => user.id == report.assignedUser).firstOrNull,
      decoration: const InputDecoration(labelText: "Zugewiesener Benutzer"),
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
        height: 100,
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
        child: Center(
          child: Hero(
            tag: imageModel.id,
            child: Image.memory(imageModel.imageBytes!),
          ),
        ),
      ),
    );
  }
}
