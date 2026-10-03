# Aktivierungen (SOTA, POTA, WWFF)

Eine Aktivierung ist ein Funkbetrieb von einem Gipfel (SOTA), Park (POTA) oder Flora-und-Fauna-Gebiet (WWFF). Tideline
speichert die Referenz bei jedem QSO, das Du währenddessen loggst, zeigt Dir, wie weit Du von einer gültigen
Aktivierung entfernt bist, und nimmt die Referenz der Gegenstation für Park-zu-Park- und Gipfel-zu-Gipfel-Verbindungen
auf. Alles funktioniert offline.

## Referenzlisten laden (einmal, mit Verbindung)

Die Listen der Gipfel, Parks und Gebiete gehören nicht zu Tideline: Du lädst jede Liste selbst herunter, direkt von der
offiziellen Quelle. Es wird nichts geladen, bevor Du es auslöst.

1. Öffne die **Einstellungen** und gehe zu **Referenzlisten (SOTA, POTA, WWFF)**.
2. Prüfe die Adresse der Liste. Sie beginnt mit der offiziellen Datei und lässt sich ändern. Es funktionieren nur
   `https`-Adressen.
3. Tippe auf **Herunterladen**. Jede Liste ist 10 bis 25 MB groß, nimm also WLAN. Ein Fortschrittsbalken und ein Text
   zeigen den Stand. **Abbrechen** stoppt den Vorgang und lässt eine bereits installierte Liste unverändert.
4. Die Karte zeigt danach, wie viele Referenzen die Liste enthält, ihr Datum und woher sie stammt.

Tippe ab und zu auf **Aktualisieren**: Neue Parks und Gipfel kommen hinzu, andere entfallen. **Entfernen** löscht eine
Liste (Deine QSOs und Aktivierungen bleiben).

Ohne Liste kannst Du trotzdem aktivieren: tippe die Referenz selbst ein. Es fehlen nur die Suche, der Ortsname und die
Liste der nächsten Referenzen.

## Eine Aktivierung starten

1. Tippe oben im Log auf die Berg-Schaltfläche oder drücke **⇧⌘A** (**Strg+Umschalt+A**).
2. Wähle das **Programm**: SOTA, POTA oder WWFF.
3. Gib die Referenz ein (zum Beispiel `US-0001`, `G/LD-001` oder `DLFF-0001`) oder suche nach dem Namen. Tippe auf einen
   Treffer, um ihn zu übernehmen. Solange das Feld leer ist, siehst Du die fünf Referenzen, die Deinem Locator am
   nächsten liegen, mit Entfernung.
4. Prüfe **Dein Locator an der Referenz**. Er stammt aus der Position der Referenz, sonst aus Deinem Wavelog-Standort.
   Du kannst auch einen eigenen eintragen.
5. Wähle die **Station** (den Wavelog-Standort, an den die QSOs gehen). Lies den Hinweis darunter: siehe unten.
6. Tippe auf **Aktivierung starten**.

Es läuft immer nur eine Aktivierung. Eine neue beendet die laufende.

## Beim Loggen

Im Log siehst Du ein Banner mit Referenz, Ortsname und Fortschritt, als Balken und als Satz: „3 von 10 QSOs · noch 7“,
dann „Gültige Aktivierung: 12 QSOs (nötig: 10)“. Darunter steht, wie gezählt wird und wie viele QSOs nicht zählen, weil
sie Rufzeichen, Band und Betriebsart wiederholen.

| Programm | Nötige QSOs | Gezählt |
|---|---|---|
| POTA | 10 | innerhalb eines UTC-Tages |
| SOTA | 4 | über die ganze Aktivierung |
| WWFF | 44 | über die ganze Aktivierung |

Das sind die Voreinstellungen von Tideline. Ein QSO mit derselben Station auf einem anderen Band oder in einer anderen
Betriebsart zählt erneut. Prüfe die Regeln Deines Awards, wenn es auf die genaue Zählung ankommt.

Logge wie gewohnt. Das Formular hat ein Feld mehr, **Ihr Park (P2P)** (**Ihr Gipfel (S2S)**, **Ihr Gebiet (WWFF)**): Trage
die Referenz der Gegenstation ein, wenn sie ebenfalls aktiviert. Sonst lass es leer.

Zum Beenden tippe im Banner auf **Aktivierung beenden** oder drücke **⇧⌘E** (**Strg+Umschalt+E**). Geloggte QSOs bleiben
unverändert.

## Deine Referenz in Wavelog

**Wavelog übernimmt Deine eigene Referenz nicht aus dem Upload.** Es legt jedes QSO unter dem gewählten Standort ab und
kopiert dessen SOTA-, POTA- oder WWFF-Referenz und Locator in das QSO. Die Referenz der Gegenstation (Park zu Park,
Gipfel zu Gipfel) kommt dagegen so an, wie Du sie eingetragen hast.

Damit Deine Referenz auch in Wavelog steht:

1. Lege in Wavelog einen Standort an, der die Referenz (und Deinen Locator) der Aktivierung trägt.
2. Synchronisiere in Tideline einmal, damit die App den Standort kennt.
3. Wähle diesen Standort beim Start der Aktivierung. Der Hinweis lautet dann „Dieser Wavelog-Standort trägt …“. Trägt
   schon ein anderer Standort die Referenz, bietet Tideline ihn mit **Diesen Standort verwenden** an.

Trägt kein Standort die Referenz, sagt der Hinweis das. Nichts geht verloren: Tideline behält Deine Referenz bei jedem
QSO, und Deine ADIF-Exporte enthalten sie. Tideline ändert Deine Wavelog-Standorte nie von sich aus.

## Gut zu wissen

- Zeiten sind immer UTC. POTA zählt pro UTC-Tag; eine Aktivierung über Mitternacht UTC wird pro Tag gezählt.
- Löschen oder Ändern eines QSOs ändert den Fortschritt sofort.
- Es gibt noch keine GPS-Taste: Die nächsten Referenzen werden aus Deinem Locator berechnet.
- Die Zählregeln lassen sich in der App noch nicht ändern.
