
all:
	elm make src/Main.elm --output=main.js

init:
	elm install elm/time
	elm install elm/random

run:
	chromium index.html

clean:
	rm -rf elm-stuff main.js

