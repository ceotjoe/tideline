# Ersteinrichtung

Du brauchst:
- **Wavelog 3.1 oder neuer.** Contest-Sessions benötigen 3.2 oder neuer.
- Einen **API-Token** dafür. Siehe [Wavelog-API-Token erstellen](api-token.md).

## Noch kein Wavelog?

Wähle auf dem ersten Bildschirm **Demo ausprobieren (ohne Wavelog)**. Tideline richtet ein Demo-Konto mit einer
erfundenen Station ein, das vollständig auf deinem Gerät läuft. Es wird nichts versendet. Du kannst es später unter
**Einstellungen → Wavelog-Konten** entfernen.

## Schritte

1. **Serveradresse.** Öffne Tideline und wähle **Mit Wavelog verbinden**.
   - Gib die Adresse ein, mit der du Wavelog im Browser öffnest, zum Beispiel `https://log.example.org`.
     Installationen in einem Unterordner funktionieren auch (`https://example.org/wavelog`), mit oder ohne `index.php`.
   - Du kannst dem Konto einen Namen geben, etwa „Privat“ oder „Clubstation“.
2. **Server im eigenen Netz ohne HTTPS** (`http://192.168.…`): Aktiviere **Unverschlüsselte Verbindung erlauben**.
   - Tideline bietet das nur für Adressen im privaten Netz an.
   - Für Server im Internet ist HTTPS immer Pflicht.
3. **Token.** Füge deinen Token ein und wähle **Verbindung prüfen**. Tideline zeigt mit Häkchen, welche Berechtigungen
   der Token hat.
   - **Unbekanntes Zertifikat:** Nutzt dein Server ein selbst erstelltes Zertifikat, zeigt Tideline seinen
     Fingerabdruck. Vergleiche ihn mit dem Fingerabdruck des Zertifikats deines Servers.
   - Nur wenn beide übereinstimmen, wähle **Diesem Zertifikat vertrauen**. Ab dann lehnt Tideline jedes andere
     Zertifikat ab und fragt erneut, falls es sich ändert.
   - Es gibt keine Einstellung, die die Zertifikatsprüfung abschaltet.
4. **Stationsstandort.** Wähle den Stationsstandort, zu dem deine QSOs gehören sollen, und dann **Loslegen**.

Bis zum letzten Schritt wird nichts gespeichert.
