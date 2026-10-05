# First setup

You need:
- **Wavelog 3.1 or newer.** Contest sessions need 3.2 or newer.
- An **API token** for it. See [Creating a Wavelog API token](api-token.md).

## No Wavelog yet?

Choose **Try the demo (no Wavelog needed)** on the first screen. Tideline sets up a demo account with a made-up station
that runs entirely on your device. Nothing is sent anywhere. Remove it later under **Settings → Wavelog accounts**.

## Steps

1. **Server address.** Open Tideline and choose **Connect to Wavelog**.
   - Enter the address you use to open Wavelog in your browser, for example `https://log.example.org`.
     Installations in a sub-folder work too (`https://example.org/wavelog`), with or without `index.php`.
   - You can give the account a name, such as "Personal" or "Club station".
2. **Server in your own network without HTTPS** (`http://192.168.…`): switch on **Allow an unencrypted connection**.
   - Tideline only offers this for private network addresses.
   - For servers on the internet, HTTPS is always required.
3. **Token.** Paste your token and choose **Check connection**. Tideline shows which permissions the token has, with a
   tick for each.
   - **Unknown certificate:** if your server uses a self-made certificate, Tideline shows its fingerprint. Compare it
     with the fingerprint of your server's certificate.
   - Only if they match, choose **Trust this certificate**. Tideline will refuse any other certificate from then on and
     will ask again if it changes.
   - There is no setting that turns certificate checks off.
4. **Station location.** Pick the station location your QSOs should go to, then choose **Start logging**.

Nothing is stored until the last step.
