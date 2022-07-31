module debounce(							//按键消抖模块
input           clk,						//1kHz时钟
input   [4:0]   key,                //输入的按键					
output  [4:0]   key_pulse  			//按键动作产生的脉冲	
);
                
reg     [4:0]   key_rst_pre;        //定义一个寄存器型变量存储上一个触发时的按键值
reg     [4:0]   key_rst;            //定义一个寄存器变量储存储当前时刻触发的按键值
wire    [4:0]   key_edge;           //检测到按键由高到低变化是产生一个高脉冲		  
reg 	  [4:0]     cnt;              //产生延时所用的计数器，系统时钟1kHz，要延时20ms左右时间，至少需要5位计数器     

initial begin
key_rst <= 5'b11111;            		//初始化时给key_rst赋值全为1，{}中表示N个1
key_rst_pre <= 5'b11111;
cnt <= 5'b0;
end
//利用非阻塞赋值特点，将两个时钟触发时按键状态存储在两个寄存器变量中
always @(posedge clk)begin
key_rst <= key;            			//第一个时钟上升沿触发之后key的值赋给key_rst,同时key_rst的值赋给key_rst_pre
key_rst_pre <= key_rst;    			//非阻塞赋值。    
end											//相当于经过两个时钟触发，key_rst存储的是当前时刻key的值，key_rst_pre存储的是前一个时钟的key的值

assign key_edge = key_rst_pre & (~key_rst);//脉冲边沿检测。当key检测到下降沿时，key_edge产生一个时钟周期的高电平

//产生20ms延时，当检测到key_edge有效是计数器清零开始计数
always @(posedge clk)begin
if(key_edge)cnt <= 5'b0;
else cnt <= cnt + 1'b1;
end  
 
reg     [4:0]   key_sec_pre;        //延时后检测电平寄存器变量
reg     [5:0]   key_sec;                    
 
initial begin
key_sec_pre <=5'b11111;             //初始化
key_sec <=5'b11111;
end

//延时后检测key，如果按键状态变低产生一个时钟的高脉冲。如果按键状态是高的话说明按键无效
always @(posedge clk)begin
if (cnt==22)key_sec <= key;  
end

always @(posedge clk)begin
key_sec_pre <= key_sec;             
end      

assign  key_pulse = key_sec_pre & (~key_sec);
endmodule
