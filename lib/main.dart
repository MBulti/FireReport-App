import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/pages.dart';
import 'cubit/cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => SettingsCubit(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, ThemeMode>(builder: (context, thememode) {
      return MaterialApp(
          title: 'FireReport',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: thememode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
          ],
          home: BlocProvider(
              create: (context) => DefectReportCubit(),
              child: const DefectReportPage()));
    });
  }
}
