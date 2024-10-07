import 'package:firereport/utils/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'pages/pages.dart';
import 'cubit/cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await APIClient.init();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(ThemeMode.light)),
      BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkLoginStatus()),
      BlocProvider<DefectReportCubit>(
        create: (context) => DefectReportCubit(context.read<AuthCubit>()), // Pass AuthCubit to DefectReportCubit
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, ThemeMode>(builder: (context, thememode) {
      return MaterialApp(
          title: 'FireReport',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
              dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
              dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
            ),
          ),
          themeMode: thememode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          home: LoginPage());
    });
  }
}
