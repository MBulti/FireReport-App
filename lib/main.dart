import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firereport/utils/api_client.dart';
import 'package:firereport/utils/theme.dart';
import 'notifier/notifier.dart';
import 'pages/pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await APIClient.init();
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
        title: 'FireReport',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ref.watch(themeProvider),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        home: const SplashPage());

    //   return BetterFeedback(
    //     localizationsDelegates: [
    //       GlobalFeedbackLocalizationsDelegate(),
    //     ],
    //     themeMode: ThemeMode.light,
    //     theme: feedbackLightTheme,
    //     child: MaterialApp(
    //         title: 'FireReport',
    //         debugShowCheckedModeBanner: false,
    //         theme: lightTheme,
    //         darkTheme: darkTheme,
    //         themeMode: ref.watch(themeProvider),
    //         localizationsDelegates: const [
    //           GlobalMaterialLocalizations.delegate,
    //           GlobalWidgetsLocalizations.delegate
    //         ],
    //         home: const SplashPage()),
    //   );
  }
}
