import 'package:firereport/controls/default_control.dart';
import 'package:firereport/models/enums.dart';
import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/utils/formatter.dart';
import 'package:firereport/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestDetailPage extends ConsumerWidget {
  const RequestDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final viewModel = ref.watch(requestDetailProvider);
    var appUser = ref.read(authProvider.notifier).user;
    return Scaffold(
        appBar: AppBar(title: const Text("Neuer Antrag")),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                ListTile(
                  leading: const SizedBox(),
                  title: TextFormField(
                    initialValue: appUser.lastName,
                    decoration: defaultInputDecoration("Name"),
                  ),
                ),
                ListTile(
                  leading: const SizedBox(),
                  title: TextFormField(
                    initialValue: appUser.firstName,
                    decoration: defaultInputDecoration("Vorname"),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.checkroom),
                  title: DropdownButtonFormField(
                    items: RequestType.values
                        .map((requestType) => DropdownMenuItem(
                            value: requestType,
                            child: Text(formatRequestType(requestType))))
                        .toList(),
                    decoration: defaultInputDecoration("Antragstyp"),
                    value: viewModel.requestType,
                    onChanged: (value) => viewModel.setRequestType(value!),
                  ),
                ),
                const DefaultDivider(),
                viewModel.requestType == RequestType.normalUniform
                    ? _NormalUniformForm(viewModel)
                    : _OperationalUniformForm(viewModel)
              ],
            ),
          ),
        ));
  }
}

class _NormalUniformForm extends StatelessWidget {
  final RequestDetailNotifier viewModel;
  const _NormalUniformForm(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [],
    );
  }
}

class _OperationalUniformForm extends StatelessWidget {
  final RequestDetailNotifier viewModel;
  const _OperationalUniformForm(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: viewModel.quantity > 0,
          onChanged: (value) {
            viewModel.setQuantity(value! ? 1 : 0);
          },
          title: const Text("Überjacke Novotex-Isomat NTI 112"),
          subtitle: const Text("Farbe: Sand"),
        ),
        ListTile(
          leading: const SizedBox(),
          title: Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: viewModel.size.toString(),
                  keyboardType: TextInputType.number,
                  decoration: defaultInputDecoration("Größe"),
                ),
              ),
              const SizedBox(width: 20,),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  viewModel.setQuantity(viewModel.quantity - 1);
                },
              ),
              Text(viewModel.quantity.toString()),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  viewModel.setQuantity(viewModel.quantity + 1);
                },
              ),
            ],
          ),
        ),
        const DefaultDivider(),
        const ListTile(
          leading: Icon(Icons.developer_mode),
          title: Text("Erster Entwuf - Work in Progress"),
        )
      ],
    );
  }
}