# Synchronisierung und Konflikte

Jedes QSO zeigt, wo es im Synchronisierungsablauf steht:

| Status | Bedeutung |
|---|---|
| Lokal | Nur auf diesem Gerät gespeichert; etwas fehlt noch (zum Beispiel ein Stationsstandort). |
| Wartet | Wartet auf die nächste Synchronisierung. |
| Wird hochgeladen | Wird gerade gesendet. |
| Wird geprüft | Der letzte Versuch wurde nicht sauber beendet. Tideline prüft den Server, bevor es erneut sendet, damit das QSO nie doppelt landet. |
| Synchronisiert | Sicher in deinem Wavelog. |
| Konflikt | Du hast etwas geändert, das Wavelog über die API nicht aktualisieren kann (Zeit, Mode, Frequenz oder Station). Du entscheidest, was passiert. |
| Abgelehnt | Wavelog hat das QSO abgelehnt. Der Grund wird verständlich angezeigt. Nach der Korrektur wird es erneut eingereiht. |
| Blockiert | Dein Token ist abgelaufen oder wurde widerrufen. Bitte einen neuen Token eingeben. |

Der **Gezeitenpegel** zeigt, wie viele QSOs noch auf die Synchronisierung warten. Bei Ebbe ist alles synchronisiert.

Der **Sync-Verlauf** listet jeden Schritt mit der Originalantwort des Servers für jedes QSO.

Synchronisiert wird beim Öffnen der App, wenn die Verbindung zurückkommt, und wenn du auf **Jetzt synchronisieren**
tippst. iPhone und iPad erlauben keine zuverlässige Hintergrund-Synchronisierung; öffne Tideline also, wenn du wieder
online bist.

Meldet Wavelog, dass zu viele Anfragen eingehen, wartet Tideline so lange, wie Wavelog es verlangt, und macht dann von
selbst weiter, solange die App geöffnet ist. Verlässt du die App, geht es beim Zurückkehren weiter.

## Vor einem großen Upload

Warten mehr als 50 neue QSOs, etwa nach einem ADIF-Import, lädt Tideline sie nicht automatisch hoch. Der
Sync-Bildschirm zeigt dann **Upload-Vorschau** mit drei Angaben:
- wie viele QSOs hochgeladen werden;
- wie viele nach Duplikaten vorhandener QSOs aussehen;
- was der Testlauf von Wavelog meldet.

Mit **Hochladen** sendest du sie.

## Wenn ein QSO deine Entscheidung braucht

Die Wavelog-API kann **Zeit, Betriebsart, Frequenz oder Station** eines hochgeladenen QSOs nicht ändern. Änderst du
eines davon, zeigt das QSO **Entscheidung nötig**, und du wählst:
- **In Wavelog ersetzen:** Der alte Eintrag wird gelöscht und das korrigierte QSO hochgeladen. Dafür ist die
  Berechtigung `qso:delete` nötig.
- **Ich korrigiere es in Wavelog:** Tideline lässt den Wavelog-Eintrag unverändert. Nimm dort dieselbe Korrektur vor.
