# Contest-Modus

_Dieses Kapitel entsteht zusammen mit der Funktion. Die Abschnitte unten sind bereits fertig._

## Wavelog-Status einer Sitzung

Der Contest-Bildschirm und die Liste vergangener Sitzungen zeigen, wo eine Sitzung bei Wavelog steht, immer als Symbol mit Text:

| Zustand | Bedeutung |
|---|---|
| Nur auf diesem Gerät | Die Sitzung wird nicht auf Wavelog gespiegelt. Der Grund steht hinter dem Doppelpunkt, zum Beispiel ein alter Server (vor 3.2), ein Contest, der auf dem Server nicht aktiviert ist, oder ein Token ohne `contest:write`. |
| Wartet auf Upload zu Wavelog | Die Sitzung wird beim nächsten Abgleich auf Wavelog angelegt. |
| Wird auf Wavelog geprüft | Eine Anlegen-Anfrage ging verloren. Tideline prüft, ob Wavelog die Sitzung schon hat, bevor es erneut versucht. |
| Auf Wavelog | Die Sitzung existiert auf Wavelog, ihre QSOs sind damit verknüpft. |

Dein Log ist in jedem Fall vollständig. Die Sitzung auf Wavelog ist eine optionale Zugabe.

## Cabrillo-Log exportieren

Wähle im Contest-Bildschirm im Menü (die drei Punkte) **Cabrillo-Log exportieren**, drücke **⇧⌘X** (**Strg+Umschalt+X**) oder nutze die Schaltfläche an einer Karte in der Liste vergangener Sitzungen. Tideline

1. baut das Log aus der Sitzung: Rufzeichen und Locator aus der Station, die Kategorien aus der Sitzungseinrichtung, die beanspruchte Punktzahl aus der Contest-Auswertung und je Verbindung eine `QSO:`-Zeile,
2. prüft es und listet Probleme auf (zum Beispiel eine Verbindung ohne Frequenz). Du kannst abbrechen oder trotzdem exportieren,
3. fragt, wo gespeichert werden soll. Vorgeschlagen wird `RUFZEICHEN-CONTEST-JAHR.log`, zum Beispiel `DO1HOZ-DARC-WAG-2026.log`.

Hinweise:

- Ein Contest, dessen Definition keinen Cabrillo-Namen hat, lässt sich nicht exportieren. Tideline zeigt dafür eine Warnung. Nutze stattdessen den ADIF-Export in den Einstellungen oder trage in der Definition einen `cabrillo`-Namen ein.
- Unterscheidet sich der Austausch je nach Station (WAG: Laufnummer aus dem Ausland, DOK aus Deutschland), teilen sich beide eine Spalte im Log.
- Die beanspruchte Punktzahl ist eine Schätzung. Prüfe sie vor dem Einsenden anhand der Ausschreibung.
- Freitext wird als reines ASCII geschrieben: aus `ä` wird `ae` und so weiter.
