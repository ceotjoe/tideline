# Mac, Windows and Linux

On a computer, Tideline works like a computer program.

- **Sidebar.** Log, Callsigns, Sync and Settings are in a sidebar on the left, in every window size. From a wide window on, it
  shows the names next to the icons.
- **Menu bar.** On a Mac it is the menu bar at the top of the screen; on Windows and Linux it is a strip at the top of
  the window. It has three menus:
  - **Go**: Go to log, Go to sync, Open settings, Go back.
  - **Operate**: Sync now, Open contest mode, Start an activation.
  - **Help**: Show keyboard shortcuts.

  Each entry shows its shortcut. An entry that makes no sense on the current page is greyed out.
- **Going back.** Press **Esc**, **Alt + ←** (**⌥ ←** on a Mac) or **Ctrl + [** (**⌘ [**) on a settings page or an
  account page to go up one level. On the log screen **Esc** still clears the entry, and in contest mode it wipes it.
- **Right click** a QSO in the log: **Open QSO** or **Copy callsign**.
- **Keyboard.** Everything can be done without the mouse: Tab moves between fields, the focus is always visible, and all
  commands have shortcuts. See [Keyboard shortcuts](keyboard-shortcuts.md).

## Linux and Raspberry Pi (experimental)

Tideline for Linux is experimental. The download page has a build for x86-64 PCs and one for 64-bit ARM, which runs on a
Raspberry Pi 4 or 5 with the 64-bit desktop version of Raspberry Pi OS. Older Pi models and the 32-bit system are not
supported.

1. Install what Tideline needs:

   ```bash
   sudo apt install libgtk-3-0 libsecret-1-0 gnome-keyring
   ```

2. Unpack the download, for example `tar -xzf Tideline-<version>-linux-arm64.tar.gz`, and start `tideline` in the new
   folder.

- **System keyring.** Tideline keeps your Wavelog token in the system keyring and nowhere else. The Raspberry Pi OS
  desktop already has one; **Raspberry Pi OS Lite** and other systems without a desktop session do not. Without a running
  keyring, Tideline shows a message at start and does not open. Your log is not touched. Install and start a secret
  service such as GNOME Keyring or KWallet, sign in to the desktop session, and start Tideline again.
- **Status.** The Linux builds are built automatically, but the project has not tested them on real hardware yet.
  Reports are welcome on GitHub.
