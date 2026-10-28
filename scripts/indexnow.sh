#!/bin/bash
# Meldet die Seiten aus der Sitemap per IndexNow (Bing, Yandex u. a.; Google nutzt
# IndexNow nicht). Nach einer Änderung, die live ist, aufrufen:
#   bash scripts/indexnow.sh           -> alle Seiten der Sitemap
#   bash scripts/indexnow.sh /studio/  -> nur bestimmte Pfade
set -e
cd "$(dirname "$0")/../public"
HOST=swoonfactory.com
KEY=$(ls | grep -E '^[0-9a-f]{32}\.txt$' | head -1 | sed 's/\.txt$//')
[ -n "$KEY" ] || { echo "FEHLER: kein IndexNow-Schlüssel in public/"; exit 1; }
curl -sf "https://$HOST/$KEY.txt" | grep -qx "$KEY" || { echo "FEHLER: Schlüssel noch nicht live"; exit 1; }
if [ $# -gt 0 ]; then
  URLS=$(for p in "$@"; do echo "https://$HOST$p"; done)
else
  URLS=$(grep -oE '<loc>[^<]+</loc>' sitemap.xml | sed -E 's#</?loc>##g')
fi
JSON=$(printf '%s\n' $URLS | python3 -c 'import json,sys; h,k=sys.argv[1:]; print(json.dumps({"host":h,"key":k,"keyLocation":f"https://{h}/{k}.txt","urlList":sys.stdin.read().split()}))' "$HOST" "$KEY")
echo "$URLS"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' -X POST -H 'Content-Type: application/json; charset=utf-8' --data "$JSON" https://api.indexnow.org/indexnow)
echo "IndexNow-Antwort: HTTP $STATUS (200/202 = angenommen)"
