import 'package:firereport/controls/default_control.dart';
import 'package:firereport/controls/listtile_control.dart';
import 'package:firereport/models/enums.dart';
import 'package:firereport/notifier/notifier.dart';
import 'package:firereport/utils/formatter.dart';
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
              leading: const Icon(Icons.account_box),
              title: Text(formatRoleType(appUser.roleType, appUser.unitType! == UnitType.kilver)),
              subtitle: Text(formatUnitType(appUser.unitType)),
            ),
            const DefaultDivider(),
            ListTile(
              leading: const SizedBox(),
              title: const Text("Ausloggen"),
              trailing: const Icon(Icons.logout),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
            PasswordResetListTile(),
            const Spacer(),
            const AboutAppListTile(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}