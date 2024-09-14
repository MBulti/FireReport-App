import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/pages.dart';
import 'cubit/cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://gtjwpkqnehchegvxesva.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0andwa3FuZWhjaGVndnhlc3ZhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjM1Mzg0OTYsImV4cCI6MjAzOTExNDQ5Nn0.7ZAHS7OOwcJy3ooTwhMVKhgbih6bLYvSvQ44A8-vC3M");
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => SettingsCubit(ThemeMode.light)),
      BlocProvider(create: (_) => AuthCubit()..checkLoginStatus()),
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
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: thememode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
          ],
          home: LoginPage());
    });
  }
}
