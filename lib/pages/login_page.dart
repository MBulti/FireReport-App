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
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fire_truck,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  size: 100),
              const SizedBox(height: 90),
              TextField(
                controller: ref.watch(userNameController),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.inversePrimary,
                  hintText: "Email",
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface),
                  prefixIcon: const Icon(Icons.person),
                  prefixIconColor: Theme.of(context).colorScheme.inverseSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ref.watch(passwordController),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.inversePrimary,
                  hintText: "Passwort",
                  hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface),
                  prefixIcon: const Icon(Icons.lock),
                  prefixIconColor: Theme.of(context).colorScheme.inverseSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).login(
                    ref.read(userNameController).text,
                    ref.read(passwordController).text),
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: ref.read(authProvider.notifier).guestLogin,
                child: Text(
                  "Gast Login",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 24.0),
              Center(
                child: SizedBox(
                  child: authState == AuthState.loading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        )
                      : Container(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
