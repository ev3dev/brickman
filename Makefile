
CFLAGS = -Wall `pkg-config --cflags glib-2.0` `pkg-config --cflags dbus-glib-1`
LDLIBS = -lu8g -lm2tk -lglib-2.0 -ludev -lncurses

all: brickdm

brickdm: brickdm_event.o

clean:
	rm -f *.o