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
