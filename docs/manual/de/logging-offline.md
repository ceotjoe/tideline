# Offline loggen

Jedes QSO wird in dem Moment auf deinem Gerät gespeichert, in dem du es loggst – mit oder ohne Verbindung. Die
Synchronisierung läuft getrennt davon und lässt dich nie warten.

## Ein QSO loggen

1. **Rufzeichen.** Tippe es ein. Buchstaben werden automatisch großgeschrieben. Auf dem iPad kannst du auch mit dem
   Apple Pencil schreiben.
   - Schon beim Tippen zeigt Tideline **DXCC-Gebiet, Kontinent und CQ-/ITU-Zone**. Das funktioniert offline, mit den
     eingebauten Länderdaten.
   - Außerdem siehst du, ob du die Station **schon gearbeitet** hast: neues Rufzeichen, neues Band, neue Betriebsart,
     neue Kombination aus Band und Betriebsart oder schon gearbeitet (mit dem Datum des ersten QSOs). Das kommt aus dem
     Index „Schon gearbeitet“, der dein Log und nach einer Synchronisierung auch die QSOs auf deinem Wavelog-Server
     enthält. Wirkt er falsch (zum Beispiel nachdem du QSOs in Wavelog gelöscht hast), nutze **Einstellungen → Referenzdaten →
     Index „Schon gearbeitet“ → Index „Schon gearbeitet“ neu aufbauen**.
2. **Band, Betriebsart und Frequenz.**
   - Wähle Band und Betriebsart oder gib einfach eine Frequenz ein; das Band wird automatisch gewählt. Unter dem Feld
     zeigt Tideline, wie es deine Eingabe verstanden hat, zum Beispiel „14.205 MHz · 20 m“.
   - Mit Dezimalpunkt (oder Komma) ist die Zahl MHz: `14.205`, `144,300`, `2320.2`.
   - Eine ganze Zahl wird so gelesen, dass sie in einem Amateurfunkband landet: `7`, `50` und `144` sind MHz, `14205`,
     `1840`, `472` (630 m) und `136` (2190 m) sind kHz. Zahlen ab 1800 sind immer kHz; für Mikrowellenbänder gibst du
     daher einen Dezimalpunkt ein.
   - Band, Betriebsart, Frequenz und Station bleiben für das nächste QSO eingestellt.
3. **Rapporte.** Lass die Felder leer für den üblichen Standard: 59 bei Fonie, 599 bei CW, −10 bei FT8/FT4.
4. **Zeit.** Die Zeit ist immer **UTC** und läuft mit. Mit **Zeit ändern** loggst du einen früheren Kontakt, mit
   **Aktuelle Zeit verwenden** geht es zurück.
5. **Loggen.** Wähle **QSO loggen** oder drücke auf einer Tastatur **Eingabe**. Das Formular ist sofort bereit für das
   nächste QSO.

## Tastatur

| Taste | Aktion |
|---|---|
| Eingabe | QSO loggen |
| Esc | Eingabe verwerfen |
| Strg/⌘ + N | Zurück ins Rufzeichenfeld |
| Strg/⌘ + E | Letztes QSO öffnen |
| Strg/⌘ + / oder F1 | Alle Tastenkürzel anzeigen |

Die vollständige Liste steht unter [Tastenkürzel](keyboard-shortcuts.md).

## Die Bildschirmtastatur (Smartphones)

- Berichtsfelder (RST) öffnen eine Zifferntastatur, die auch das Minuszeichen hat. Die Frequenz öffnet eine
  Zifferntastatur mit Dezimalpunkt. Rufzeichen, Name und Locator öffnen die Buchstabentastatur.
- Solange die Tastatur offen ist, steht **Tastatur ausblenden** direkt darüber. Tippen schließt die Tastatur; die
  Navigationsleiste (Log, Rufzeichen, Sync, Einstellungen) ist sofort wieder da. Auch ein Tipp auf eine leere Fläche oder ein Ziehen
  der Liste schließt die Tastatur.
- Auf Tablets und Computern ändert sich nichts: Die Tastatur hat ihre eigene Schließtaste, und das Formular behält die
  ganze Höhe.

## Tablet und Desktop

- **Querformat:** Die Felder stehen in drei Zeilen über die ganze Breite, darunter dein Log. Bei geöffneter
  Bildschirmtastatur bleiben alle Felder sowie **Eingabe verwerfen** und **QSO loggen** ohne Scrollen sichtbar. Die
  obere Leiste wird ausgeblendet, solange die Tastatur offen ist, und kommt mit dem Schließen zurück. Tab und
  Umschalt+Tab springen zeilenweise durch die Felder.
- **Hochformat:** Die Felder stehen in Zeilen zu je bis zu drei über die Breite, **Eingabe verwerfen** und **QSO loggen**
  bleiben darunter fixiert, das Log folgt weiter unten. Bei geöffneter Bildschirmtastatur bleiben alle Felder und beide
  Schaltflächen ohne Scrollen sichtbar.
- **QSO-Details:** Wähle ein QSO im Log, um die Details in einem Blatt über dem Log zu sehen; was du gerade tippst,
  bleibt unverändert. Zum Schließen das Blatt nach unten wischen.
- **Smartphones** bleiben im Hochformat.
- **Fenstergröße ändern:** Drehen oder Ändern der Fenstergröße (Split View, Stage Manager) verliert nie deine Eingabe.
