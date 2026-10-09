# appstore-connect-sync in this repo
Toolkit copied from `~/.claude/skills/appstore-connect-sync` (09/10/2026). Config: `appstore/metadata-json/_config.json`.
Dry run (writes nothing); the API key stays outside the repo (`~/KeyManager/AuthKey_F672M6BVNL.p8`):

    ASC_KEY_ID=F672M6BVNL ASC_ISSUER_ID=<issuer id from App Store Connect> ASC_KEY_PATH=~/KeyManager/AuthKey_F672M6BVNL.p8 \
      python3 tools/appstore/asc-sync.py --only iap

Add `--apply` only to write. Subscription display names and the group name come from `iOS/App/GentleWalk.storekit`.
The listing half (`--only listing`) needs `appstore/metadata-json/en.json` (name, subtitle, keywords, description,
promotional_text), written with the `appstore-metadata` skill, and a published privacy URL in `_config.json`.
