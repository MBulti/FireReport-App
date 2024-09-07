import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firereport/cubit/cubit.dart';
import 'pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) => {
          if (state == AuthState.unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil( // replace does not work here 
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
              (route) => false, // Entferne alle Routen
            ),
          }
        },
        child: BlocBuilder<SettingsCubit, ThemeMode>(
          builder: (context, themeMode) {
            return Column(
              children: [
                SwitchListTile(
                  title: const Text('Dunkles Thema'),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleTheme();  // Wechsle das Theme
                  },
                ),
                ElevatedButton(onPressed: () {
                  context.read<AuthCubit>().logout();
                }, child: const Text("Ausloggen"))
              ],
            );
          },
        ),
      ),
    );
  }
}