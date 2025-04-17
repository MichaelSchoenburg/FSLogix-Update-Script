# FSLogix Update Skript

Ein PowerShell-Skript zur automatischen Aktualisierung von FSLogix auf die neueste Version. Konzipiert für den Einsatz mit einem RMM-Tool.

## Features

1.  **Automatisierte FSLogix-Aktualisierung:**

    * **Nutzen:** Reduziert manuellen Aufwand und spart Zeit durch selbstständige Hintergrundaktualisierung. Gewährleistet, dass FSLogix-Installationen stets auf dem neuesten Stand sind.

2.  **Geplante Ausführung:**

    * **Nutzen:** Ermöglicht die präzise Steuerung des Aktualisierungszeitpunkts (Wochentag und Uhrzeit), um Störungen für Benutzer zu minimieren (z.B. außerhalb der Geschäftszeiten).

3.  **Flexible Ausführungszeit durch Toleranz:**

    * **Nutzen:** Erhöht die Zuverlässigkeit der geplanten Ausführung, indem eine konfigurierbare Zeitspanne (`$MinutesTolerance`) um die geplante Uhrzeit toleriert wird. Dies kompensiert mögliche Ungenauigkeiten bei der Skriptausführung durch das RMM-Tool.
    * **Hintergedanke:** Für eine präzisere Ausführung bei häufiger Skriptausführung (z.B. stündlich oder minütlich) kann die Toleranz entsprechend angepasst werden.
    * **Beispiele:**
        * **Stündliche Ausführung, Ziel 04:00 Uhr:** Bei einer Toleranz von 30 Minuten würde das Skript zwischen 03:30 Uhr und 04:30 Uhr ausgeführt.
        * **Minütliche Ausführung, exakte Zielzeit:** Eine Toleranz von 1 Minute ermöglicht die Ausführung genau in der konfigurierten Minute.

4.  **Optionale Neustartunterdrückung:**

    * **Nutzen:** Gibt dem Anwender die Kontrolle über automatische Neustarts nach der Aktualisierung. Ermöglicht die Vermeidung von Störungen während der Arbeitszeit und die zentrale oder separate Planung/Automatisierung von Neustarts.

5.  **Umfassende Validierung der Eingabeparameter:**

    * **Nutzen:** Erkennt Konfigurationsfehler frühzeitig und informiert den Anwender präzise über das Problem und die erforderliche Korrektur. Verhindert Skriptausführungsfehler und spart Zeit bei der Fehlersuche.
    * **Beispiel:** Die Fehlermeldung "`Ungültiges Zeitformat. Verwende HH:mm.`" bei fehlerhafter `$InstallTime` erleichtert die Korrektur.
    * **Validierte Parameter:**
        * `$DownloadPath`: Gültiges Windows-Pfadformat (Laufwerksbuchstabe:\\ oder \\Server\\Freigabe) und keine ungültigen Zeichen.
        * `$DownloadUrl`: Gültiges URL-Schema (`http`, `https`, `ftp`).
        * `$InstallDay`: Gültiger deutscher Wochentag (case-sensitive).
        * `$InstallTime`: Korrektes 24-Stunden-Format (HH:mm).
        * `$MinutesTolerance`: Gültige positive Ganzzahl innerhalb des sinnvollen Bereichs (0-720 Minuten).
        * `$Restart`: Gültige Ganzzahl (0 oder 1).

6.  **Integrierte Fehlerbehandlung:**

    * **Nutzen:** Fängt Fehler während des gesamten Prozesses (Download, Extraktion, Installation) ab und protokolliert diese detailliert. Der Anwender erhält klare Informationen über Fehlerursachen.

7.  **Detaillierte Protokollierung (Ausgabe):**

    * **Nutzen:** Bietet eine umfassende Nachvollziehbarkeit aller Skriptaktionen, inklusive Erfolgs- und Fehlermeldungen. Unterstützt die Überwachung und gezielte Fehlersuche.

8.  **Überprüfung und Ausgabe der FSLogix-Versionen:**

    * **Nutzen:** Zeigt die vor und nach der Aktualisierung installierte FSLogix-Version an. Ermöglicht eine einfache Erfolgskontrolle und dient als zentrale Informationsquelle zur aktuellen und historischen Versionsübersicht der verwalteten Systeme.

9.  **Erkennung und Meldung erforderlicher Neustarts:**

    * **Nutzen:** Informiert den Anwender explizit (per Exit-Code und Ausgabe), wenn ein Neustart zur vollständigen Installation notwendig ist, um Probleme durch ausbleibende Neustarts zu verhindern.

10. **Automatisierte Bereinigung:**

    * **Nutzen:** Entfernt temporäre Dateien (heruntergeladene ZIP-Datei und extrahierte Dateien) nach der Aktualisierung, um Speicherplatz zu sparen und das System sauber zu halten.

11. **Klare Rückmeldung über Exit-Codes:** \* **Nutzen:** Ermöglicht dem RMM-Tool eine einfache, automatisierte Auswertung des Skriptergebnisses zur Steuerung weiterer Aktionen (z.B. Benachrichtigungen, Neustartplanung).

## Eingaben/Variablen

Dieses Skript erwartet, dass das RMM-Tool die folgenden Variablen zur Laufzeit (Beispiel: Riversuite Riverbird) definiert:

1.  `$Restart`: Steuert den Neustart nach der Installation (`0` = zulassen, `1` = unterdrücken).

2.  `$MinutesTolerance`: Toleranz in Minuten für die geplante Ausführungszeit.

3.  `$InstallTime`: Geplante Ausführungszeit im 24-Stunden-Format (HH:mm).

4.  `$InstallDay`: Geplanter Wochentag (Deutsch: Montag, Dienstag, ...).

5.  `$DownloadPath`: Lokaler Pfad für den Download der FSLogix-Installationsdatei.

## Exit Codes

* `0`: Erfolgreich
* `1`: Fehler
* `2`: Warnung (Aktualisierung erfolgreich, Neustart erforderlich)
