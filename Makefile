
CFLAGS = -Wall `pkg-config --cflags glib-2.0` `pkg-config --cflags dbus-glib-1`

OBJ = brickdm.o brickdm_event.o

all: brickdm

brickdm: $(OBJ)
	$(CC) -g -o $@ -lu8g -lm2tk -lglib-2.0 -ludev $?
