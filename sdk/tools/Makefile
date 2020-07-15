all: $(patsubst %.c,%.exe,$(wildcard *.c))

%.exe: %.c
	gcc -o $@ $<

clean:
	rm *.exe
