ALL_ASM = $(wildcard *.asm) $(wildcard *.inc)

all: $(ALL_ASM)
	cl65 --cpu 65C02 -o XCI.PRG -l xci.list xci.asm

clean:
	rm -f *.PRG *.prg *.list *.o

test: mouse_test

mouse_test: $(ALL_ASM)
	cl65 --cpu 65C02 -o mouse_test.prg -l mouse_test.list mouse_test.asm
