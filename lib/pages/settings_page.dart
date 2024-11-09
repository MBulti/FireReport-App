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
                secondary: const Icon(Icons.color_lens),
                title: const Text('Dunkles Thema'),
                value: ref.watch(themeProvider) == ThemeMode.dark,
                onChanged: (value) {
                  ref.read(themeProvider.notifier).toggleTheme();
                }),
            const DefaultDivider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(appUser.lastName),
              subtitle: Text(appUser.firstName),
            ),
            ListTile(
              leading: const SizedBox(),
              title: const Text("Ausloggen"),
              trailing: const Icon(Icons.logout),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
            const Spacer(),
            AboutListTile(
              icon: const Icon(Icons.info),
              applicationVersion: ref.watch(appVersionProvider).when(
                    data: (data) => data,
                    loading: () => "",
                    error: (err, stack) => "",
                  ),
              applicationLegalese:
                  "© 2024 Moritz Bulthaup. Alle Rechte vorbehalten.",
              aboutBoxChildren: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Datenschutzerklärung"),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyPage())),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Impressum"),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ImprintPage())),
                )
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
