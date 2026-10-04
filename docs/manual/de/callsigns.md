# Rufzeichen-Verzeichnis und Notizen

Tideline merkt sich, was deine QSOs über die gearbeiteten Stationen sagen, und lässt dich eigene Notizen führen. Beides
funktioniert offline.

## Was frühere Kontakte sagen
Tippst du ein Rufzeichen, das du schon gearbeitet hast, erscheint unter dem Feld eine Zeile, zum Beispiel
**Aus früheren Kontakten bekannt: Anna · Berlin · JO62**. Sie nutzt für jeden Wert den neuesten Kontakt, der ihn hat.
Ein portables Rufzeichen (`DL1ABC/P`, `EA8/DL1ABC`) findet dieselbe Station.

- **Übernehmen** kopiert Name und Locator in die Felder, die noch **leer** sind. Was du getippt hast, wird nie ersetzt.
- In ein QSO wird nichts geschrieben, solange du es nicht loggst.

Das Verzeichnis entsteht aus deinem eigenen Log und aus deinem Wavelog (es lernt die Wavelog-Historie beim Synchronisieren,
Stück für Stück). Es gehört zum Index „Schon gearbeitet“: **Einstellungen → Referenzdaten → Index „Schon gearbeitet“ →
neu aufbauen** baut es mit neu auf.

## Notizen
- Die **Notiz-Taste** rechts im Rufzeichenfeld öffnet die Notiz zu dieser Station. Sie ist gefüllt, wenn eine Notiz
  existiert, und der Anfang der Notiz steht unter dem Feld. Tippe auf den Text, um sie zu bearbeiten.
- Eine Notiz gilt für die Station, egal welches Suffix: eine Notiz für `DL1ABC`, `DL1ABC/P` und `EA8/DL1ABC`. Sie kann bis
  zu 2.000 Zeichen lang sein.
- **Notizen bleiben auf deinem Gerät.** Die Wavelog-Oberfläche hat eigene Rufzeichen-Notizen, aber ihre API gibt keinen
  Zugriff darauf; Tidelines Notizen werden deshalb nie an Wavelog gesendet und stehen in keinem ADIF-Export. Sie sind in
  deinem [verschlüsselten Backup](backups.md); ein Wiederherstellen überschreibt nie eine vorhandene Notiz.
- Eine leere Notiz zu speichern löscht sie.

## Durchsuchen
**Einstellungen → Referenzdaten → Rufzeichen und Notizen durchsuchen** listet die Stationen, neuester Kontakt zuerst, mit
Name, Ort, Locator, DXCC und Zonen und dem Datum, an dem du sie zuletzt gearbeitet hast. Suche nach dem Anfang eines
Rufzeichens oder nach Name oder Ort. Tippe auf eine Station, um ihre Notiz zu lesen oder zu bearbeiten; ein gefülltes
Notiz-Symbol markiert Stationen mit Notiz.

## Datenschutz
Namen und Orte anderer Personen sind personenbezogene Daten. Sie bleiben in der verschlüsselten Datenbank auf deinem Gerät
und werden nirgendwohin gesendet. Siehe die [Datenschutzerklärung](../../../PRIVACY.md).
