# Activations (SOTA, POTA, WWFF)

An activation is a stretch of operating from one summit (SOTA), park (POTA) or flora and fauna area (WWFF). Tideline
keeps the reference on every QSO you log meanwhile, tells you how far you are from a valid activation, and lets you note
the other station's reference for park-to-park and summit-to-summit contacts. All of it works offline.

## Download the reference lists (once, with a connection)

The lists of summits, parks and areas are not part of Tideline: you download each one yourself, directly from its
official source. Nothing is downloaded until you ask.

1. Open **Settings → Reference data** and go to **Reference lists (SOTA, POTA, WWFF)**.
2. Check the address of the list. It starts as the official file and you can change it. Only `https` addresses work.
3. Press **Download**. Each list is 10 to 25 MB, so use Wi-Fi. A progress bar and a text show how far it is. **Cancel**
   stops it and leaves any installed list as it was.
4. The card then shows how many references it holds, the date of the list and where it came from.

Press **Update** from time to time: new parks and summits appear, others retire. **Remove** deletes a list (your QSOs
and activations stay).

Without a list you can still activate: type the reference yourself. You only lose the search, the place name and the
"nearest references" list.

## Starting an activation

1. Press the mountain button at the top of the log screen, or **⇧⌘A** (**Ctrl+Shift+A**).
2. Choose the **Program**: SOTA, POTA or WWFF.
3. Enter the reference (for example `US-0001`, `G/LD-001` or `DLFF-0001`), or search by name. Tap a match to use it.
   While the field is empty, the five references nearest to your grid square are listed with their distance.
4. Check **Your grid square at the reference**. It comes from the position of the reference, otherwise from your Wavelog
   location. You can type your own.
5. Choose the **Station** (the Wavelog location the QSOs go to). Read the note under it: see below.
6. Press **Start activation**.

Only one activation runs at a time. Starting another ends the running one.

## While you log

The log screen shows a banner with the reference, the place name and your progress, as a bar and as a sentence:
"3 of 10 QSOs · 7 to go", then "Valid activation: 12 QSOs (needs 10)". Below it you see how QSOs are counted and how
many were not counted because they repeat a station (call, band and mode; for SOTA the call alone).

| Program | QSOs needed | Counted |
|---|---|---|
| POTA | 10 | within one UTC day |
| SOTA | 4, each with a different station | within one UTC day |
| WWFF | 44 | over the whole activation, a repeat counts again on another day |

These are Tideline's defaults, checked against the programmes' rules on 2026-10-05. POTA and WWFF count a QSO with the same
station on another band or in another mode again; SOTA does not (each QSO needs a different station). WWFF also counts
the same station again on another UTC day. Tideline counts one activation at a time: WWFF lets the QSOs of several visits
add up to 44 and SOTA gives points once per summit and calendar year, which Tideline does not track across activations.
Check the rules of your award if the exact counting matters to you.

Log as usual. The form has one more field, **Their park (P2P)** (**Their summit (S2S)**, **Their area (WWFF)**): enter
the other station's reference when it is also activating. Leave it empty otherwise.

To finish, press **End activation** in the banner or **⇧⌘E** (**Ctrl+Shift+E**). Logged QSOs stay as they are.

## Your reference on Wavelog

**Wavelog does not take your own reference from the upload.** It files every QSO under the station location you chose and
copies that location's SOTA, POTA or WWFF reference and grid square into the QSO. The reference of the other station
(park to park, summit to summit) does arrive as you entered it.

So that your reference also appears on Wavelog:

1. In Wavelog, create a station location that carries the reference (and your grid square) of the activation.
2. In Tideline, sync once so the app learns the location.
3. Choose that location when you start the activation. The note then reads "This Wavelog location carries …". If
   another location already carries the reference, Tideline offers it with **Use this location**.

If no location carries the reference, the note says so. Nothing is lost: Tideline keeps your reference on every QSO, and
your ADIF exports contain it. Tideline never changes your Wavelog locations by itself.

## Good to know

- Times are always UTC. POTA counts per UTC day, so an activation that crosses midnight UTC is counted per day.
- Deleting or editing a QSO changes the progress at once.
- There is no GPS button yet: the nearest references are found from your grid square.
- The counting rules cannot be edited in the app yet.
