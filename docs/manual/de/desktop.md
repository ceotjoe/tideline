# Mac, Windows und Linux

Auf einem Computer arbeitet Tideline wie ein Computerprogramm.

- **Seitenleiste.** Log, Rufzeichen, Sync und Einstellungen stehen in jeder Fenstergröße links in einer Seitenleiste. Ab einem
  breiten Fenster zeigt sie die Namen neben den Symbolen.
- **Menüleiste.** Auf dem Mac ist es die Menüleiste am oberen Bildschirmrand, unter Windows und Linux ein Streifen am
  oberen Fensterrand. Sie hat drei Menüs:
  - **Gehe zu**: Zum Log, Zu den Rufzeichen, Zur Synchronisierung, Einstellungen öffnen, Zurück.
  - **Betrieb**: Jetzt synchronisieren, Contest-Modus öffnen, Aktivierung starten.
  - **Hilfe**: Tastenkürzel anzeigen.

  Jeder Eintrag zeigt sein Tastenkürzel. Ein Eintrag, der auf der aktuellen Seite keinen Sinn ergibt, ist ausgegraut.
- **Zurück.** Drücke auf einer Einstellungs- oder Kontoseite **Esc**, **Alt + ←** (Mac: **⌥ ←**) oder **Strg + [**
  (Mac: **⌘ [**), um eine Ebene höher zu gehen. Auf dem Log-Bildschirm löscht **Esc** weiterhin die Eingabe, im
  Contest-Modus wischt es sie weg.
- **Rechtsklick** auf ein QSO im Log: **QSO öffnen** oder **Rufzeichen kopieren**.
- **Tastatur.** Alles geht ohne Maus: Mit Tab wechselst du zwischen Feldern, der Fokus ist immer sichtbar, und alle
  Befehle haben Tastenkürzel. Siehe [Tastenkürzel](keyboard-shortcuts.md).

## Linux und Raspberry Pi (experimentell)

Tideline für Linux ist experimentell. Auf der Download-Seite gibt es einen Build für x86-64-PCs und einen für 64-Bit-ARM,
der auf einem Raspberry Pi 4 oder 5 mit der 64-Bit-Desktop-Version von Raspberry Pi OS läuft. Ältere Pi-Modelle und das
32-Bit-System werden nicht unterstützt.

1. Installiere, was Tideline braucht:

   ```bash
   sudo apt install libgtk-3-0 libsecret-1-0 gnome-keyring
   ```

2. Entpacke den Download, zum Beispiel mit `tar -xzf Tideline-<Version>-linux-arm64.tar.gz`, und starte `tideline` im
   neuen Ordner.

- **System-Schlüsselbund.** Tideline speichert dein Wavelog-Token im System-Schlüsselbund und sonst nirgends. Der
  Desktop von Raspberry Pi OS hat bereits einen; **Raspberry Pi OS Lite** und andere Systeme ohne Desktop-Sitzung haben
  keinen. Ohne laufenden Schlüsselbund zeigt Tideline beim Start eine Meldung und öffnet sich nicht. Dein Log bleibt
  unverändert. Installiere und starte einen Secret-Service wie GNOME Keyring oder KWallet, melde dich an der
  Desktop-Sitzung an und starte Tideline erneut.
- **Stand.** Die Linux-Builds werden automatisch gebaut, aber das Projekt hat sie noch nicht auf echter Hardware
  getestet. Rückmeldungen sind auf GitHub willkommen.
