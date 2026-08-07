CC      = gcc
CFLAGS  = -std=c99 -Wall -Wextra -O2 -g
LDFLAGS =

.PHONY: all clean run crash

all: example crash_demo

example: example.c zasm.c zasm.h
	$(CC) $(CFLAGS) -o example example.c zasm.c $(LDFLAGS)

crash_demo: crash_demo.c zasm.c zasm.h
	$(CC) $(CFLAGS) -o crash_demo crash_demo.c zasm.c $(LDFLAGS)

run: example
	./example

crash: crash_demo
	./crash_demo || true

clean:
	rm -f example crash_demo