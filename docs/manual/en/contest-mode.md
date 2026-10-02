# Contest mode

_This chapter will be written together with the feature. The sections below are already final._

## Wavelog status of a session

The contest screen and the list of past sessions show where a session stands on Wavelog, always as an icon with text:

| State | Meaning |
|---|---|
| Only on this device | The session is not mirrored on Wavelog. The reason is shown after the colon, for example an old server (before 3.2), a contest that is not activated on the server, or a token without `contest:write`. |
| Waiting for upload to Wavelog | The session will be created on Wavelog at the next sync. |
| Being checked on Wavelog | A create request got lost. Tideline checks whether Wavelog already has the session before it tries again. |
| On Wavelog | The session exists on Wavelog and its QSOs are linked to it. |

Your log is complete either way. The session on Wavelog is an optional extra.

## Exporting a Cabrillo log

Choose **Export Cabrillo log** from the menu (the three dots) in the contest screen, press **⇧⌘X** (**Ctrl+Shift+X**), or use the button on a card in the list of past sessions. Tideline then:

1. Builds the log from the session: your callsign and locator from the station, the categories from the session setup, the claimed score from the contest engine, and one `QSO:` line per contact.
2. Checks it and lists any problems (for example a contact without a frequency). You can cancel, or export anyway.
3. Asks where to save it. The suggested name is `CALL-CONTEST-YEAR.log`, for example `DO1HOZ-DARC-WAG-2026.log`.

Notes:

- A contest whose definition has no Cabrillo name cannot be exported. Tideline shows a warning for it. Use the ADIF export in Settings instead, or add a `cabrillo` name to the definition.
- When the exchange differs by station (WAG: serial number from abroad, DOK from Germany), both share one column in the log.
- The claimed score is an estimate. Check it against the contest rules before you send the log.
- Free text is written as plain ASCII: `ä` becomes `ae`, and so on.
