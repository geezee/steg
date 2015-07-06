CC=dmd
TARGET=steg
CFLAGS=-O -Jsrc -Isrc -odsrc
CEXTRAFLAGS=

CC_OBJ=$(CC) -c $^ $(CFLAGS) $(CEXTRAFLAGS)
CC_BUILD=$(CC) $^ $(CFLAGS) $(CEXTRAFLAGS) -ofbin/$(TARGET)

CODE=$(wildcard src/*.d)
OBJECTS=$(patsubst %.d,%.o,$(CODE))

all: $(TARGET)

test: CEXTRAFLAGS=-unittest -cov
test: all
	@echo "Hello, World!" > /tmp/steg_cov_test.txt
	@./bin/$(TARGET) -c /tmp/steg_cov_test.txt a -o /tmp/steg_cov_test
	@rm /tmp/steg_cov_test.txt
	for lst in *.lst; do cat $$lst | tail -n 1; done

run:
	@./bin/$(TARGET)

clean:
	rm bin/$(TARGET)
	for file in $(OBJECTS); do rm $$file; done
	if ls *.lst 1> /dev/null 2>&1; then for cov in *.lst; do rm $$cov; done fi

%.o: %.d
	$(CC_OBJ)

$(TARGET): $(OBJECTS)
	$(CC_BUILD)
