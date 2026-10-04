# Speicher freigeben

Dein Log kann groß werden. Tideline kann die **Kopien auf diesem Gerät** von QSOs entfernen, die Wavelog schon hat. **Auf
Wavelog wird nichts gelöscht.**

## So geht's
**Einstellungen → Wavelog-Konten →** das Konto **→ Synchronisierte QSOs von diesem Gerät entfernen.**

1. Wähle, wie weit zurück: älter als 1, 2 oder 5 Jahre oder alle synchronisierten QSOs. Die Seite sagt, wie viele entfernt
   werden können und warum andere bleiben.
2. Wähle **Bei Wavelog prüfen.** Tideline fragt dein Wavelog, welche dieser QSOs es hat. Dafür braucht es eine
   Verbindung; ohne Antwort wird nichts entfernt. QSOs, die Wavelog nicht hat (zum Beispiel weil du sie dort gelöscht
   hast), bleiben auf deinem Gerät.
3. Wähle **… QSOs von diesem Gerät entfernen.** Du kannst **Exportieren, dann entfernen** wählen: Tideline speichert
   zuerst eine ADIF-Datei genau dieser QSOs. Wird das Speichern abgebrochen, wird nichts entfernt.

## Welche QSOs bleiben
- QSOs, die Wavelog **noch nicht erreicht** haben oder **seit dem Senden geändert** wurden.
- QSOs von **Contest-Sitzungen** und **Aktivierungen** (Contest-Modus, Cabrillo und der Aktivierungs-Export brauchen sie).
- QSOs, die Wavelog **nicht bestätigen** kann.

## Ein einzelnes QSO
Öffne ein synchronisiertes QSO und wähle **Von diesem Gerät entfernen.** Tideline prüft vorher bei Wavelog.

## Was sich ändert
- Das QSO verschwindet aus der Log-Liste und aus dem ADIF-Export dieses Kontos. **Exportiere vorher**, wenn du eine
  Kopie willst.
- Es lässt sich nicht aus Wavelog zurück in Tideline holen; nur aus einer ADIF-Datei.
- **„Schon gearbeitet“-Hinweise und das Rufzeichen-Verzeichnis behalten, was sie gelernt haben.** Beim Import einer Datei
  mit so einem QSO wird es übersprungen.
- Der Sync-Verlauf sagt, wie viele QSOs entfernt wurden.
