all:
	iverilog -g2005-sv -DICARUS=1 main.v cpu.v -o main.qqq
	vvp main.qqq >> /dev/null
vcd:
	gtkwave main.vcd
wave:
	gtkwave main.gtkw
