# Fast Log Entry

Tippe viele QSOs als Kurzschrift, prüfe, wie Tideline jede Zeile gelesen hat, und logge sie alle auf einmal. Es ist die
Kurzschrift von Wavelogs SimpleFLE, passend für ein Papierlog, eine aufgeschriebene Aktivierung oder eine Sitzung an der
Tastatur. Es braucht keine Verbindung.

Öffne es mit dem **Blitz** in der oberen Leiste des Logs oder mit **Strg/⌘ + Umschalt + F**.

## So tippst du
Ein QSO pro Zeile. Band-, Mode-, Datums- und Zeitzonen-Angaben in einer eigenen Zeile gelten für die Zeilen danach.

```
date 2026-10-02
20m cw
1734 DL1ABC 599 579 JO62 @Anna
5 G4XYZ
40 F5ABC <good signal>
14.205 ssb
1810 W1AW 59 57
```

- **Zeit:** Das erste QSO braucht eine volle UTC-Zeit (`1734`). Danach tippst du nur die geänderten Ziffern: `5` nach `1734`
  ist 17:35, `40` ist 17:40.
- Dann das **Rufzeichen**, optional **Rapporte**, **Locator** (`JO62`, `#JO62QM`), eine **Referenz** (`de-0034`, `dm/bw-001`,
  `dlff-0123`, `eu-005`; die Referenz der Gegenstation) und **@Name**.
- **Rapporte:** `59`, `599`, `-12`. Ein Rapport ist der gesendete; was du nicht tippst, ist der Standard des Modes (59, 599,
  -10 bei FT8). Eine einzelne Ziffer ist die zweite Ziffer (`7 3` heißt in SSB 57 / 53).
- **Band, Mode, Frequenz:** `20m`, `cw`, `ft8`, `14.205` (MHz, mit Punkt). Eine Frequenz setzt auch das Band.
- **Datum:** `date 2026-10-02`, `day +` (nächster Tag), `day ++` (zwei Tage). **Zeitzone:** `timezone +2` rechnet die getippten
  Zeiten von Ortszeit in UTC um.
- **Mehr:** `<Kommentar>`, `[QSL-Nachricht]`, `<tx_pwr:50>` (gilt für die Zeilen danach) oder ein anderes ADIF-Feld wie
  `<rig:IC-7300>`.
- **Contest-Austausch:** `,1.12` heißt gesendet 1, empfangen 12; `,++` zählt hoch. Das wird wie getippt gespeichert; Fast Log Entry
  vergibt keine Contest-Seriennummern und ist nicht für eine Contest-Sitzung gedacht.

## Die Vorschau
Jede Zeile erscheint mit Symbol **und** Text:
- ein QSO: Rufzeichen, Name, Zeit in UTC, Band, Mode und Rapporte;
- eine Zeile, die für die folgenden gilt;
- ein **Problem**, mit dem Wort, das nicht verstanden wurde. Eine Zeile mit Problem wird ganz weggelassen.

Hinweise: Das QSO ist **früher als das davor** (fehlt ein `day +`?), **in der Zukunft** oder ein **Doppeltes** eines QSOs, das schon
im Log oder weiter oben im Text steht. Doppelte werden nur mit **Doppelte auch loggen** geloggt.

## Loggen
Wähle den **Stationsstandort** (wenn du mehrere hast), dann **N QSOs loggen**. Alle QSOs werden in einem Schritt gespeichert:
alle oder keins. Beim Tippen wird nichts gespeichert und nichts gesendet. Danach werden sie wie jedes QSO synchronisiert.

- Bei Problemen im Text korrigiere sie oder schalte **Zeilen mit Problemen überspringen** ein.
- Läuft eine **Aktivierung**, kommen die QSOs mit ihren Referenzen dort hinein.

## Was nicht akzeptiert wird
Zeilen wie `mycall DL1ABC`, `mygrid JO62` (klassische FLE-Dateien): Wähle stattdessen den Stationsstandort auf dem Bildschirm. Ein
zweites Rufzeichen in einer Zeile, Rapporte vor dem Rufzeichen, `sat` und Felder, die Tideline selbst setzt (`my_…`, das
Stationsrufzeichen), werden als Probleme gemeldet.
