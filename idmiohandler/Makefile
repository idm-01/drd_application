#
# Configuration
#
SOURCES := idmiohandler.c
CFLAGS := -std=gnu18
LDFLAGS := -lserialport
CC := clang

#
# Auto-generated
#
OBJECTS := $(subst .c,.o,$(SOURCES))

all: link

clean:
	@echo -e "\e[32mCleaning...\e[0m"
	@rm -rf $(OBJECTS)
	@rm -rf idmiohandler

build: clean
	@echo -e "\e[32mBuilding...\e[0m"
	@$(CC) $(CFLAGS) -c $(SOURCES)

link: build
	@echo -e "\e[32mLinking...\e[0m"
	@$(CC) $(CFLAGS) $(LDFLAGS) -o idmiohandler $(OBJECTS)
	@echo -e "\e[32mBuilt idmiohandler.\e[0m"

install: link
	@mv idmiohandler /usr/bin/idmiohandler