## Conways's Game of Life in Elm

I wanted to learn some Elm so I set out to create the Game of Life.

## Building it
Building from this repo requires elm 0.19.  First, clone the repo locally:
```bash
$ git clone https://github.com/brianonn/elm-life.git
Cloning into 'elm-life'...
remote: Enumerating objects: 50, done.
remote: Counting objects: 100% (50/50), done.
remote: Compressing objects: 100% (23/23), done.
remote: Total 50 (delta 21), reused 45 (delta 18), pack-reused 0 (from 0)
Receiving objects: 100% (50/50), 19.36 KiB | 19.36 MiB/s, done.
Resolving deltas: 100% (21/21), done.
```
Change directory into the cloned repo and use the `tree` command to see the worktree:
```bash
$ cd elm-life
$ tree
.
├── elm.json
├── images
│   └── screenshot.png
├── index.html
├── LICENSE
├── Makefile
├── README.md
└── src
    └── Main.elm
```
There is a `Makefile` at the top-level.  You can run `make help` (or simply `make`) to get the help text:
```bash
$ make
build        (default) Build the standard version of the application
debug        Build the debug version of the application
deps         Install Elm dependancies
run          Run the standard version in the browser
run-debug    Run the debug version in the browser
clean        Clean all files
help usage   Show this help
```

Next run `make deps` to install the Elm dependancies needed to build the application.
If you already have the dependancies installed you will see the output similar to below.
If you do not have these dependancies already installed then you will see it download and install them.

```bash
$ make deps
elm install elm/time
It is already installed!
elm install elm/random
It is already installed!
```
When you have all the dependancies installed, you can build the program with `make build`:
```bash
$ make build
elm make src/Main.elm --output=main.js
Dependencies ready!
Success! Compiled 1 module.

    Main ───> main.js
```
The Elm compiler will create the `main.js` file from the `src/Main.elm` file.
There is a `index.html` file at the top-level that will load and initialize the new `main.js`
file to start the Elm Application running.

## Running the Game of Life in your browser
Use the command `make run` to launch the browser with the game
```bash
$ make run
```
this will launch a default browser with the `index.html` file.
You can also simply load the index file yourself:

#### On MacOS
```bash
$ open index.html
```

#### On Linux
```bash
$ xdg-open index.html
```

## Game controls
When the game is started, you will see a randomized 60x60 cell grid for the Game of Life, and a row of 3 buttons at the bottom, \[Start]\[Step]\[Reset].

Press the \[Start] button to start the game running. The \[Start] button will change to a \[Stop] button
to stop the game.

Similarly, the \[Reset] button is only available when the game is stopped, and it will reset the
Game of Life grid to a random placement of cells.   When the game is running, the \[Reset] button
will become a \[Restart] button.  Pressing the \[Restart] button will immediately randomize the grid
and restart the game at generation 1.

When the game is stopped, the \[Step] button will become active.  It is greyed out while the game is running.
You can use the \[Step] button to single step to the next generation and watch the game progress.

There is also a slider to adjust the game speed in 50ms increments.

The generation counter is at the bottom of the page.

## Cleaning up
The command `make clean` will remove any built files from the local repository.

## Screenshot
![screenshot](images/screenshot.png)
