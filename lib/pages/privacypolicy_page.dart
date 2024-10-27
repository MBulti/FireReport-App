import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datenschutzerklärung')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
1. Verantwortlicher für die Datenverarbeitung

Verantwortlich für die Datenverarbeitung in dieser App ist:

Moritz Bulthaup  
m.bulthaup.development@gmail.com

2. Zugriff auf die App und GitHub-Hosting

Unsere App ist als Open-Source-Projekt öffentlich auf GitHub verfügbar. Informationen zur App und dem Quellcode findest du unter https://github.com/MBulti/FireReport-App.

3. Nutzung von Supabase als Backend und Account-Verwaltung

Die App nutzt Supabase als Datenbank und Backend-Service. Supabase dient zur Authentifizierung und Speicherung der Nutzerdaten, wie z. B. Accounts und anwendungsspezifische Daten. Alle personenbezogenen Daten werden sicher in der Supabase-Datenbank verarbeitet und gespeichert.

Verarbeitete Daten über Supabase:
- Account-Daten: Benutzername, E-Mail-Adresse und andere für die Authentifizierung erforderliche Informationen.
- Nutzungsdaten: Daten, die während der Nutzung der App anfallen (z. B. Aktivitätsprotokolle), werden anonymisiert und können zur Analyse und Verbesserung der App verwendet werden.

4. Zweck der Datenverarbeitung und Rechtsgrundlagen

Die Datenverarbeitung erfolgt zu folgenden Zwecken:
- Bereitstellung der App-Funktionalitäten: Verarbeitung der Account-Daten zur Authentifizierung und Nutzung der App.
- Sicherstellung der Sicherheit der App: Verarbeitung zur Gewährleistung eines sicheren Betriebs der App.
- Analyse und Verbesserung der App: Anonymisierte Daten werden analysiert, um die Benutzererfahrung zu verbessern.

Die Rechtsgrundlage für die Verarbeitung ist Art. 6 Abs. 1 lit. b DSGVO (Erfüllung eines Vertrages) und Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse zur Sicherstellung der Funktionsfähigkeit und Sicherheit der App).

5. Speicherdauer

Personenbezogene Daten werden nur so lange gespeichert, wie dies für die Bereitstellung der App und zur Erfüllung des Zwecks erforderlich ist. Wenn der Zweck der Speicherung entfällt oder der Nutzer die Nutzung beendet, werden die Daten gelöscht, sofern keine gesetzlichen Aufbewahrungsfristen bestehen.

6. Übermittlung von Daten an Dritte

Daten werden grundsätzlich nicht an Dritte weitergegeben, außer:
- es besteht eine gesetzliche Verpflichtung zur Weitergabe,
- oder die Weitergabe ist zur Erfüllung der App-Dienstleistungen erforderlich.

Daten werden in der Supabase-Datenbank gespeichert, die unter Umständen Server in Drittländern betreibt. Die Übermittlung erfolgt in Übereinstimmung mit den geltenden Datenschutzbestimmungen und, soweit erforderlich, durch den Einsatz von Standardvertragsklauseln der EU zur Gewährleistung eines angemessenen Datenschutzniveaus.

7. Betroffenenrechte

Gemäß der DSGVO hast du folgende Rechte in Bezug auf deine personenbezogenen Daten:
- Recht auf Auskunft über die von uns verarbeiteten Daten (Art. 15 DSGVO)
- Recht auf Berichtigung unrichtiger oder unvollständiger Daten (Art. 16 DSGVO)
- Recht auf Löschung der gespeicherten Daten (Art. 17 DSGVO)
- Recht auf Einschränkung der Verarbeitung (Art. 18 DSGVO)
- Recht auf Datenübertragbarkeit (Art. 20 DSGVO)
- Widerspruchsrecht gegen die Verarbeitung personenbezogener Daten (Art. 21 DSGVO)

Um diese Rechte auszuüben, kontaktiere uns bitte über die oben genannten Kontaktdaten.

8. Beschwerderecht bei der Aufsichtsbehörde

Solltest du der Ansicht sein, dass die Verarbeitung deiner Daten gegen die DSGVO verstößt, hast du das Recht, eine Beschwerde bei der zuständigen Datenschutzaufsichtsbehörde einzureichen.

9. Änderungen der Datenschutzerklärung

Wir behalten uns das Recht vor, diese Datenschutzerklärung bei Bedarf anzupassen, um sie an Änderungen in der App oder an neue rechtliche Vorgaben anzupassen. Die jeweils aktuelle Version ist jederzeit in der App einsehbar.

Stand der Datenschutzerklärung: Oktober 2024
          ''',
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
