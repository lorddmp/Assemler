#!/bin/bash

nasm -g -f elf64 haha.asm -o printf.o
gcc  -g -c haha.c -o haha.o
gcc -g -no-pie haha.o printf.o -o proga
./proga