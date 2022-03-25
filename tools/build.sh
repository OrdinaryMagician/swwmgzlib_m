#!/bin/sh
gcc -std=c2x -march=native -Os -Wall -Wextra -Werror -pedantic -lm -ljansson -o fontatlas fontatlas.c
