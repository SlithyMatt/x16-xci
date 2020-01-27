ALL_OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
ALL_HDRS = $(wildcard *.h)

all: $(ALL_OBJS) $(ALL_HDRS)
	gcc -o xci.exe $(ALL_OBJS)
%.o: %.c
	gcc -c $< -o $@

clean:
	rm -f xci.exe $(ALL_OBJS)

test: bitmap_test

bitmap_test: bitmap.h bitmap.c
	gcc -o bitmap.exe -DTEST bitmap.c
