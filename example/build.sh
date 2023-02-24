#!/bin/sh
rm *.BIN
cp ../engine/XCI.PRG .
cp ../sdk/xci.exe .
./xci.exe mygame.xci
