#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

BASE="/home/ghaf/open_trusted"
LOG="${BASE}/open_trusted.sh.log"

function Ord {
    printf "%d" "\"$1"
}

function Chr {
    printf "%b" "$(printf "\\\\x%02x" "$1")"
}

function Msg {
    local len b1 b2 b3 b4

    len="${#1}"
    b1="$(( len & 255 ))"
    b2="$(( (len >> 8) & 255 ))"
    b3="$(( (len >> 16) & 255 ))"
    b4="$(( (len >> 24) & 255 ))"
    Chr "$b1"
    Chr "$b2"
    Chr "$b3"
    Chr "$b4"
    printf "%s" "$1"
}

LANG=C IFS= read -r -d '' -n 1 B1
LANG=C IFS= read -r -d '' -n 1 B2
LANG=C IFS= read -r -d '' -n 1 B3
LANG=C IFS= read -r -d '' -n 1 B4

if [ -z "$B1" ]; then
    B1=0
else
    B1="$(Ord "$B1")"
fi
if [ -z "$B2" ]; then
    B2=0
else
    B2="$(Ord "$B2")"
fi
if [ -z "$B3" ]; then
    B3=0
else
    B3="$(Ord "$B3")"
fi
if [ -z "$B4" ]; then
    B4=0
else
    B4="$(Ord "$B4")"
fi

LEN="$(( B1 + (B2 << 8) + (B3 << 16) + (B4 << 24) ))"

date >> "$LOG"
echo "$LEN" >> "$LOG"

if [ "$LEN" -lt 0 ] || [ "$LEN" -gt 4096 ]; then
    Msg "{\"status\":\"Failed\"}"
    exit 1
fi

LANG=C IFS= read -r -d '' -n "$LEN" JSON
PFX="{\"URL\":\""
URL="${JSON##"$PFX"}"
SFX="\"}"
URL="${URL%%"$SFX"}"
echo "$URL" >> "$LOG"

ssh -o StrictHostKeyChecking=no business-vm "run-waypipe chromium --enable-features=UseOzonePlatform --ozone-platform=wayland \"${URL}\""

Msg "{\"status\":\"Ok\"}"
