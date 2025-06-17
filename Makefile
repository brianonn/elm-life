SOURCES      := src/Main.elm
UNAME_S      := $(shell uname -s | tr A-Z a-z)
ifeq ($(suffix $(SHELL)),.exe)
    # Windows system .
    # TODO: MinGW/MinGW-w64 systems
    OS_NAME ?= windows
else
    # Non-Windows systems
    # I expect Microsoft WSL to identify as 'linux'
    OS_NAME ?= $(UNAME_S)
endif

## OS specific webpage opener commands.
## You can also specify OPEN=<command>, for example, `make OPEN=opera run`
OPEN-linux   := chromium  # xdg-open is better but you can also force a specific browser here too
OPEN-darwin  := open
OPEN-windows := start ""
OPEN         := $(OPEN-$(OS_NAME))

##
## make targets below
##
all: help

build: main.js		## (default) Build the standard version of the application

main.js: $(SOURCES)
	elm make $(SOURCES) $(DEBUG) --output=$@

debug: debug.html	## Build the debug version of the application
debug.html:
	elm make $(SOURCES) --debug --output=$@

deps:			## Install Elm dependancies
	elm install elm/time
	elm install elm/random

run:			## Run the standard version in the browser
	$(OPEN) index.html

run-debug:		## Run the debug version in the browser
	$(OPEN) debug.html

clean:			## Clean all files
	rm -rf elm-stuff main.js history-*.txt debug.html debug.js

help usage:		## Show this help
	@grep -E --color=always "^(\w+[ \t-]*\w+):.*##" $(MAKEFILE_LIST) \
		| sed -E -e 's/(.*:).*##(.*$$)/\1\2/' \
		| column -s: -t
