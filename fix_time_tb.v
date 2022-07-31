`timescale 1ns/1ps
module fix_time_tb;
	reg 				signal_clk;
	reg 				signal_sw;
	reg 	[4:0]		signal_ANJIAN;
	reg   [9:0]		tem;
	wire 	[1:0]		signal_time_model;
	wire 	[5:0]		signal_Time;
fix_time#(.N(3)) ft1(
	.clk(signal_clk),
	.sw(signal_sw),
	.ANJIAN(signal_ANJIAN),
	.time_model(signal_time_model),
	.Time(signal_Time)
);
initial begin
	signal_sw<=1;
	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b00100;
	#200
	signal_ANJIAN<=5'b00000;
	#300

	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b00100;
	#200
	signal_ANJIAN<=5'b00000;
	#300

	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b00100;
	#200
	signal_ANJIAN<=5'b00000;
	#200
	
	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b00100;
	#200
	signal_ANJIAN<=5'b00000;
	#300

	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b01000;
	#200
	signal_ANJIAN<=5'b00000;
	#300

	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b00100;
	#200
	signal_ANJIAN<=5'b00000;
	#200

	signal_ANJIAN<=5'b00000;
	#200
	signal_ANJIAN<=5'b10000;
	#200
	signal_ANJIAN<=5'b00000;
	#4500
	signal_sw<=0;
	#500
	signal_sw<=1;
end
initial begin
	for(tem=0;tem<60;tem=tem+1)begin
	signal_clk=0;
	#100;
	signal_clk=1;
	#100;
	end
end
endmodule