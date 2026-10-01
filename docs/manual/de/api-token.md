# Wavelog-API-Token erstellen

Tideline nutzt **API v2** von Wavelog. Dafür ist **Wavelog 3.1.0 oder neuer** nötig.

1. Bei Wavelog anmelden.
2. Im Benutzermenü **API** wählen.
3. Einen **neuen v2-Token** anlegen und benennen, zum Beispiel „Tideline auf dem Handy“.
4. Diese Berechtigungen (Scopes) auswählen:

   | Scope | Nötig? | Wofür Tideline ihn nutzt |
   |---|---|---|
   | `qso:write` | erforderlich | QSOs hochladen und Felder hochgeladener QSOs korrigieren. |
   | `qso:read` | erforderlich | Vor einem erneuten Senden prüfen, ob ein QSO schon auf dem Server ist, damit nichts doppelt landet. Außerdem für die Offline-Hinweise „schon gearbeitet“. |
   | `station:read` | erforderlich | Deine Stationsstandorte abrufen, damit jedes QSO beim richtigen landet. |
   | `contest:read`, `contest:write` | optional | Contest-Sessions in Wavelog anlegen und Contest-QSOs zuordnen (Wavelog 3.2+). |
   | `qso:delete` | optional | In Tideline gelöschte QSOs auch auf dem Server löschen. |
   | `lookup:read` | optional | Online-Rufzeichenabfragen bei bestehender Verbindung. |

5. Eine Ablaufzeit wählen. Tideline erinnert dich, bevor der Token abläuft.
6. Den Token sofort kopieren; Wavelog zeigt ihn nur einmal an. Er beginnt mit `wl2_`.
7. In Tideline einfügen. Tideline speichert ihn ausschließlich im sicheren Speicher deines Geräts.

Tokens der alten API (ohne `wl2_`) funktionieren nicht.
