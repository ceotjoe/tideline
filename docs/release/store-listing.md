# Store listing texts (v1.0 draft)

Drafted 2026-10-05 from `PRIVACY.md`, the manual and the 0.4.0 changelog. Each text states only what the app does
today. Check the limits again in App Store Connect and Play Console before pasting. German uses "Du", like the app.

## Privacy answers (from `PRIVACY.md`)
- **App Store privacy label:** Data Not Collected. No tracking, no third-party SDKs, no analytics.
- **Play Data safety:** no data collected, none shared. The app does not encrypt the data itself; the operating system protects it on the device and it is excluded from cloud backups. Users can delete the data
  by removing an account or the app. The app contacts only servers the user configures and, on request, reference-list
  sources.
- **Permissions:** no location, no camera. Biometrics (app lock, optional), local network (a Wavelog on the LAN),
  internet.
- **Export compliance:** `ITSAppUsesNonExemptEncryption` is false (ADR 0034): the app uses only the OS's HTTPS and secure store and has no encryption of its own, so there are no follow-up questions. On Google Play, answer the data-safety encryption question accordingly: data in transit is encrypted (HTTPS), data at rest is not encrypted by the app.
- **Age rating:** no user-generated content shared, no ads, no purchases, no web browsing.
- **App access for review:** the Welcome screen's "Try the demo" needs no server or sign-in (ADR 0031).

## English

**Name:** Tideline
**Subtitle (30):** Offline logger for Wavelog
**Short description, Play (80):** Log QSOs offline and sync them to your own Wavelog when you are back online.
**Promotional text (170):** Log on a summit, in a park or in a contest with no signal. Tideline keeps every QSO safe on
your device and syncs to your Wavelog when it can.
**Keywords (100):** ham radio,amateur radio,logbook,QSO,Wavelog,ADIF,contest,POTA,SOTA,WWFF,Cabrillo,FLE

**Description**

Tideline is the offline logger for Wavelog, made for radio amateurs.

Log first, sync later. Every QSO is saved on your device the moment you enter it, and a separate sync sends it to your
own Wavelog server when a connection is there. Nothing waits for the network. For every QSO you can see what sync is
doing (waiting, uploaded, checked, rejected) with a plain explanation, and nothing is replaced silently.

• Several Wavelog accounts and stations, with a switcher on the log screen.
• Fast Log Entry: type QSOs as shorthand, see how each line was read, and log them all at once.
• Contest mode: keyboard-first entry, serial numbers that never repeat, dupe checks, super check partial (from the
  MASTER.SCP you download), live score and rates, Cabrillo export, Wavelog contest sessions.
• SOTA, POTA and WWFF activations: reference lists you download yourself, search by name or distance, progress toward a
  valid activation, park-to-park and summit-to-summit.
• Offline callsign directory and your own notes, built from your log and your Wavelog history.
• Worked-before hints and offline DXCC lookup.
• ADIF import and export, and backups.
• Free up space by removing local copies of QSOs Wavelog already has. Nothing is deleted on Wavelog.
• Field mode: sunlight theme, glove mode, a battery saver and keep-screen-on in one switch.
• Made accessible: VoiceOver and TalkBack, text up to 200 %, themes for sunlight and for the night, full keyboard use.
• English and German, chosen in the app.

Private by design: no account with us, no ads, no analytics, no tracking. Your log stays on your device, and your
API token stays in the system's secure store. Tideline talks only to your Wavelog servers and, when you press Download,
to the reference-list sources you can see. Open source under the MIT licence.

You need a Wavelog server (version 3.1 or newer) and an API token, or you can try the built-in demo with no server.

**What's New (1.0):** to be written with the release notes of 1.0.0.

## Deutsch

**Name:** Tideline
**Untertitel (30):** Offline-Logger für Wavelog
**Kurzbeschreibung, Play (80):** QSOs offline loggen, später mit Deinem Wavelog synchronisieren.
**Werbetext (170):** Logge auf dem Gipfel, im Park oder im Contest ohne Netz. Tideline sichert jedes QSO auf Deinem Gerät
und synchronisiert mit Deinem Wavelog, sobald es geht.
**Schlüsselwörter (100):** Amateurfunk,Funktagebuch,Logbuch,QSO,Wavelog,ADIF,Contest,POTA,SOTA,WWFF,Cabrillo,FLE

**Beschreibung**

Tideline ist der Offline-Logger für Wavelog, gemacht für Funkamateure.

Erst loggen, später synchronisieren. Jedes QSO wird im Moment der Eingabe auf Deinem Gerät gespeichert, und eine eigene
Synchronisierung sendet es an Deinen Wavelog-Server, sobald eine Verbindung besteht. Nichts wartet auf das Netz. Bei
jedem QSO siehst Du, was die Synchronisierung macht (wartend, hochgeladen, geprüft, abgelehnt), mit einer klaren
Erklärung, und nichts wird stillschweigend ersetzt.

• Mehrere Wavelog-Konten und Stationen, mit Umschalter im Log.
• Fast Log Entry: QSOs als Kurzschrift tippen, sehen, wie jede Zeile gelesen wurde, und alle auf einmal loggen.
• Contest-Modus: Eingabe per Tastatur, Seriennummern, die sich nie wiederholen, Dupe-Prüfung, Super Check Partial (aus
  der MASTER.SCP, die Du selbst herunterlädst), Punkte und Raten live, Cabrillo-Export, Wavelog-Contest-Sitzungen.
• SOTA-, POTA- und WWFF-Aktivierungen: Referenzlisten, die Du selbst herunterlädst, Suche nach Name oder Entfernung,
  Fortschritt zur gültigen Aktivierung, Park zu Park und Gipfel zu Gipfel.
• Offline-Rufzeichenverzeichnis und eigene Notizen, aufgebaut aus Deinem Log und Deiner Wavelog-Historie.
• „Schon gearbeitet“-Hinweise und DXCC-Suche offline.
• ADIF-Import und -Export sowie verschlüsselte Backups.
• Speicher freigeben: lokale Kopien von QSOs entfernen, die Wavelog schon hat. Auf Wavelog wird nichts gelöscht.
• Feldmodus: Sonnenlicht-Thema, Handschuh-Modus, Energiesparer und Display-an in einem Schalter.
• Barrierefrei: VoiceOver und TalkBack, Text bis 200 %, Themen für Sonnenlicht und Nacht, volle Tastaturbedienung.
• Deutsch und Englisch, in der App wählbar.

Privat von Grund auf: kein Konto bei uns, keine Werbung, keine Analyse, kein Tracking. Dein Log ist auf dem Gerät
verschlüsselt, und Dein API-Token bleibt im sicheren Speicher des Systems. Tideline spricht nur mit Deinen
Wavelog-Servern und, wenn Du auf „Herunterladen“ tippst, mit den sichtbaren Quellen der Referenzlisten. Open Source unter
der MIT-Lizenz.

Du brauchst einen Wavelog-Server (ab Version 3.1) und ein API-Token, oder Du probierst die eingebaute Demo ohne Server.

**Was ist neu (1.0):** wird mit den Release-Notes von 1.0.0 geschrieben.
