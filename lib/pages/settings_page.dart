import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firereport/cubit/cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: BlocBuilder<SettingsCubit, ThemeMode>(
        builder: (context, themeMode) {
          return SwitchListTile(
            title: const Text('Dunkles Thema'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              context.read<SettingsCubit>().toggleTheme();  // Wechsle das Theme
            },
          );
        },
      ),
    );
  }
}