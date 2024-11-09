import 'package:firereport/controls/button_control.dart';
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
            icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onPrimary),
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
              const SizedBox(height: 40),
              Text(
                'Anmeldung',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextInputField(
                  isPassword: false,
                  hintText: "Email",
                  controller: ref.watch(userNameController)),
              const SizedBox(height: 16),
              TextInputField(
                  isPassword: true,
                  hintText: "Passwort",
                  controller: ref.watch(passwordController)),
              const SizedBox(height: 24.0),
              Button(
                onPressed: () => ref.read(authProvider.notifier).login(
                    ref.read(userNameController).text,
                    ref.read(passwordController).text),
                text: "Login",
              ),
              // const SizedBox(height: 10.0),
              // Button(
              //   onPressed: ref.read(authProvider.notifier).guestLogin,
              //   text: "Gast Login",
              // ),
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

class TextInputField extends StatelessWidget {
  final bool isPassword;
  final String hintText;
  final TextEditingController controller;
  const TextInputField(
      {super.key,
      required this.isPassword,
      required this.hintText,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Theme.of(context).colorScheme.inverseSurface,
      obscureText: isPassword,
      controller: controller,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      style: TextStyle(
        color: Theme.of(context).colorScheme.inverseSurface,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.inversePrimary,
        hintText: hintText,
        hintStyle:
            TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
        prefixIcon: const Icon(Icons.person),
        prefixIconColor: Theme.of(context).colorScheme.inverseSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}