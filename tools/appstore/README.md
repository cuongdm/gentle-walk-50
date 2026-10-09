# App Store Connect metadata toolkit

Writes an app's whole store listing — name, subtitle, keywords, description,
promotional text, subscription names, and screenshots — from files in the repo to
App Store Connect, in every language, without retyping anything into a web form.

Drop-in portable: copy this folder into another repo, add one config file, done.
Nothing here names a specific project.

## What is in here

| File | Role |
|---|---|
| `asc-studio.py` | **Start here.** Local web console: pick app, pick/create version, preview, publish |
| `studio.html` | Its UI |
| `asc-sync.py` | The same thing as a CLI, and the module the studio imports (auth, diff, writes) |
| `asc-media.py` | Screenshot upload (reserve → chunked PUT → checksum commit) |
| `_config.template.json` | Copy to `<metadata_dir>/_config.json` and fill in |

`capture.sh` is **not** part of this toolkit — it belongs to the screenshot-capture
workflow and depends on `tools/verify/snap.sh`.

## Expected repo layout

```
tools/appstore/                 this folder, two levels below the repo root
appstore/metadata-json/         _config.json + one <locale>.json per language
appstore/output/<device>/<lang>/NN-name.png      rendered screenshots
<anywhere>/*.storekit           optional, only needed for subscriptions
```

All three paths are overridable in `_config.json` under `sync.paths`, so a different
layout needs no code change. The `.storekit` file is found automatically when the repo
contains exactly one; name it explicitly if there are several.

One metadata folder per release (`AppStore/1.0.0/metadata-json/`,
`AppStore/1.0.1/metadata-json/`, …) works too: the `_config.json` under the highest
version wins. A release with no new screenshots can point `screenshots_dir` back at the
previous release's output.

`tools/appstore` must sit two levels below the repo root — the scripts resolve the root
as `parents[2]`.

## Setting up a new project

1. Copy this folder to `<newrepo>/tools/appstore/`.
2. Create `appstore/metadata-json/` and copy `_config.template.json` to
   `_config.json`. Fill in `sync.bundle_id`, the `locales` map (repo code → ASC
   locale + that language's privacy URL), and `storekit_locales` if the app sells
   subscriptions.
3. Write one `<locale>.json` per language. The schema and the writing guidance live
   in the `appstore-metadata` skill; its generator also produces a copy-paste HTML
   review page from the same files.
4. Create an App Store Connect API key (App Store Connect → Users and Access →
   Integrations, role App Manager). Keep the `.p8` **outside the repo and outside any
   synced folder** (Dropbox, iCloud Drive).

```sh
export ASC_KEY_ID=XXXXXXXXXX
export ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export ASC_KEY_PATH=~/.appstoreconnect/AuthKey_XXXXXXXXXX.p8
```

## Running

```sh
tools/appstore/asc-studio.py          # web console on 127.0.0.1:8787
tools/appstore/asc-sync.py            # CLI, dry run
tools/appstore/asc-sync.py --apply    # CLI, write
```

The stock macOS `python3` is enough. The token is signed with the `cryptography`
package when it is installed, and with the system `openssl` when it is not.

Publishing order that avoids dead ends:

1. **Listing** — needs a version in an editable state (Prepare for Submission).
2. **Screenshots** — needs the version localizations to exist, so run Listing first.
3. **Subscriptions** — needs the group and the products to already exist in App Store
   Connect. The API can localize them but cannot create them.

## Things it knows that are easy to get wrong

- **`whatsNew` does not exist on a first release.** App Store Connect refuses the
  write rather than ignoring it. Detected from the version count and dropped; the text
  stays in the JSON for the next release.
- **A new version does not inherit Promotional Text.** Description, keywords and URLs
  are copied from the live version; promotional text arrives empty, so the next
  release would ship without it. The preview shows it as a change and Publish puts
  the repo's text back.
- **A JWT lives 15 minutes.** A 252-image upload does not fit in one. The token
  re-signs itself, and a stray 401 re-signs once more.
- **`RemoteDisconnected` is an `HTTPException`, not a `URLError`.** urllib does not
  wrap what `getresponse()` raises, so catching `URLError` alone misses it.
- **A half-sent image cannot be resumed.** The presigned URLs belong to one
  reservation; a failed attempt deletes it and starts clean.
- **"Has some images" is not "is complete".** Sets are compared by file name, so a
  re-run finishes a partial set instead of skipping it.
- **One refused field must not abort the rest.** Each locale is an independent write;
  failures are collected and reported.
- **Apple 500s at random.** Reads retry with backoff before being believed.

## Safety

- Binds to `127.0.0.1` only; every API call needs a token minted at startup and a
  loopback `Host` header, so another page in the browser cannot drive it.
- The `.p8` is read only to sign a token. The browser never receives it.
- Dry run is the default. `--apply`, or the Publish button, is the only path that writes.
