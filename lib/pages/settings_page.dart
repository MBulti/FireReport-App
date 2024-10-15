import 'package:firereport/notifier/notifier.dart';
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
      body: Column(
        children: [
          SwitchListTile(
              title: const Text('Dunkles Thema'),
              value: ref.watch(themeProvider) == ThemeMode.dark,
              onChanged: (value) {
                ref.read(themeProvider.notifier).toggleTheme();
              }),
          const Divider(),
          const Icon(Icons.person, size: 38),
          Text(appUser.firstName),
          Text(appUser.lastName),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: const Text("Ausloggen"))
        ],
      ),
    );
  }
}
