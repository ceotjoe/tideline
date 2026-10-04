# Several Wavelog accounts

You can connect more than one Wavelog, for example your own and a club station's. One account is **in use for
logging** at a time: the log screen, contests and activations all use it. Waiting QSOs of every account are still sent
to their own server.

## Add an account
1. **Settings → Wavelog accounts → Add account.**
2. Follow the same steps as in [First setup](first-setup.md): server, token, station location.
3. The new account is **not** switched on automatically. Its page opens; choose **Use for logging** when you want it.

If two accounts have the same name, Tideline adds a number ("Club 2"). You can rename an account any time.

## Switch the account
- On the log screen, the account menu (two arrows and the account's name) appears as soon as there are two accounts.
  Choose the account; a message confirms "Logging to …".
- Or open **Settings → Wavelog accounts**, the account, **Use for logging**.
- **You cannot switch while a contest session or an activation is running.** Both belong to the account, and logging
  to the wrong one would be hard to notice. End the session or activation first.

## What belongs to an account
Its QSOs, stations, sync state and history, contest sessions, activations and worked-before index. **Import and
export** (Security and backup) work on the account in use and name it.

The **Sync** screen shows how many QSOs are waiting for each account.

## Remove an account
**Settings → Wavelog accounts →** the account **→ Remove account from this device.**
- Tideline first tells you how many of its QSOs never reached Wavelog (they would be lost).
- **Export log, then remove** saves an ADIF file first. If saving is cancelled, the account stays.
- **Remove account from this device** removes it at once.
- Removing deletes the account's QSOs, sessions, activations and token **on this device only**. Your Wavelog is not
  changed.
