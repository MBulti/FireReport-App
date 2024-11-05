import 'package:flutter/material.dart';

class ImprintPage extends StatelessWidget {
  const ImprintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impressum')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Moritz Bulthaup
Mitglied im Löschzug Kilver e.V.
E-Mail: m.bulthaup.development@gmail.com

Löschzug Kilver e.V.
Zur Alten Schmiede 2
32289 Rödinghausen
Deutschland
          ''',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
