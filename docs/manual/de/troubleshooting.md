# Fehlerbehebung

| Was du siehst | Was zu tun ist |
|---|---|
| „Dein Wavelog ist gerade nicht erreichbar“ | Es geht nichts verloren. Tideline synchronisiert beim nächsten Öffnen, wenn die Verbindung zurückkommt oder mit **Jetzt synchronisieren**. |
| QSOs zeigen **Wird geprüft** | Ein früherer Versuch wurde unterbrochen. Tideline fragt dein Wavelog, ob das QSO angekommen ist, bevor es erneut sendet – so landet nichts doppelt. |
| **Token-Problem** | Der Token ist abgelaufen oder wurde widerrufen. Erstelle in Wavelog einen neuen und gib ihn unter **Einstellungen → Wavelog-Konto → Neuen Token eingeben** ein. Wartende QSOs werden dann synchronisiert. |
| **Abgelehnt** | Öffne das QSO: Dort steht das Problem und die Originalmeldung von Wavelog. Korrigiere das QSO, dann wird es erneut gesendet. |
| **Entscheidung nötig** nach Ändern von Zeit, Betriebsart, Frequenz oder Station | Wavelog kann diese Felder bei einem hochgeladenen QSO nicht ändern. Wähle **In Wavelog ersetzen** (braucht die Berechtigung qso:delete) oder **Ich korrigiere es in Wavelog**. |
| „Ein anderes QSO mit gleichem Rufzeichen … in derselben Minute“ | Wavelog speichert nur ein QSO pro Rufzeichen, Band, Betriebsart und Minute. Korrigiere die Zeit, wenn es ein eigener Kontakt war, oder lösche eines davon. |
| „Unbekanntes Zertifikat“ bei der Einrichtung | Bei selbst betriebenen Servern normal. Vergleiche den Fingerabdruck mit dem deines Servers und vertraue ihm dann. |
| „Dein früheres Log konnte nicht übernommen werden“ nach dem Update von 0.5 | Version 0.5 hat ihre Datenbank verschlüsselt; diese Version kann sie nicht öffnen und startet leer. Die alte Datei bleibt auf dem Gerät, wird aber nicht verwendet. Bereits synchronisierte QSOs sind weiterhin in deinem Wavelog-Logbuch. |
| iPhone/iPad synchronisiert nicht im Hintergrund | Richtig so: iOS erlaubt keine zuverlässige Hintergrund-Synchronisierung. Öffne Tideline, wenn du wieder online bist. |
