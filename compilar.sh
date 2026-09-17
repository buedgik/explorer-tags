#!/bin/sh
# Compila um mod como o Windhawk o compila (argumentos tirados de
# UI/resources/app/extensions/windhawk/dist/extension.js). Só verifica: o DLL
# vai para a pasta temporária, o Windhawk não o carrega.
# Uso: sh compilar.sh explorer-tags.wh.cpp
set -e
MOD="$1"
WH="/c/Program Files/Windhawk"
OUT="${TMPDIR:-/tmp}/$(basename "$MOD" .wh.cpp).dll"
ID=$(sed -n 's|^// @id *||p' "$MOD" | tr -d '\r')
VER=$(sed -n 's|^// @version *||p' "$MOD" | tr -d '\r')
OPTS=$(sed -n 's|^// @compilerOptions *||p' "$MOD" | tr -d '\r')
cd "$WH/Compiler"
# shellcheck disable=SC2086
./bin/clang++.exe -std=c++23 -O2 -shared -DUNICODE -D_UNICODE \
  -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00 -D_WIN32_IE=0x0A00 -DNTDDI_VERSION=0x0A000008 \
  -D__USE_MINGW_ANSI_STDIO=0 -DWH_MOD "-DWH_MOD_ID=L\"$ID\"" "-DWH_MOD_VERSION=L\"$VER\"" \
  "$WH/Engine/1.7.3/64/windhawk.lib" -x c++ - -include windhawk_api.h \
  -target x86_64-w64-mingw32 -Wl,--export-all-symbols -o "$OUT" -Wall $OPTS < "$OLDPWD/$MOD"
echo "ok: $OUT"
