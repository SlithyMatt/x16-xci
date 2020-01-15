ALL_OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
ALL_HDRS = $(wildcard *.h)

all: $(ALL_OBJS) $(ALL_HDRS)
	gcc -o xci.exe $(ALL_OBJS)
%.o: %.c
	gcc -c $< -o $@
