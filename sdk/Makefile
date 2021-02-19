ALL_OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
ALL_HDRS = $(wildcard *.h)
GCC_CMD = gcc

all: $(ALL_OBJS) $(ALL_HDRS) dev_tools
	$(GCC_CMD) -o xci.exe $(ALL_OBJS)
%.o: %.c
	$(GCC_CMD) -c $< -o $@

clean:
	rm -f xci.exe $(ALL_OBJS)
	$(MAKE) -C tools clean

test: bitmap_test music_test

bitmap_test: bitmap.h bitmap.c
	$(GCC_CMD) -o bitmap.exe -DTEST bitmap.c

music_test: vgm2x16opm.h vgm2x16opm.c
	$(GCC_CMD) -o music.exe -DTEST vgm2x16opm.c

dev_tools:
	$(MAKE) -C tools
