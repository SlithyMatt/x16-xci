#!/bin/bash
cd engine
make
cd ../sdk
make clean
rm -f xci_sdk_linux_amd64.tar.gz
rm -f xci_sdk_windows_mingw64.zip
make clean
make
tar -zcvf xci_sdk_linux_amd64.tar.gz xci.exe
make clean
make -f Makefile.mingw
zip xci_sdk_windows_mingw64.zip xci.exe
cd ..
rm -f xci.zip
zip xci.zip engine/XCI.PRG sdk/xci_sdk_linux_amd64.tar.gz sdk/xci_sdk_windows_mingw64.zip
