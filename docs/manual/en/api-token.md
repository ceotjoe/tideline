# Creating a Wavelog API token

Tideline talks to Wavelog through **API v2**, which needs **Wavelog 3.1.0 or newer**.

1. Sign in to your Wavelog.
2. Open the user menu and choose **API**.
3. Create a **new v2 token** and give it a name, for example "Tideline on my phone".
4. Select these scopes:

   | Scope | Needed? | What Tideline does with it |
   |---|---|---|
   | `qso:write` | required | Upload your QSOs and correct fields of uploaded QSOs. |
   | `qso:read` | required | Check whether a QSO is already on the server before sending it again, so nothing is duplicated. Also builds your offline "worked before" hints. |
   | `station:read` | required | List your station locations, so each QSO goes to the right one. |
   | `contest:read`, `contest:write` | optional | Create contest sessions in Wavelog and attach your contest QSOs (Wavelog 3.2+). |
   | `qso:delete` | optional | Delete QSOs on the server that you deleted in Tideline. |
   | `lookup:read` | optional | Online callsign lookups while connected. |

5. Choose an expiry. Tideline reminds you before the token expires.
6. Copy the token right away; Wavelog shows it only once. It starts with `wl2_`.
7. Paste it into Tideline. Tideline stores it only in your device's secure storage.

Tokens from the old API (without `wl2_`) do not work.
