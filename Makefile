SOURCES := src/Main.elm

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
