ALL_ASM = $(wildcard *.asm) $(wildcard *.inc)

all: $(ALL_ASM)
	cl65 --cpu 65C02 -o XCI.PRG -l xci.list xci.asm

clean:
	rm -f XCI.PRG xci.list *.o
