#!/usr/bin/env bash
set -euo pipefail

OUT=output
mkdir -p "$OUT"
TS=$(date -u +%Y-%m-%dT%H:%MZ)

GEOIP_BASE="https://cdn.jsdelivr.net/gh/hydraponique/roscomvpn-geoip/release/text"
GEOSITE_BASE="https://raw.githubusercontent.com/hydraponique/roscomvpn-geosite/master/data"

write_header_geoip() {
  local dst="$1" src_url="$2" lines="$3"
  cat <<EOF
# NAME: $dst
# SOURCE: $src_url
# UPDATED: $TS
# IP-CIDR: $lines
# TOTAL: $lines
EOF
}

write_header_geosite() {
  local dst="$1" src_url="$2" lines="$3"
  cat <<EOF
# NAME: $dst
# SOURCE: $src_url
# UPDATED: $TS
# TOTAL: $lines
EOF
}

convert_geoip() {
  local src="$1" dst="$2"
  local url="$GEOIP_BASE/$src.txt"
  local body="$OUT/$dst.list.body"
  curl -fsSL "$url" | sed -E 's|^|IP-CIDR,|; s|$|,no-resolve|' > "$body"
  local lines
  lines=$(wc -l < "$body")
  { write_header_geoip "$dst" "$url" "$lines"; cat "$body"; } > "$OUT/$dst.list"
  rm "$body"
  printf '  ✓ %-32s %s\n' "$dst.list" "$lines CIDR"
}

convert_geosite() {
  local src="$1" dst="$2"
  local url="$GEOSITE_BASE/$src"
  local body="$OUT/$dst.list.body"
  curl -fsSL "$url" | sed -E '/^#/d; /^[[:space:]]*$/d; s|^domain:|DOMAIN-SUFFIX,|; s|^full:|DOMAIN,|; s|^keyword:|DOMAIN-KEYWORD,|; s|^regexp:|URL-REGEX,|' > "$body"
  local lines
  lines=$(wc -l < "$body")
  { write_header_geosite "$dst" "$url" "$lines"; cat "$body"; } > "$OUT/$dst.list"
  rm "$body"
  printf '  ✓ %-32s %s\n' "$dst.list" "$lines domains"
}

echo "=== GeoIP ==="
convert_geoip direct    geoip-direct
convert_geoip whitelist geoip-whitelist

echo "=== Geosite ==="
convert_geosite category-ru             geosite-category-ru
convert_geosite whitelist               geosite-whitelist
convert_geosite google-play             geosite-google-play
convert_geosite youtube                 geosite-youtube
convert_geosite telegram                geosite-telegram
convert_geosite microsoft               geosite-microsoft
convert_geosite apple                   geosite-apple
convert_geosite category-ads            geosite-category-ads
convert_geosite category-geoblock-ru    geosite-category-geoblock-ru
convert_geosite torrent                 geosite-torrent

cat > "$OUT/README.md" <<EOF
# SR Rules Mirror — release branch

Built: \`$TS\`
Source: [hydraponique/roscomvpn-geoip](https://github.com/hydraponique/roscomvpn-geoip), [hydraponique/roscomvpn-geosite](https://github.com/hydraponique/roscomvpn-geosite)

Plain-text source files converted into Shadowrocket \`RULE-SET\` format.

## Usage in SR config

\`\`\`
RULE-SET,https://cdn.jsdelivr.net/gh/eslavgor/sr-rules-mirror@release/<file>.list,<POLICY>
\`\`\`
EOF

echo
echo "Done at $TS"
