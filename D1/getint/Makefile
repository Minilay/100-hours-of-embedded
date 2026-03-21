CC = gcc
CFLAGS = -Wall -Wextra -std=c11

OBJS = main.o getfloat.o getint.o readchar.o

all: main

main: $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f $(OBJS) main
