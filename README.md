# sr-rules-mirror

Mirror of [hydraponique/roscomvpn-geoip](https://github.com/hydraponique/roscomvpn-geoip) and [hydraponique/roscomvpn-geosite](https://github.com/hydraponique/roscomvpn-geosite) plain-text sources, converted into Shadowrocket `RULE-SET` format.

## How it works

`scripts/convert.sh` pulls upstream text files, prepends SR-specific prefixes (`IP-CIDR,`, `DOMAIN-SUFFIX,` etc.), and writes the result to the `release` orphan branch. GitHub Action runs daily at 03:00 UTC.

## Output (release branch)

| File | Type | Source |
|---|---|---|
| `geoip-direct.list` | IP-CIDR | RU+BY (MaxMind+IPInfo+DBIP+ASN union) |
| `geoip-whitelist.list` | IP-CIDR | RU hosting (Yandex Cloud, VK, etc.) |
| `geosite-category-ru.list` | DOMAIN-SUFFIX | RU services with non-RU TLD |
| `geosite-whitelist.list` | DOMAIN-SUFFIX | hydraponique main whitelist |
| `geosite-google-play.list` | DOMAIN-SUFFIX | Google Play |
| `geosite-youtube.list` | DOMAIN-SUFFIX | YouTube |
| `geosite-telegram.list` | DOMAIN-SUFFIX | Telegram |
| `geosite-microsoft.list` | DOMAIN-SUFFIX | Microsoft |
| `geosite-apple.list` | DOMAIN-SUFFIX | Apple |
| `geosite-category-ads.list` | DOMAIN-SUFFIX | Ads (extras) |
| `geosite-category-geoblock-ru.list` | DOMAIN-SUFFIX | Geo-blocked from RU |
| `geosite-torrent.list` | DOMAIN-SUFFIX | Torrent |

## Usage in Shadowrocket config

```
RULE-SET,https://cdn.jsdelivr.net/gh/eslavgor/sr-rules-mirror@release/geoip-direct.list,DIRECT
RULE-SET,https://cdn.jsdelivr.net/gh/eslavgor/sr-rules-mirror@release/geosite-category-ru.list,DIRECT
RULE-SET,https://cdn.jsdelivr.net/gh/eslavgor/sr-rules-mirror@release/geosite-youtube.list,YOUR_PROXY_GROUP
```

jsDelivr caches for ~12 hours; for instant updates use raw GitHub URL instead.
