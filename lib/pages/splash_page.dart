import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firereport/notifier/notifier.dart';
import 'pages.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authCheckProvider).when(
      data: (_) {
        final authState = ref.read(authProvider);
        if (authState == AuthState.unauthenticated) {
          return LoginPage();
        } else if (authState == AuthState.authenticated || authState == AuthState.anonymous) {
          return const DefectReportPage(); 
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
