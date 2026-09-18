#!/bin/sh
# Compiles a mod the way Windhawk compiles it (arguments taken from
# UI/resources/app/extensions/windhawk/dist/extension.js), for every
# architecture Windhawk builds, because a mistake can compile on one target and
# fail on another (a lambda where a CALLBACK is expected, for instance).
# Check only: the DLLs go to the temp folder, Windhawk doesn't load them.
# Usage: sh compilar.sh explorer-tags.wh.cpp
set -e
MOD="$1"
SRC="$(pwd)/$MOD"
WH="/c/Program Files/Windhawk"
ENGINE="$WH/Engine/1.7.3"
ID=$(sed -n 's|^// @id *||p' "$MOD" | tr -d '\r')
VER=$(sed -n 's|^// @version *||p' "$MOD" | tr -d '\r')
OPTS=$(sed -n 's|^// @compilerOptions *||p' "$MOD" | tr -d '\r')
cd "$WH/Compiler"

for PAIR in "x86_64-w64-mingw32 64" "i686-w64-mingw32 32" "aarch64-w64-mingw32 arm64"; do
  TARGET=${PAIR% *}
  ARCH=${PAIR#* }
  OUT="${TMPDIR:-/tmp}/$(basename "$MOD" .wh.cpp).$ARCH.dll"
  # shellcheck disable=SC2086
  ./bin/clang++.exe -std=c++23 -O2 -shared -DUNICODE -D_UNICODE \
    -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00 -D_WIN32_IE=0x0A00 -DNTDDI_VERSION=0x0A000008 \
    -D__USE_MINGW_ANSI_STDIO=0 -DWH_MOD "-DWH_MOD_ID=L\"$ID\"" "-DWH_MOD_VERSION=L\"$VER\"" \
    "$ENGINE/$ARCH/windhawk.lib" -x c++ - -include windhawk_api.h \
    -target "$TARGET" -Wl,--export-all-symbols -o "$OUT" -Wall $OPTS < "$SRC"
  echo "ok ($ARCH): $OUT"
done
