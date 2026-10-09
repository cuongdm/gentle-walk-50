#!/usr/bin/env python3
"""asc-open-territories.py - sell the subscriptions and the in-app purchase in every territory.

What the ASC web form does NOT do for you: after "all countries" is ticked it leaves the price column
empty, so a territory can be "available" and still have no price (the product then shows as unavailable
to a tester in that storefront: "This item is not available"). This script:

  * subscriptions: finds the base-territory (USA) price point for the price you pass, reads Apple's
    equalised price point for every other territory, and creates the missing `subscriptionPrices`;
  * in-app purchase: makes it available in every territory (its price schedule already equalises).

Dry run by default (read-only). `--apply` writes. Same env as asc-sync.py (ASC_KEY_ID / ASC_ISSUER_ID /
ASC_KEY_PATH). Example:
    asc-open-territories.py                      # plan only
    asc-open-territories.py --apply
"""
from __future__ import annotations

import argparse, concurrent.futures as cf, importlib.util, pathlib, sys

HERE = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("asc_sync", HERE / "asc-sync.py")
S = importlib.util.module_from_spec(spec)
sys.modules["asc_sync"] = S
spec.loader.exec_module(S)

# product id -> base (USA) customer price. Subscriptions only; the lifetime IAP keeps its own schedule.
SUBS = {"com.kmd.goodfooting.pro.yearly": "49.99", "com.kmd.goodfooting.pro.monthly": "9.99"}
IAP = "com.kmd.goodfooting.pro.lifetime"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--apply", action="store_true", help="write (default: read-only plan)")
    args = ap.parse_args()
    sync = S.load_config()
    cl = S.Client(S.token, apply=False)
    app_id = cl.get_all(f"/v1/apps?filter[bundleId]={sync['bundle_id']}&limit=10")[0]["id"]
    territories = [t["id"] for t in cl.get_all("/v1/territories?limit=200")]
    print(f"app {app_id}, {len(territories)} territories\n")
    writes = errors = 0

    groups = cl.get_all(f"/v1/apps/{app_id}/subscriptionGroups?limit=50")
    subs = {s["attributes"]["productId"]: s for g in groups
            for s in cl.get_all(f"/v1/subscriptionGroups/{g['id']}/subscriptions?limit=200")}
    for pid, usd in SUBS.items():
        sub = subs.get(pid)
        if not sub:
            print(f"! {pid} not found"); continue
        sid = sub["id"]
        have = {p["relationships"]["territory"]["data"]["id"]
                for p in cl.get_all(f"/v1/subscriptions/{sid}/prices?limit=200&include=territory")}
        usa_points = cl.get_all(f"/v1/subscriptions/{sid}/pricePoints?filter[territory]=USA&limit=200")
        base = next((p for p in usa_points if p["attributes"].get("customerPrice") == usd), None)
        if not base:
            print(f"! {pid}: no USA price point for {usd}"); continue
        equal = cl.get_all(f"/v1/subscriptionPricePoints/{base['id']}/equalizations?limit=200&include=territory")
        want = {p["relationships"]["territory"]["data"]["id"]: p["id"] for p in equal}
        want["USA"] = base["id"]
        missing = sorted(t for t in territories if t in want and t not in have)
        none = sorted(t for t in territories if t not in want)
        print(f"{pid}: {len(have)} priced, {len(missing)} to create"
              + (f", {len(none)} territories with no equalised point: {none[:5]}" if none else ""))
        if not args.apply:
            continue
        cl.apply = True

        def create(t):
            cl.write("POST", "/v1/subscriptionPrices", {"data": {
                "type": "subscriptionPrices",
                "attributes": {"preserveCurrentPrice": False},
                "relationships": {
                    "subscription": {"data": {"type": "subscriptions", "id": sid}},
                    "subscriptionPricePoint": {"data": {"type": "subscriptionPricePoints", "id": want[t]}},
                    "territory": {"data": {"type": "territories", "id": t}}}}})

        # One POST per territory (Apple has no bulk endpoint); 8 in flight cuts ~10 min to ~1 min.
        with cf.ThreadPoolExecutor(max_workers=8) as pool:
            futures = {pool.submit(create, t): t for t in missing}
            for fut in cf.as_completed(futures):
                try:
                    fut.result(); writes += 1
                except BaseException as e:  # SystemExit comes from the client's fatal errors
                    errors += 1; print(f"  ! {pid} {futures[fut]}: {str(e)[:140]}")
        cl.apply = False

    iaps = {i["attributes"]["productId"]: i for i in cl.get_all(f"/v1/apps/{app_id}/inAppPurchasesV2?limit=200")}
    iap = iaps.get(IAP)
    if iap:
        try:
            av_id = cl._call("GET", f"/v2/inAppPurchases/{iap['id']}/inAppPurchaseAvailability")["data"]["id"]
            av = cl.get_all(f"/v1/inAppPurchaseAvailabilities/{av_id}/availableTerritories?limit=50")
        except SystemExit:
            av = []  # no availability record yet: it will be created below
        print(f"{IAP}: available in {len(av)} territories")
        if args.apply and len(av) < len(territories):
            cl.apply = True
            try:
                cl.write("POST", "/v1/inAppPurchaseAvailabilities", {"data": {
                    "type": "inAppPurchaseAvailabilities",
                    "attributes": {"availableInNewTerritories": True},
                    "relationships": {
                        "inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap["id"]}},
                        "availableTerritories": {"data": [{"type": "territories", "id": t} for t in territories]}}}})
                writes += 1
            except SystemExit as e:
                errors += 1; print(f"  ! {IAP}: {str(e)[:200]}")
            cl.apply = False
    print(f"\n{'applied' if args.apply else 'would apply'}: {writes} write(s), {errors} error(s)")
    if not args.apply:
        print("Re-run with --apply to write.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
