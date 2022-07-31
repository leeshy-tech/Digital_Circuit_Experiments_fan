`timescale 1ns/1ps
module picture_tb;

	reg 				signal_clk;
	wire	 [7:0]	signal_hang;
	wire 	 [7:0]	signal_red;
	wire 	 [7:0]	signal_green;
	reg	 [2:0]	P=3;
	reg  	 [9:0]	tem;//for循环所需的计数器
	
picture p1(//例化所测试模块
	.clk(signal_clk),
	.P(P),
	.hang(signal_hang),
	.red(signal_red),
	.green(signal_green)
);

initial begin
for(tem=0;tem<20;tem=tem+1)begin//产生大于两个图形显示周期的时钟信号
	signal_clk=0;
	#100;
	signal_clk=1;
	#100;
	end
	$stop;	
end

initial begin//在中途改变参数P的值
	#1000;
	P=2;
end

endmodule
