all:
	iverilog -g2005-sv -DICARUS=1 main.v kr580.v -o main.qqq 
	vvp main.qqq >> /dev/null
vcd:
	gtkwave main.vcd
