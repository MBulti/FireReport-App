import 'package:firereport/notifier/notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final userNameController = Provider.autoDispose((ref) {
    final controller = TextEditingController();
    ref.onDispose(() => controller.dispose());
    return controller;
  });
  final passwordController = Provider.autoDispose((ref) {
    final controller = TextEditingController();
    ref.onDispose(() => controller.dispose());
    return controller;
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next == AuthState.authenticated || next == AuthState.anonymous) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) {
            return const DefectReportPage();
          }),
        );
      } else if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login fehlgeschlagen'),
          ),
        );
      }
    });
    var authState = ref.watch(authProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: ref.watch(userNameController),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ref.watch(passwordController),
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                  labelText: "Passwort",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => ref.read(authProvider.notifier).login(
                  ref.read(userNameController).text,
                  ref.read(passwordController).text),
              child: const Text("Login"),
            ),
            ElevatedButton(
              onPressed: ref.read(authProvider.notifier).guestLogin,
              child: const Text("Gast Login"),
            ),
            const SizedBox(height: 24.0),
            authState == AuthState.loading
                ? const CircularProgressIndicator()
                : Container(),
          ],
        ),
      ),
    );
  }
}
