# Sicherung und Export

Dein Log ist nie eingesperrt.

## ADIF-Export

**Einstellungen → Import, Export und Sicherung → Log als ADIF exportieren** speichert dein gesamtes Log als ADIF-Datei.
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

## Verschlüsselte Sicherung

**Verschlüsselte Sicherung erstellen** speichert alles außer deinem Token, geschützt durch ein Passwort mit mindestens
8 Zeichen.
- **Bewahre das Passwort gut auf.** Ohne es lässt sich die Sicherung nicht öffnen – auch nicht von uns.
- **Wiederherstellen:** **Sicherung wiederherstellen** holt alles auf dasselbe oder ein neues Gerät zurück.
- **Keine Duplikate:** QSOs, die schon in Wavelog waren, bleiben mit ihren Wavelog-Einträgen verknüpft und werden nicht
  erneut hochgeladen.
- **Dein Token ist nicht in der Sicherung.** Gib nach dem Wiederherstellen auf einem neuen Gerät unter **Einstellungen →
  Neuen Token eingeben** einen neuen Token ein.

### Warum Android Tideline nicht in die Cloud sichert

Tidelines Daten sind mit einem Schlüssel verschlüsselt, der das Gerät nie verlässt. Eine Cloud-Kopie ließe sich nicht
öffnen. Daher schaltet Tideline die Systemsicherung ab und bietet stattdessen seine eigene verschlüsselte Sicherung an.
