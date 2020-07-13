#!/bin/sh

iverilog -g2005-sv -DICARUS=1 main.v z80.v -o main.qqq 
vvp main.qqq >> /dev/null

# gtkwave main.vcd

echo 'OK'
