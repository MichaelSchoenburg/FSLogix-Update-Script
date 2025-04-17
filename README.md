
# FSLogix Update Script
PowerShell-Skript, welches FSLogix automatisch auf die neueste Version aktualisiert. Gedacht zur Verwendung mit einem RMM-Tool.

## Features

 1.  **Automatisierte FSLogix-Aktualisierung:**
    * **Nutzen:** Spart dem Anwender manuelle Arbeit und Zeit, da die Aktualisierung selbstständig im Hintergrund abläuft. Dies reduziert den administrativen Aufwand erheblich und stellt sicher, dass FSLogix-Installationen auf dem neuesten Stand bleiben.

 2.  **Geplante Ausführung:**
    * **Nutzen:** Ermöglicht die Steuerung, wann die Aktualisierung stattfindet (basierend auf Wochentag und Uhrzeit). Der Anwender kann so Zeitpunkte wählen, die wenig störend für die Benutzer sind (z.B. außerhalb der Geschäftszeiten).

 3.  **Zeitliche Toleranz für die Ausführung:**
    * **Nutzen:** Bietet Flexibilität bei der Ausführungszeit. Wenn das RMM-Tool das Skript nicht exakt zur geplanten Zeit startet, wird die Aktualisierung dennoch innerhalb des konfigurierten Zeitfensters durchgeführt. Dies erhöht die Zuverlässigkeit der automatisierten Aktualisierung.
    * **Hintergedanke:** Damit das Skript zur von Ihnen gewünschten Uhrzeit ausgeführt wird, stellen Sie ein, dass das Skript mehrfach am Tag ausgeführt wird. Je öfter das Skript ausgeführt wird, umso kleiner stellen Sie auch die Toleranz ein.
    * **Beispiel #1:** Das Skript wird jede Stunde ausgeführt. Es soll um 04:00 Uhr morgens ausgeführt werden. Das RMM-Tool startet den stündlichen Rythmus um 00:13 Uhr. Somit wird das Skript um 03:10 und um 04:10, aber nie exakt um 04:00 Uhr ausgeführt. Dafür ist die Toleranz da. Stellen Sie diese etwa auf 30 Minuten ein, würde das Skript in diesem Fall um 04:13 Uhr ausgeführt.
    * **Beispiel #2:** Wird das Skript jede Minute ausgeführt, können Sie die Toleranz auf 1 Minute ein, dann wird das Skript genau zu der Minute ausgeführt, die sie vorbestimmt haben.

 4.  **Optionale Neustartunterdrückung:**
    * **Nutzen:** Der Anwender hat die Kontrolle darüber, ob ein Neustart nach der Aktualisierung automatisch erfolgen soll oder nicht. Dies ist nützlich, um unerwünschte Neustarts während der Arbeitszeit zu vermeiden und diese zentral oder zu einem späteren Zeitpunkt zu planen oder separat zu automatisieren. 

 5. **Validierung der Eingabeparameter:**
    * **Nutzen:** Das Skript überprüft, ob die konfigurierten Variablen (z.B. Downloadpfad, Installationszeit) im korrekten Format vorliegen. Der Anwender wird frühzeitig und sehr konkret auf Konfigurationsfehler hingewiesen, was Fehlfunktionen des Skripts verhindert und Klarheit darüber schafft, exakt war geändert werden muss, damit das Skript starten kann.
    * **Beispiel:** Die detaillierte Fehlermeldung bei falschem Zeitformat ("Ungültiges Zeitformat. Verwende HH:mm.") erleichtert die Korrektur der Konfiguration erheblich.

 6. **Validierung der Eingabeparameter auf gültiges Format:**

    * **Implementierung:** Das Skript prüft, ob der `$DownloadPath` entweder einem gültigen Laufwerksbuchstaben mit folgendem Doppelpunkt und Backslash (z.B. `C:\`) oder einem UNC-Pfad (beginnend mit `\\`) entspricht. Außerdem wird geprüft, ob ungültige Zeichen für Windows-Pfade (<>:"/\|\?\*) enthalten sind.
    * **Beispielhafte Fehlermeldung:**
        * "`$DownloadPath 'ungültiger_pfad' is not a valid Windows path format (e.g., C:\\ or \\\\server\\share)."`
        * "`$DownloadPath 'C:\Datei>' contains invalid characters for a Windows path (<>:\/|\?\*)."`
    * **Nutzen für den Anwender:** Verhindert, dass das Skript in ungültige oder nicht existierende Pfade herunterlädt oder versucht, dort Dateien zu erstellen. Dies vermeidet Fehler im späteren Verlauf des Skripts (z.B. beim Speichern oder Extrahieren der heruntergeladenen Datei) und spart dem Anwender Zeit bei der Fehlersuche, da das Problem direkt bei der Konfiguration erkannt wird.
	 * **Liste der validierten Eingabeparameter :**
		 1. **Validierung der `$DownloadUrl` auf gültiges URL-Schema:**
			* **Implementierung:** Das Skript überprüft, ob die `$DownloadUrl` mit einem der erwarteten Protokolle (`http`, `https`, `ftp`) beginnt.
			* **Beispielhafte Fehlermeldung:** "`$DownloadUrl is not a valid URL scheme (must be http, https, or ftp)."`
			* **Nutzen für den Anwender:** Stellt sicher, dass das Skript versucht, die Datei von einer gültigen Quelle herunterzuladen. Eine URL mit einem unbekannten oder falschen Schema würde zu einem Downloadfehler führen. Die frühzeitige Validierung hilft, solche Fehler zu vermeiden.
		2. **Validierung des `$InstallDay` auf gültige deutsche Wochentage:**
			* **Implementierung:** Das Skript prüft, ob der Wert von `$InstallDay` exakt mit einem der sieben deutschen Wochentage ("Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag") übereinstimmt (Case-sensitive).
			* **Beispielhafte Fehlermeldung:** "`$InstallDay 'Sonntag!' is not a valid German weekday (Montag, Dienstag, Mittwoch, Donnerstag, Freitag, Samstag, Sonntag)."`
			**Nutzen für den Anwender:** Verhindert Tippfehler oder die Verwendung englischer Wochentagsnamen, die dazu führen würden, dass die geplante Ausführung nicht wie erwartet stattfindet. Der Anwender kann sich darauf verlassen, dass die Aktualisierung am gewünschten Tag durchgeführt wird.
		3. **Validierung der `$InstallTime` auf korrektes 24-Stunden-Format:**
			* **Implementierung:** Das Skript verwendet ein reguläres Expressions (`-match '^([01]\d|2[0-3]):([0-5]\d)$'`), um sicherzustellen, dass `$InstallTime` dem Format "HH:mm" entspricht, wobei HH zwischen 00 und 23 und mm zwischen 00 und 59 liegen muss.
			**Beispielhafte Fehlermeldung:** "`$InstallTime '25:00' is not in the valid HH:mm format (00:00 - 23:59)."`
			**Nutzen für den Anwender:** Stellt sicher, dass die geplante Ausführungszeit im korrekten Format angegeben ist und vom Skript fehlerfrei interpretiert werden kann. Falsche Zeitformate würden die geplante Ausführung unvorhersehbar machen.
		4. **Validierung von `$MinutesTolerance` auf gültigen numerischen Bereich:**
			* **Implementierung:** Das Skript prüft, ob `$MinutesTolerance` eine gültige ganze Zahl ist und ob dieser Wert innerhalb eines sinnvollen Bereichs liegt (hier 0 bis 720 Minuten, also 12 Stunden).
			* **Beispielhafte Fehlermeldung:**
		        * "`$MinutesTolerance 'abc' is not a valid integer."`
		        * "`$MinutesTolerance '-5' is not within the valid range (0-720)."`
			* **Nutzen für den Anwender:** Verhindert die Verwendung ungültiger oder unsinniger Toleranzwerte, die zu unerwartetem Verhalten des Skripts bei der Überprüfung der Ausführungszeit führen könnten. Ein negativer Wert oder ein extrem hoher Wert wäre nicht sinnvoll.

		5. **Validierung von `$Restart` auf gültige numerische Werte:**
			* **Implementierung:** Das Skript prüft, ob `$Restart` eine gültige ganze Zahl ist und ob dieser Wert entweder 0 oder 1 ist (die erwarteten Steuerungsoptionen).
			* **Beispielhafte Fehlermeldung:**
				* "`$Restart 'ja' is not a valid integer."`
		        * "`$Restart '2' is not within the valid range (0-1)."`
		    * **Nutzen für den Anwender:** Stellt sicher, dass nur die zulässigen Werte für die Neustartsteuerung verwendet werden. Andere Werte würden vom Skript nicht korrekt interpretiert werden und könnten zu unerwarteten Neustartverhalten führen.

6.  **Integrierte Fehlerbehandlung:**
    * **Nutzen:** Fängt Fehler während des Download-, Extraktions- und Installationsprozesses ab und protokolliert diese. Der Anwender erhält dadurch klare Informationen, wenn etwas schiefgelaufen ist, anstatt dass der Prozess unbemerkt abbricht.

7.  **Detaillierte Protokollierung (Ausgabe):**
    * **Nutzen:** Liefert umfassende Informationen über den Ablauf des Skripts. Der Anwender kann genau nachvollziehen, welche Schritte durchgeführt wurden, ob diese erfolgreich waren oder wo Probleme aufgetreten sind. Dies ist entscheidend für die Überwachung und das Troubleshooting.

8.  **Prüfung und Ausgabe der aktuellen und neuen FSLogix-Version:**
    * **Nutzen:** Der Anwender erhält über die Ausgabe die Information, welche FSLogix-Version vor und nach der Aktualisierung installiert ist. Dies ermöglicht eine einfache Überprüfung des Erfolgs der Aktualisierung. Außerdem: Falls Sie sich mal nicht sicher sind, welche Version ein bestimmter Kunde im Einsatz hat, ist dieses Skript Ihre zentrale Anlaufstelle -- hier können Sie immer ablesen, welche Version gerad genutzt wird. Auch können Sie den Verlauf, wann auf welche Version gewechselt wurde nachvollziehen.

9.  **Erkennung und Meldung erforderlicher Neustarts:**
    * **Nutzen:** Informiert den Anwender (über den Exit-Code und die Konsolenausgabe), wenn ein Neustart für die vollständige Installation notwendig ist. Dies hilft, Probleme durch ausbleibende Neustarts zu vermeiden.

11. **Automatisierte Bereinigung:**
    * **Nutzen:** Entfernt nach der Aktualisierung automatisch die heruntergeladene ZIP-Datei und die extrahierten Dateien. Dies hält das System sauber und vermeidet unnötigen Speicherverbrauch im angegebenen Downloadpfad.

12. **Rückmeldung über Exit-Codes:**
    * **Nutzen:** Ermöglicht dem RMM-Tool eine einfache und automatisierte Auswertung des Ergebnisses der Skriptausführung. Basierend auf dem Exit-Code kann das RMM-Tool beispielsweise Benachrichtigungen versenden oder weitere Schritte einleiten.

Durch diese Features bietet das Skript dem Anwender eine zuverlässige, flexible und gut nachvollziehbare Lösung für die automatisierte Aktualisierung von FSLogix, wodurch der administrative Aufwand reduziert und die Stabilität der FSLogix-Umgebung verbessert wird. Die detaillierten Ausgaben erleichtern dabei die Überwachung und Fehlerbehebung im Falle von Problemen erheblich.

## Eingaben/Variablen

**1. `$Restart`**

* **Zweck:** Diese Variable bestimmt, ob das Skript das FSLogix-Installationsprogramm anweisen soll, nach dem Installations-/Aktualisierungsprozess einen Systemneustart durchzuführen.
* **Werte:**
    * `0`: Gibt an, dass das Skript dem FSLogix-Installationsprogramm erlauben soll, bei Bedarf einen Systemneustart einzuleiten.
    * `1`: Gibt an, dass das Skript das FSLogix-Installationsprogramm anweisen soll, jeden automatischen Systemneustart zu unterdrücken, auch wenn die Installation normalerweise einen erfordern würde.
* **Konfiguration:** Sie konfigurieren diese Variable, indem Sie ihr entweder die ganze Zahl `0` oder `1` zuweisen. Dies geschieht in der Regel über Ihr RMM-Tool (Remote Monitoring and Management) beim Bereitstellen oder Planen des Skripts. Zum Beispiel:
    ```powershell
    $Restart = 0  # Um einen Neustart zu erlauben
    $Restart = 1  # Um einen Neustart zu verhindern
    ```
* **Überlegungen:**
    * **`0` (Neustart zulassen):** Dies ist im Allgemeinen die sicherere Option, um sicherzustellen, dass die FSLogix-Installation korrekt abgeschlossen wird, da einige Aktualisierungen möglicherweise einen Neustart erfordern, um vollständig wirksam zu werden.
    * **`1` (Neustart verhindern):** Sie könnten diese Option wählen, wenn Sie Neustarts aus betrieblichen Gründen (z. B. während der Geschäftszeiten) steuern müssen und planen, später auf andere Weise einen Neustart einzuleiten. Beachten Sie jedoch, dass das Unterdrücken notwendiger Neustarts zu unvollständigen Installationen oder unerwartetem Verhalten führen kann.

**2. `$MinutesTolerance`**

* **Zweck:** Diese Variable definiert ein Zeitfenster (in Minuten) um die angegebene `$InstallTime`, innerhalb dessen das Skript die FSLogix-Aktualisierung durchführen darf. Dies verleiht der geplanten Ausführungszeit Flexibilität.
* **Werte:** Eine positive ganze Zahl, die die Anzahl der Minuten darstellt.
* **Konfiguration:** Sie konfigurieren diese Variable, indem Sie ihr über Ihr RMM-Tool einen positiven ganzzahligen Wert zuweisen. Zum Beispiel:
    ```powershell
    $MinutesTolerance = 15  # Ausführung innerhalb von 15 Minuten vor oder nach der InstallTime erlauben
    $MinutesTolerance = 60  # Ausführung innerhalb von 60 Minuten (1 Stunde) vor oder nach der InstallTime erlauben
    ```
* **Funktionsweise:** Die Funktion `Check-Scheduled-Time` berechnet die Differenz zwischen der aktuellen Zeit und der `$InstallTime`. Wenn der absolute Wert dieser Differenz (in Minuten) kleiner als `$MinutesTolerance` ist, gibt die Funktion `$true` zurück, und das Skript fährt mit der Aktualisierung fort.
* **Überlegungen:**
    * Eine geringere Toleranz macht die Ausführungszeit präziser.
    * Eine größere Toleranz bietet mehr Flexibilität, falls die Skriptausführung von Ihrem RMM nicht perfekt pünktlich erfolgt.

**3. `$InstallTime`**

* **Zweck:** Diese Variable gibt die genaue Uhrzeit (im 24-Stunden-Format) an, zu der das Skript versuchen soll, die FSLogix-Aktualisierung durchzuführen, vorausgesetzt, es ist auch der `$InstallDay`.
* **Werte:** Eine Zeichenkette im Format "HH:mm" (z. B. "04:00" für 4:00 Uhr morgens, "18:30" für 18:30 Uhr).
* **Konfiguration:** Sie konfigurieren diese Variable, indem Sie ihr über Ihr RMM-Tool eine Zeichenkette zuweisen, die die gewünschte Zeit im 24-Stunden-Format darstellt. Zum Beispiel:
    ```powershell
    $InstallTime = "03:30"  # Setzt die Installationszeit auf 3:30 Uhr morgens
    $InstallTime = "22:00"  # Setzt die Installationszeit auf 22:00 Uhr
    ```
* **Funktionsweise:** Die Funktion `Check-Scheduled-Time` vergleicht die aktuelle Zeit mit dieser `$InstallTime`. Sie verwendet auch die `$MinutesTolerance`, um die Ausführung innerhalb eines bestimmten Zeitfensters um diese Zeit zu ermöglichen.
* **Überlegungen:** Wählen Sie eine Zeit, zu der die Systeme wahrscheinlich weniger ausgelastet sind, um Störungen zu minimieren.

**4. `$InstallDay`**

* **Zweck:** Diese Variable gibt den Wochentag (auf Deutsch) an, an dem das Skript in Verbindung mit der `$InstallTime` versuchen soll, die FSLogix-Aktualisierung durchzuführen.
* **Werte:** Eine Zeichenkette, die einen deutschen Wochentag darstellt: "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag".
* **Konfiguration:** Sie konfigurieren diese Variable, indem Sie ihr über Ihr RMM-Tool den deutschen Namen des gewünschten Wochentags zuweisen. Zum Beispiel:
    ```powershell
    $InstallDay = "Sonntag"  # Setzt den Installationstag auf Sonntag
    $InstallDay = "Mittwoch" # Setzt den Installationstag auf Mittwoch
    ```
* **Funktionsweise:** Die Funktion `Check-Scheduled-Time` vergleicht den aktuellen Wochentag (auf Deutsch) mit dem Wert von `$InstallDay`. Das Skript wird die Aktualisierung nur durchführen, wenn der aktuelle Tag mit `$InstallDay` übereinstimmt und die aktuelle Zeit innerhalb der Toleranz von `$InstallTime` liegt.
* **Überlegungen:** Wählen Sie einen Tag, an dem die Systeme wahrscheinlich weniger ausgelastet sind, z. B. Wochenenden oder außerhalb der Hauptgeschäftszeiten.

**5. `$DownloadPath`**

* **Zweck:** Diese Variable gibt den lokalen Dateisystempfad auf dem Zielcomputer an, in den die FSLogix-Installer-ZIP-Datei heruntergeladen wird. Das Skript erstellt auch einen Unterordner innerhalb dieses Pfads, um die Installationsdateien zu extrahieren.
* **Werte:** Eine Zeichenkette, die einen gültigen lokalen Dateisystempfad darstellt. Zum Beispiel: `"C:\Temp\FSLogix"`, `"D:\SoftwareUpdates\FSLogix"`, `"\\server\freigabe\FSLogixDownloads"`.
* **Konfiguration:** Sie konfigurieren diese Variable, indem Sie ihr über Ihr RMM-Tool eine Zeichenkette zuweisen, die den gewünschten Downloadpfad darstellt. Zum Beispiel:
    ```powershell
    $DownloadPath = "C:\FSLogixUpdate"
    $DownloadPath = "\\dateiserver\Software\FSLogix"
    ```
* **Überlegungen:**
    * Stellen Sie sicher, dass der angegebene Pfad existiert oder dass das System, auf dem das Skript ausgeführt wird, die erforderlichen Berechtigungen zum Erstellen besitzt. Das Skript enthält Logik, um das Verzeichnis zu erstellen, falls es nicht vorhanden ist.
    * Der Pfad sollte genügend freien Speicherplatz haben, um die FSLogix-ZIP-Datei herunterzuladen und deren Inhalt zu extrahieren.
    * Die Verwendung eines dedizierten Ordners für Downloads kann zur Organisation und Bereinigung beitragen (da das Skript versucht, die heruntergeladene ZIP-Datei und den extrahierten Ordner im `finally`-Block zu löschen).

**Zusammenfassend:** Diese Eingabevariablen bieten eine entscheidende Konfiguration für das FSLogix-Update-Skript und ermöglichen es Ihnen, zu steuern, *wann* das Update erfolgt, *wie* es Neustarts behandelt und *wohin* die erforderlichen Dateien heruntergeladen werden. Sie werden diese Variablen in der Regel in den Bereitstellungs- oder Planungseinstellungen Ihres RMM-Tools für jeden Zielcomputer oder jede Gruppe von Computern festlegen. Das Skript verwendet diese Variablen dann, um Entscheidungen darüber zu treffen, ob und wie mit dem FSLogix-Update fortgefahren werden soll.

## Wie setzte/definiere ich Variablen?
Das Skript setzt voraus, dass das RMM-Tool die Variablen während der Ausführung festlegt. Dies geschieht beispielsweise mit Riversuite Riverbird.

## Exit Codes
Exit Code 0 = Erfolgreich

Exit Code 1 = Fehler

Exit Code 2 = Warnung
