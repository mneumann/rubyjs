CC=cc
CFLAGS=-I/usr/local/include -I/usr/pkg/include
LDFLAGS=-L/usr/local/lib -L/usr/pkg/lib
LIBS=-ljs -lm -lpthread

RunScript: RunScript.c
	${CC} ${CFLAGS} ${LDFLAGS} ${LIBS} RunScript.c -o RunScript
