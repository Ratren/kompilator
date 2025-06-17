#!/bin/bash
rm -f lex.yy.c gramatyka.tab.c gramatyka.tab.h kompilator kod_w_c.c program_wynikowy
flex analizator_leksykalny.l
bison gramatyka.y -d -Wcounterexamples
gcc lex.yy.c gramatyka.tab.c -lfl -o kompilator
./kompilator < "$1" > kod_w_c.c
gcc kod_w_c.c -o program_wynikowy
./program_wynikowy
