`timescale 1ns/1ps
module CLK_n_tb;

reg 				signal_clk;
wire 				signal_clk_n;
reg 	[9:0]		tem;

CLK_n c1(
	.clk(signal_clk),
	.n(10),
	.clk_n(signal_clk_n)
);

initial begin
	for(tem=0;tem<50;tem=tem+1)begin
		signal_clk=0;
		#100;
		signal_clk=1;
		#100;
	end
	$stop;
end

endmodule