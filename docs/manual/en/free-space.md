# Free up space

Your log can grow large. Tideline can remove the **copies on this device** of QSOs that Wavelog already has. **Nothing is
deleted on Wavelog.**

## How
**Settings → Wavelog accounts →** the account **→ Remove synced QSOs from this device.**

1. Choose how far back: older than 1, 2 or 5 years, or all synced QSOs. The page says how many can be removed and why
   others stay.
2. Choose **Check with Wavelog.** Tideline asks your Wavelog which of these QSOs it has. It needs a connection; without an
   answer, nothing is removed. QSOs Wavelog does not have (for example because you deleted them there) stay on your
   device.
3. Choose **Remove … QSOs from this device.** You can **Export, then remove**: Tideline first saves an ADIF file of exactly
   these QSOs. If saving is cancelled, nothing is removed.

## Which QSOs stay
- QSOs that have **not reached Wavelog yet**, or were **changed since** they were sent.
- QSOs of **contest sessions** and **activations** (contest mode, Cabrillo and the activation export need them).
- QSOs Wavelog **cannot confirm**.

## One QSO
Open a synced QSO and choose **Remove from this device.** Tideline checks with Wavelog first.

## What changes
- The QSO is gone from the log list and from the ADIF export of this account. **Export first** if you want a copy.
- It cannot be brought back from Wavelog into Tideline; only from an ADIF file.
- **Worked-before hints and the callsign directory keep what they learned.** Importing a file that contains such a QSO
  skips it.
- The sync history says how many QSOs were removed.
