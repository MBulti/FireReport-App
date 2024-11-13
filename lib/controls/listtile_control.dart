import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/pages/pages.dart';
import 'package:firereport/services/device_service.dart';
import 'package:firereport/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordResetListTile extends ConsumerWidget {
  PasswordResetListTile({super.key});

  // autodispose for automatic garbage collection
  final passwordControllerProvider = Provider.autoDispose((ref) {
    final controller = TextEditingController();
    ref.onDispose(() => controller.dispose());
    return controller;
  });

  final confirmPasswordControllerProvider = Provider.autoDispose((ref) {
    final controller = TextEditingController();
    ref.onDispose(() => controller.dispose());
    return controller;
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const SizedBox(),
      title: const Text("Passwort zurücksetzen"),
      trailing: const Icon(Icons.password),
      onTap: () {
        final formKey = GlobalKey<FormState>();
        final passwordController = ref.watch(passwordControllerProvider);
        final confirmPasswordController =
            ref.watch(confirmPasswordControllerProvider);

        passwordController.clear();
        confirmPasswordController.clear();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Neues Passwort eingeben"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: defaultInputDecoration("Neues Passwort"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Bitte geben Sie ein Passwort ein.";
                        } else if (value.length < 6) {
                          return "Mindestens 6 Zeichen ";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: defaultInputDecoration("Passwort bestätigen"),
                      validator: (value) {
                        if (value != null && value != passwordController.text) {
                          return "Die Passwörter stimmen nicht überein.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Abbrechen"),
                ),
                TextButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? true) {
                      ref
                          .read(authProvider.notifier)
                          .changePassword(passwordController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Passwort erfolgreich geändert.")),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Bestätigen"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AboutAppListTile extends ConsumerWidget {
  const AboutAppListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AboutListTile(
      icon: const Icon(Icons.privacy_tip),
      applicationVersion: ref.watch(appVersionProvider).when(
            data: (data) => data,
            loading: () => "",
            error: (err, stack) => "",
          ),
      applicationLegalese: "© 2024 Moritz Bulthaup. Alle Rechte vorbehalten.",
      aboutBoxChildren: [
        ListTile(
          title: const Text("Datenschutzerklärung"),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const PrivacyPolicyPage())),
        ),
        ListTile(
          title: const Text("Impressum"),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ImprintPage())),
        )
      ],
    );
  }
}
