# App Store screenshots (en-US)

Rendered store images live in `appstore/output/<device>/en/NN-slug.png`, the layout
`tools/appstore/asc-media.py` uploads from (iPhone 1290×2796 → APP_IPHONE_67,
iPad 2064×2752 → APP_IPAD_PRO_3GEN_129). They are committed (about 20 MB).

| File | Role |
|---|---|
| `captions.txt` | Title (accent word in `[ ]`) and subtitle per screen, appstore-mockup format |
| `mockup-brand.json` | Style 05 "Fresh Mint" recoloured to Hooker green with a sun-gold accent |
| `prepare-mockup-inputs.py` | Picks the captures per device, renumbers stems and captions, masks iPad system chrome |
| `input/`, `style-preview/` | Renderer scratch, git-ignored |

Galleries: iPhone has 7 screens (hero = Welcome); iPad has 6 (hero = Today, no separate
Today slide), because the iPad Welcome is a narrow column over an empty page.

## Regenerate

From the repo root. Simulator UDIDs are the ones on the owner's Mac (iPhone 17 Pro Max,
iPad Pro 13-inch (M5)); every simulator step runs under the shared lock.

```sh
# 1. Build (iPhone first; the iPad build re-thins the asset catalog to @2x)
(cd iOS && xcodegen generate && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk \
  -destination 'id=558F034D-7FF9-42AF-9612-50FFA68E6B91' -derivedDataPath /tmp/gw-dd-store)

# 2. Temporary capture script: store build path, plain full battery (no charging bolt)
sed -e 's#/tmp/gw-dd/#/tmp/gw-dd-store/#' \
    -e 's/--batteryState charged --batteryLevel 100 --cellularBars 4/--batteryState discharging --batteryLevel 100 --cellularBars 4 --wifiBars 3 --dataNetwork wifi/' \
    iOS/scripts/capture_states.sh > /tmp/capture_store.sh && chmod +x /tmp/capture_store.sh

# 3. iPhone captures (raw, git-ignored)
lockf -k /tmp/gentlewalk-sim.lock /tmp/capture_store.sh docs/release/1.0/shots \
  558F034D-7FF9-42AF-9612-50FFA68E6B91 \
  onboarding-welcome today-goal-line walk-player chair-player program progress-results journey

# 4. iPad build + captures (raw, git-ignored), then shut the iPad down again
(cd iOS && xcodebuild build -project GentleWalk.xcodeproj -scheme GentleWalk \
  -destination 'id=21219F08-4441-452D-963D-D4A35CB7B2D2' -derivedDataPath /tmp/gw-dd-store)
lockf -k /tmp/gentlewalk-sim.lock /tmp/capture_store.sh docs/release/1.0/shots-ipad \
  21219F08-4441-452D-963D-D4A35CB7B2D2 \
  today-goal-line walk-player chair-player program progress-results journey
lockf -k /tmp/gentlewalk-sim.lock xcrun simctl shutdown 21219F08-4441-452D-963D-D4A35CB7B2D2

# 5. Inputs + render (needs Pillow and Google Chrome; skill appstore-mockup)
python3 appstore/prepare-mockup-inputs.py
python3 ~/.claude/skills/appstore-mockup/scripts/render.py --root appstore
identify appstore/output/*/en/*.png
```

Before rendering new captions, lint them (they must say 0 findings):

```sh
python3 -c "import json; print(json.dumps([l.split(':',1)[1].strip().replace('[','').replace(']','') for l in open('appstore/captions.txt') if l.startswith(('title:','subtitle:'))]))" > /tmp/captions.json
python3 tools/lint/copy_lint.py /tmp/captions.json
```

The iPad captures show the status-bar date in the simulator's own language (Japanese on this
Mac) and the windowed-apps resize grabber; `prepare-mockup-inputs.py` paints both over with the
neighbouring colour. Nothing inside the app's UI is altered.
