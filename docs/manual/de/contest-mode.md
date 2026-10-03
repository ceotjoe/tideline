# Contest-Modus

Der Contest-Modus ist ein schneller, kompakter Logbildschirm für Contests. Er funktioniert vollständig offline.
Laufende Nummern, Dupe-Prüfung, Punktzahl und Raten werden auf deinem Gerät berechnet. Contest-QSOs sind ganz normale
QSOs in deinem Log und werden wie alle anderen mit Wavelog synchronisiert.

## Eine Sitzung starten

1. Öffne den **Contest-Modus** über die Schaltfläche oben im Log-Bildschirm oder mit **⇧⌘C** (**Strg+Umschalt+C**).
2. Wähle den **Contest**. Mit **Contests suchen** filterst du die Liste. Jeder Contest ist als **Eingebaut** oder
   **Von dir importiert** gekennzeichnet.
3. Wähle die **Station**. Sie ist nötig, damit die QSOs synchronisiert werden können.
4. Prüfe **Mein Exchange**. Tideline füllt aus, was es von der Station weiß, zum Beispiel deine CQ-Zone oder deinen DOK.
   Felder, die dein Exchange nicht braucht, werden nicht angezeigt.
5. Setze bei Bedarf die **Cabrillo-Kategorien** (Betreiber, Unterstützung, Band, Betriebsart, Leistung, Stationstyp,
   Sender, Overlay, Zeit). Sie werden nur für den Cabrillo-Export gebraucht. Leistung, Stationstyp und Overlay stehen
   absichtlich auf **Nicht gesetzt**, damit du diese Angaben selbst machst.
6. Tippe auf **Sitzung starten**.

Solange eine Sitzung läuft, zeigt der Log-Bildschirm den Hinweis „Contest-Sitzung läuft“ mit **Zurück zum Contest**.
Eine beendete Sitzung kannst du unter **Frühere Sitzungen** wieder öffnen.

## Loggen

Die Eingabe folgt dem Exchange des Contests: zuerst das Rufzeichen, dann der empfangene Exchange (zum Beispiel RST und
CQ-Zone oder RST und laufende Nummer). Darüber steht, was du sendest, einschließlich der **nächsten laufenden Nummer**.

- Die **Eingabetaste** loggt das QSO, aber nur, wenn es vollständig ist. Ist das Rufzeichen leer, springt sie zum
  Rufzeichen. Fehlt ein Teil des Exchange, springt sie zum ersten fehlenden Feld.
- **Leertaste** oder **Tab** springt zum nächsten Feld.
- **Esc** leert die Eingabe.
- Nach dem Loggen werden Rufzeichen und empfangene Felder geleert; Band, Betriebsart und Frequenz bleiben. Der
  Screenreader sagt „geloggt“, das Rufzeichen Buchstabe für Buchstabe und die laufende Nummer an.
- **Bild auf** und **Bild ab** wechseln das Band, **⌘M** (**Strg+M**) die Betriebsart. Das Frequenzfeld funktioniert wie
  im normalen Log: `14025`, `14.025` und `1840` werden alle verstanden.

Auf einem Touchscreen nutzt du die Schaltfläche **QSO loggen**. Alle Schaltflächen sind mindestens 48 dp groß, im
Handschuhmodus größer.

**Tablet im Querformat:** Rufzeichen, empfangener Exchange, Band, Betriebsart und Frequenz stehen in einer Zeile über
die ganze Breite. Darunter folgen die Hinweise und der gesendete Exchange, dann die Frequenzanzeige und die
Schaltflächen. Unten siehst du deine letzten QSOs und das Punktefeld. Bei geöffneter Bildschirmtastatur bleibt alles
ohne Scrollen sichtbar, und die obere Leiste wird ausgeblendet, bis du die Tastatur schließt.

### Laufende Nummern

Deine laufende Nummer wird in dem Moment vergeben, in dem das QSO gespeichert wird, im selben Schritt wie das QSO selbst.
Die Nummer, die vorher angezeigt wird, ist nur eine Vorschau. Laufende Nummern werden nie wiederverwendet: Löschst du ein
QSO, bleibt seine Nummer vergeben, und das nächste QSO bekommt die nächste Nummer. Beim Bearbeiten eines QSOs ändert sich
die gesendete Nummer nie.

## Hinweise beim Tippen

Unter dem Rufzeichen zeigt Tideline, was es weiß, immer als Symbol mit Text:

| Hinweis | Bedeutung |
|---|---|
| Dupe | Du hast die Station schon auf diesem Band gearbeitet (und in dieser Betriebsart, wenn der Contest Betriebsarten getrennt zählt). Mit der Eingabetaste wird ein Dupe trotzdem geloggt. Es wird markiert und zählt 0 Punkte. |
| Bereits gearbeitet auf … | In diesem Contest gearbeitet, aber auf einem anderen Band oder in einer anderen Betriebsart, also hier kein Dupe. |
| Neuer Multiplikator | Dieses QSO brächte einen Multiplikator, zum Beispiel eine neue Zone, ein neues Land, Präfix oder einen neuen DOK. |
| Außerhalb der Bänder oder Betriebsarten dieses Contests | Das QSO zählt 0 Punkte. |
| Im Log | Schon einmal in deinem gesamten Log gearbeitet: neues Band, neue Betriebsart, neue Kombination oder schon gearbeitet. |
| Super Check | Rufzeichen aus der MASTER.SCP-Liste, die das Getippte enthalten. Tippe eines an, um es zu übernehmen. |
| Meintest du | Rufzeichen aus der Liste, die sich um ein Zeichen unterscheiden. Erscheint, wenn das Getippte nicht in der Liste steht. |

### Die Super-Check-Partial-Liste (MASTER.SCP)

Tideline liefert die Liste nicht mit, weil wir sie nicht verbreiten dürfen. Du installierst sie unter **Einstellungen →
Super Check Partial**:

- **Herunterladen** lädt die Liste von der angezeigten Adresse. Voreingestellt ist
  `https://www.supercheckpartial.com/MASTER.SCP`; du kannst sie ändern. Es sind nur `https`-Adressen erlaubt, und die
  Datei darf höchstens 8 MiB groß sein. Tideline kontaktiert diese Adresse nur, wenn du auf Herunterladen tippst, und
  sendet nichts über dich.
- **Datei importieren** installiert eine MASTER.SCP-Datei, die du schon hast.
- **Entfernen** löscht die Liste.

## Punkte und Raten

Der Bereich **Punkte und Raten** zeigt QSOs, Punkte, Multiplikatoren, Dupes, die Wertung je Band und diese Raten:

- die letzten 10 und die letzten 60 Minuten, hochgerechnet auf QSOs pro Stunde;
- die letzten 10 und die letzten 100 QSOs, als QSOs pro Stunde;
- deine bisher besten 60 Minuten.

Die **beanspruchte Punktzahl ist eine Schätzung**. Sie folgt den Regeln des Contests, so wie Tideline sie kennt; maßgeblich
ist aber allein die Logprüfung des Veranstalters. Mit **⌘R** (**Strg+R**) blendest du den Bereich ein oder aus. Auf dem
Telefon ist er anfangs eingeklappt und zeigt eine einzeilige Zusammenfassung.

## Bearbeiten, ohne den Contest-Modus zu verlassen

Wähle ein QSO unter **Letzte QSOs** oder drücke **⌘E** (**Strg+E**) für das letzte. Rufzeichen, Band, Betriebsart und
empfangenen Exchange änderst du direkt in der Liste. Der gesendete Exchange einschließlich der laufenden Nummer ist nicht
änderbar. Vor dem Löschen fragt Tideline nach. Nach jeder Änderung wird die Wertung neu berechnet.

## Eine Sitzung beenden

Drücke **⇧⌘E** (**Strg+Umschalt+E**) oder wähle oben im Contest-Bildschirm **Contest-Sitzung beenden** (das Stopp-Symbol).
Tideline fragt vorher nach. Deine QSOs bleiben im Log, und du kannst die Sitzung später wieder öffnen.

## Wavelog-Status einer Sitzung

Deine QSOs werden immer mit dem ADIF-Namen des Contests (`CONTEST_ID`) und ihren Exchange-Feldern hochgeladen. Ab
**Wavelog 3.2** und mit einem Token, das `contest:write` hat, legt Tideline die Sitzung zusätzlich auf Wavelog an und
verknüpft ihre QSOs damit. Der Contest-Bildschirm und die Liste früherer Sitzungen zeigen, wo eine Sitzung steht, immer
als Symbol mit Text:

| Zustand | Bedeutung |
|---|---|
| Nur auf diesem Gerät | Die Sitzung wird nicht auf Wavelog gespiegelt. Der Grund steht hinter dem Doppelpunkt, zum Beispiel ein alter Server (vor 3.2), ein Contest, der auf dem Server nicht aktiviert ist, oder ein Token ohne `contest:write`. |
| Wartet auf Upload zu Wavelog | Die Sitzung wird auf Wavelog angelegt, sobald eines ihrer QSOs hochgeladen ist. |
| Wird auf Wavelog geprüft | Eine Anfrage zum Anlegen ging verloren. Tideline prüft, ob Wavelog die Sitzung schon hat, bevor es es noch einmal versucht. |
| Auf Wavelog | Die Sitzung existiert auf Wavelog, und ihre QSOs sind damit verknüpft. |

Dein Log ist in jedem Fall vollständig. Die Sitzung auf Wavelog ist eine optionale Ergänzung. Löschst du die Sitzung in
Wavelog, legt Tideline sie nicht erneut an.

## Ein Cabrillo-Log exportieren

Wähle im Contest-Bildschirm im Menü (die drei Punkte) **Cabrillo-Log exportieren**, drücke **⇧⌘X**
(**Strg+Umschalt+X**) oder nutze die Schaltfläche auf einer Karte in der Liste früherer Sitzungen. Tideline:

1. Baut das Log aus der Sitzung: dein Rufzeichen und Locator von der Station, die Kategorien aus der Einrichtung der
   Sitzung, die beanspruchte Punktzahl aus der Wertung und eine `QSO:`-Zeile je Verbindung.
2. Prüft es und listet Probleme auf (zum Beispiel einen leeren Exchange-Wert, der als `-` geschrieben wird). Du kannst
   abbrechen oder trotzdem exportieren.
3. Fragt, wo es gespeichert werden soll. Der vorgeschlagene Name ist `RUFZEICHEN-CONTEST-JAHR.log`, zum Beispiel
   `DO1HOZ-DARC-WAG-2026.log`.

Hinweise:

- Ein Contest, dessen Definition keinen Cabrillo-Namen hat, kann nicht exportiert werden. Tideline zeigt dafür einen
  Hinweis. Nutze dann den ADIF-Export in den Einstellungen oder ergänze einen `cabrillo`-Namen in der Definition.
- Wenn der Exchange von der Station abhängt (WAG: laufende Nummer aus dem Ausland, DOK aus Deutschland), teilen sich
  beide eine Spalte im Log.
- Ein QSO ohne Frequenz bekommt die untere Bandgrenze seines Bandes (`14000` für 20 m), wie Contest-Logger es üblicherweise
  schreiben.
- Dupes werden mit exportiert, wie die Veranstalter es erwarten. Ihre Logprüfung entfernt sie.
- Die beanspruchte Punktzahl ist eine Schätzung. Prüfe sie anhand der Contest-Regeln, bevor du das Log einschickst.
- Freitext wird als reines ASCII geschrieben: aus `ä` wird `ae` und so weiter.

## Contest-Definitionen

Jeder Contest ist eine kleine Datendatei, die Exchange, Dupe-Regel, Punkte und Multiplikatoren beschreibt. Tideline
bringt mit:

- CQ World Wide DX (SSB, CW);
- CQ WPX (SSB, CW);
- ARRL International DX (CW, SSB);
- IARU HF World Championship;
- DARC Worked All Germany (WAG);
- zwei allgemeine Contests, einen mit laufender Nummer und einen mit freiem Exchange, für alles andere.

Die mitgelieferten Regeln wurden am 2026-10-02 mit den Regeln der Veranstalter abgeglichen. Regeln ändern sich, prüfe sie
also vor einem Contest. Bekannte Vereinfachungen stehen in `app/assets/contests/README.md`, zum Beispiel dass reine
WAE-Länder keine eigenen Multiplikatoren sind.

Unter **Einstellungen → Contest-Definitionen** kannst du mit **Definition importieren** eine JSON-Datei bis 256 KiB
hinzufügen und von dir importierte Definitionen löschen. Eine Definition, die eine Sitzung verwendet, lässt sich nicht
löschen. Tideline prüft eine importierte Datei streng und sagt, was nicht stimmt, wenn es sie ablehnt. Das Dateiformat
ist in [contest-definitions.md](../../architecture/contest-definitions.md) beschrieben (Englisch).
