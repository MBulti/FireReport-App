import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/services/services.dart';
import 'package:firereport/utils/controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var appUser = ref.read(authProvider.notifier).user;
    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          // replace does not work here
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false, // Entferne alle Routen
        );
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SwitchListTile(
                title: const Text('Dunkles Thema'),
                value: ref.watch(themeProvider) == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                }),
            const Icon(Icons.person, size: 38),
            Text(appUser.firstName),
            Text(appUser.lastName),
            const SizedBox(height: 30),
            // ElevatedButton(
            //     onPressed: () {
            //       BetterFeedback.of(context).show((UserFeedback feedback) async {
            //         try {
            //           await Future.delayed(const Duration(milliseconds: 500));
            //         } catch (e) {
            //           print(e);
            //         }
            //       });
            //     },
            //     child: const Text("Fehler melden")),
            const Spacer(),

            InvertedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              text: "Ausloggen",
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage())),
              child: const Text("Datenschutzerklärung"),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ImprintPage())),
              child: const Text("Impressum"),
            ),
            const SizedBox(height: 10),
            ref.watch(appVersionProvider).when(
                  data: (data) => Text(data),
                  loading: () => const SizedBox.shrink(),
                  error: (err, stack) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
