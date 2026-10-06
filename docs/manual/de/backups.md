# Sicherung und Export

Dein Log ist nie eingesperrt.

## ADIF-Export

**Einstellungen → Sicherheit und Backup → Log als ADIF exportieren** speichert dein gesamtes Log als ADIF-Datei.
Jedes Logprogramm kann sie lesen.

ADIF-Dateien sind **nicht verschlüsselt**, bewahre sie also sicher auf.

## ADIF-Import

**ADIF-Datei importieren** fügt QSOs aus einer Datei hinzu, etwa ein anderswo erfasstes Papierlog oder den Export eines
anderen Loggers.
- QSOs, die schon in deinem Log sind, werden übersprungen.
- Einträge ohne gültiges Rufzeichen, ohne Zeit, Band oder Betriebsart werden gezählt und gemeldet.
- Die importierten QSOs gehören zu deinem Standard-Stationsstandort und werden wie alle anderen QSOs synchronisiert.
- **Große Importe:** Bevor mehr als 50 neue QSOs hochgeladen werden, zeigt Tideline eine Vorschau und wartet auf dich.
  Siehe [Synchronisierung und Konflikte](sync-and-conflicts.md).

## Sicherung

**Sicherung erstellen** speichert alles außer deinem Token in einer `.tlbackup`-Datei.
- **Die Sicherung ist nicht verschlüsselt.** Sie enthält deine QSOs, Standorte und Rufzeichen-Notizen lesbar; bewahre
  sie also sicher auf, wie einen ADIF-Export.
- **Wiederherstellen:** **Sicherung wiederherstellen** holt alles auf dasselbe oder ein neues Gerät zurück.
- **Keine Duplikate:** QSOs, die schon in Wavelog waren, bleiben mit ihren Wavelog-Einträgen verknüpft und werden nicht
  erneut hochgeladen.
- **Dein Token ist nicht in der Sicherung.** Gib nach dem Wiederherstellen auf einem neuen Gerät unter **Einstellungen →
  Wavelog-Konto → Neuen Token eingeben** einen neuen Token ein.
- **Sicherungen aus Version 0.5 lassen sich nicht wiederherstellen.** Version 0.5 hat ihre Sicherungen mit einem Passwort
  verschlüsselt; diese Version enthält keinen Verschlüsselungscode mehr. Tideline weist darauf hin, wenn du so eine Datei
  auswählst.

### Wie dein Log auf dem Gerät geschützt ist

Tideline verschlüsselt dein Log nicht selbst. Es verlässt sich auf das, was dein Gerät bietet: die Displaysperre und den
Speicherschutz des Betriebssystems. Nutze einen Gerätecode und aktiviere die App-Sperre unter **Sicherheit und Backup**,
wenn andere dein Gerät benutzen.

Tideline bittet iPhone, iPad und Android, seine Daten nicht in iCloud-, iTunes- oder Google-Sicherungen aufzunehmen. Deine
eigene Sicherungsdatei, die du selbst speicherst, ist der Weg, das Log auf ein anderes Gerät zu bringen.
