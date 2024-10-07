import 'package:firereport/cubit/cubit.dart';
import 'package:firereport/models/models.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class DefectReportDetailPage extends StatefulWidget {
  const DefectReportDetailPage({
    super.key,
    this.report,
    this.index,
    required this.lsUsers,
  });
  final DefectReport? report;
  final List<AppUser> lsUsers;
  final int? index;

  @override
  State<DefectReportDetailPage> createState() => _DefectReportDetailPageState();
}

class _DefectReportDetailPageState extends State<DefectReportDetailPage> {
  final formKey = GlobalKey<FormState>();

  late DefectReport report;
  late DateTime firstDate;
  bool isNotifyUser = false;
  bool isImagesFetched = false;
  bool isLoadImagesInProgress = false;
  bool isSaveInProgress = false;

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

    if (report.lsImages.isEmpty) {
      isImagesFetched = true;
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

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final fileExtension = pickedFile.name.split('.').last;
      final ImageModel image = ImageModel(
        id: DateTime.now().millisecondsSinceEpoch,
        reportId: report.id,
        url:
            "report_${report.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension",
        imageBytes: await pickedFile.readAsBytes(),
      );

      setState(() {
        report.lsImages.add(image);
      });
    }
  }

  Future<void> downloadImages() async {
    setState(() {
      isLoadImagesInProgress = true;
    });
    for (var image in report.lsImages) {
      image = await context.read<DefectReportCubit>().downloadImage(image);
    }
    setState(() {
      isImagesFetched = true;
      isLoadImagesInProgress = false;
    });
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    setState(() {
      isSaveInProgress = true;
    });
    await context.read<DefectReportCubit>().upsertReport(report);
    setState(() {
      isSaveInProgress = false;
    });
    if (!mounted) return;
    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final userItems = [
      AppUser(id: null, firstName: "Kein Benutzer", lastName: ""),
      ...widget.lsUsers
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.index == null
            ? 'Neuer Mängelbericht'
            : 'Mängelbericht bearbeiten'),
      ),
      body: isSaveInProgress
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Bericht wird gespeichert ..."),
              ],
            ))
          : Padding(
              padding: const EdgeInsets.all(4.0),
              child: Form(
                key: formKey,
                child: ListView(
                  children: [
                    Card.outlined(
                      elevation: 2,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                            child: Text(
                              "Eigenschaften",
                              textAlign: TextAlign.start,
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
                                  initialValue: report.title,
                                  decoration:
                                      const InputDecoration(labelText: "Titel"),
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
                                  decoration: const InputDecoration(
                                      labelText: "Beschreibung"),
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
                                DropdownStatus(report: report),
                                const SizedBox(height: 10),
                                DropdownUser(
                                    userItems: userItems, report: report),
                                const SizedBox(height: 10),
                                ListTile(
                                  title: Text(report.dueDate == null
                                      ? 'Bitte Fälligkeitsdatum auswählen'
                                      : 'Datum: ${formatDate(report.dueDate!.toLocal())}'),
                                  trailing: const Icon(Icons.calendar_today),
                                  onTap: () => selectDueDate(context),
                                ),
                                const SizedBox(height: 10),
                                SwitchListTile(
                                    title: const Text(
                                        "Benachrichtige mich bei Änderungen"),
                                    value: isNotifyUser,
                                    onChanged: (value) {
                                      setState(() {
                                        isNotifyUser = value;
                                      });
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card.outlined(
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
                            child: isLoadImagesInProgress
                                ? const Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 20),
                                        Text("Bilder werden geladen..."),
                                      ],
                                    ),
                                  )
                                : isImagesFetched
                                    ? Column(
                                        children: [
                                          report.lsImages
                                                  .where((x) =>
                                                      x.imageBytes != null)
                                                  .isNotEmpty
                                              ? SizedBox(
                                                  height: 100,
                                                  child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        report.lsImages.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ReportImage(
                                                          imageModel: report
                                                              .lsImages[index]);
                                                    },
                                                  ),
                                                )
                                              : const Text(
                                                  "Keine Bilder vorhanden"),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  onPressed: () => _pickImage(
                                                      context,
                                                      ImageSource.camera),
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons
                                                          .add_a_photo_outlined),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text("Kamera"),
                                                    ],
                                                  )),
                                              ElevatedButton(
                                                  onPressed: () => _pickImage(
                                                      context,
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
                                          onPressed: downloadImages,
                                          child: Text(
                                              "${report.lsImages.length} Bilder laden"),
                                        ),
                                      ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: context.read<AuthCubit>().isAnonymousUser
                            ? null
                            : save,
                        child: Text(
                            widget.index == null ? 'Hinzufügen' : 'Speichern')),
                  ],
                ),
              ),
            ),
    );
  }
}

class DropdownStatus extends StatelessWidget {
  const DropdownStatus({
    super.key,
    required this.report,
  });

  final DefectReport report;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
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
  const DropdownUser({
    super.key,
    required this.userItems,
    required this.report,
  });

  final List<AppUser> userItems;
  final DefectReport report;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
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
