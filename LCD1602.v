module LCD1602(
	input			   CLK,//1kHz时钟
	input 			sw,
	output	 		LCD_E,
	output reg 		LCD_RS,
	output reg[7:0]LCD_DATA
);
reg		[127:0]		row_1;					//LCD第一行显示的内容，共16个字符
reg		[127:0]		row_2;					//LCD第二行显示的内容，共16个字符
reg 		[6:0]			count_row;				//计数器，控制作者信息与欢迎语句的循环显示
reg 		[11:0]		count_off;				//计数器，计算关机时间
initial begin
	count_row<=0;
	count_off<=0;
end
always@(posedge CLK)begin						//计算关机的时间，用来判断显示欢迎使用还是欢迎下次使用
	if(sw)count_off<=0;
	else if(!sw&&count_off<4024)count_off<=count_off+1;
	else count_off<=count_off;
end
always@(posedge CLK)begin						//控制显示内容
	count_row<=count_row+1;
	if(sw==0&&count_off<4000)					//关机一段时间内显示“作者信息”与“欢迎下次使用”
		if(count_row<33)begin
		//			 "1234567890123456" 			//这串字符当尺子用
			row_1 =" Welcome to use ";
			row_2 ="Lisai 2019210774";
		end
		else begin
			row_1 ="author:     BUPT";
			row_2 =" next  time  !  ";
		end
	else												//关机足够时间后显示“作者信息”与“欢迎使用”
		if(count_row<33)begin
		//			 "1234567890123456"
			row_1 =" Welcome to use ";
			row_2 ="Lisai 2019210774";
		end
		else begin
			row_1 ="author:     BUPT";
			row_2 =" my  air  fan  !";
		end
	if(count_row==65)count_row<=0;else;
end

parameter		TIME_20MS=20;							//需要20ms以达上电稳定(初始化)
reg		[4:0]	cnt_20ms;									//延时计数器
reg 				delay_done;
initial begin
	delay_done<=0;
	cnt_20ms<=0;
end
always@(posedge CLK)begin
	if(cnt_20ms==TIME_20MS-1'b1)delay_done<=1;//延时完成
	else cnt_20ms<=cnt_20ms+1'b1;
end

parameter 		TIME_500HZ=2;							//工作周期是500Hz
reg		[1:0]	cnt_500hz;
initial begin
	cnt_500hz<=0;
end
always@(posedge CLK)begin
	if(delay_done)//如果延时完毕
		if(cnt_500hz==TIME_500HZ-1'b1)cnt_500hz<=1'b0;
		else cnt_500hz<=cnt_500hz+1'b1;
	else cnt_500hz<=1'b0;
end
assign	LCD_E=(cnt_500hz>(TIME_500HZ-1'b1)/2)?1'b0:1'b1;//使能端,每个工作周期一次下降沿,执行一次命令
wire 		write_flag=(cnt_500hz==TIME_500HZ-1'b1)?1'b1:1'b0;//每到一个工作周期,write_flag置高一周期

//状态机有40种状态,此处用的是格雷码,用什么码赋值是无所谓的，只是用于判断罢了
parameter IDLE=			8'b0000_0000;
parameter SET_FUNCTION=	8'b0000_0001;
parameter DISP_OFF=		8'b0000_0011;
parameter DISP_CLEAR=	8'b0000_0010;
parameter ENTRY_MODE=	8'b0000_0110;
parameter DISP_ON=		8'b0000_0111;
parameter ROW1_ADDR=		8'b0000_0101;
parameter ROW1_0=			8'b0000_0100;
parameter ROW1_1=			8'b0000_1100;
parameter ROW1_2=			8'b0000_1101;
parameter ROW1_3=			8'b0000_1111;
parameter ROW1_4=			8'b0000_1110;
parameter ROW1_5=			8'b0000_1010;
parameter ROW1_6=			8'b0000_1011;
parameter ROW1_7=			8'b0000_1001;
parameter ROW1_8=			8'b0000_1000;
parameter ROW1_9=			8'b0001_1000;
parameter ROW1_A=			8'b0001_1001;
parameter ROW1_B=			8'b0001_1011;
parameter ROW1_C=			8'b0001_1010;
parameter ROW1_D=			8'b0001_1110;
parameter ROW1_E=			8'b0001_1111;
parameter ROW1_F=			8'b0001_1101;
parameter ROW2_ADDR=		8'b0001_1100;
parameter ROW2_0=			8'b0001_0100;
parameter ROW2_1=			8'b0001_0101;
parameter ROW2_2=			8'b0001_0111;
parameter ROW2_3=			8'b0001_0110;
parameter ROW2_4=			8'b0001_0010;
parameter ROW2_5=			8'b0001_0011;
parameter ROW2_6=			8'b0001_0001;
parameter ROW2_7=			8'b0001_0000;
parameter ROW2_8=			8'b0011_0000;
parameter ROW2_9=			8'b0011_0001;
parameter ROW2_A=			8'b0011_0011;
parameter ROW2_B=			8'b0011_0010;
parameter ROW2_C=			8'b0011_0110;
parameter ROW2_D=			8'b0011_0111;
parameter ROW2_E=			8'b0011_0101;
parameter ROW2_F=			8'b0011_0100;

reg[5:0]c_state;//Current state,当前状态
reg[5:0]n_state;//Next state,下一状态
initial begin
	c_state<=IDLE;
end
always@(posedge CLK)begin
	if(write_flag)													//每一个工作周期改变一次状态
		c_state<=n_state;
	else
		c_state<=c_state;
end
always@(posedge CLK)begin
	case (c_state)
		IDLE:				n_state=SET_FUNCTION;
		SET_FUNCTION:	n_state=DISP_OFF;
		DISP_OFF:		n_state=DISP_CLEAR;
		DISP_CLEAR:		n_state=ENTRY_MODE;
		ENTRY_MODE:		n_state=DISP_ON;
		DISP_ON:			n_state=ROW1_ADDR;
		ROW1_ADDR:		n_state=ROW1_0;
		ROW1_0:			n_state=ROW1_1;
		ROW1_1:			n_state=ROW1_2;
		ROW1_2:			n_state=ROW1_3;
		ROW1_3:			n_state=ROW1_4;
		ROW1_4:			n_state=ROW1_5;
		ROW1_5:			n_state=ROW1_6;
		ROW1_6:			n_state=ROW1_7;
		ROW1_7:			n_state=ROW1_8;
		ROW1_8:			n_state=ROW1_9;
		ROW1_9:			n_state=ROW1_A;
		ROW1_A:			n_state=ROW1_B;
		ROW1_B:			n_state=ROW1_C;
		ROW1_C:			n_state=ROW1_D;
		ROW1_D:			n_state=ROW1_E;
		ROW1_E:			n_state=ROW1_F;
		ROW1_F:			n_state=ROW2_ADDR;
		ROW2_ADDR:		n_state=ROW2_0;
		ROW2_0:			n_state=ROW2_1;
		ROW2_1:			n_state=ROW2_2;
		ROW2_2:			n_state=ROW2_3;
		ROW2_3:			n_state=ROW2_4;
		ROW2_4:			n_state=ROW2_5;
		ROW2_5:			n_state=ROW2_6;
		ROW2_6:			n_state=ROW2_7;
		ROW2_7:			n_state=ROW2_8;
		ROW2_8:			n_state=ROW2_9;
		ROW2_9:			n_state=ROW2_A;
		ROW2_A:			n_state=ROW2_B;
		ROW2_B:			n_state=ROW2_C;
		ROW2_C:			n_state=ROW2_D;
		ROW2_D:			n_state=ROW2_E;
		ROW2_E:			n_state=ROW2_F;
		ROW2_F:			n_state=ROW1_ADDR;				//LCD的整个工作循环流程
		default:;
	endcase
end

initial begin
	LCD_RS<=1'b0;												//初始化，为0时输入指令,为1时输入数据
end	
always@(posedge CLK)begin
	if(write_flag)
		//当状态为七个指令任意一个,将RS置为指令输入状态
		if((n_state==SET_FUNCTION)||(n_state==DISP_OFF)||(n_state==DISP_CLEAR)||(n_state==ENTRY_MODE)||(n_state==DISP_ON)||(n_state==ROW1_ADDR)||(n_state==ROW2_ADDR))
			LCD_RS<=1'b0; 
		else
			LCD_RS<=1'b1;
	else
		LCD_RS<=LCD_RS;
end
initial begin
	LCD_DATA<=1'b0;
end	
always@(posedge CLK)begin									//LCD的整个工作循环流程
	if(write_flag)
		case(n_state)
			IDLE:					LCD_DATA<=8'hxx;
			SET_FUNCTION:		LCD_DATA<=8'b0011_1000;	//工作方式设置:DL=1(DB4,8位数据接口),N=1(DB3,两行显示),L=0(DB2,5x8点阵显示).
			DISP_OFF:			LCD_DATA<=8'b0000_1000;	//显示开关设置:D=0(DB2,显示关),C=0(DB1,光标不显示),D=0(DB0,光标不闪烁)
			DISP_CLEAR:			LCD_DATA<=8'b0000_0001;	//清屏
			ENTRY_MODE:			LCD_DATA<=8'b0000_0110;	//进入模式设置:I/D=1(DB1,写入新数据光标右移),S=0(DB0,显示不移动)
			DISP_ON:				LCD_DATA<=8'b0000_1100;	//显示开关设置:D=1(DB2,显示开),C=0(DB1,光标不显示),D=0(DB0,光标不闪烁)
			ROW1_ADDR:			LCD_DATA<=8'b1000_0000;	//设置DDRAM地址:00H->1-1,第一行第一位
			//将输入的row_1以每8-bit拆分,分配给对应的显示位
			ROW1_0:		LCD_DATA<=row_1[127:120];
			ROW1_1:		LCD_DATA<=row_1[119:112];
			ROW1_2:		LCD_DATA<=row_1[111:104];
			ROW1_3:		LCD_DATA<=row_1[103: 96];
			ROW1_4:		LCD_DATA<=row_1[ 95: 88];
			ROW1_5:		LCD_DATA<=row_1[ 87: 80];
			ROW1_6:		LCD_DATA<=row_1[ 79: 72];
			ROW1_7:		LCD_DATA<=row_1[ 71: 64];
			ROW1_8:		LCD_DATA<=row_1[ 63: 56];
			ROW1_9:		LCD_DATA<=row_1[ 55: 48];
			ROW1_A:		LCD_DATA<=row_1[ 47: 40];
			ROW1_B:		LCD_DATA<=row_1[ 39: 32];
			ROW1_C:		LCD_DATA<=row_1[ 31: 24];
			ROW1_D:		LCD_DATA<=row_1[ 23: 16];
			ROW1_E:		LCD_DATA<=row_1[ 15:  8];
			ROW1_F:		LCD_DATA<=row_1[  7:  0];
			ROW2_ADDR:	LCD_DATA<=8'hc0;					//8'b1100_0000,设置DDRAM地址:40H->2-1,第二行第一位
			ROW2_0:		LCD_DATA<=row_2[127:120];
			ROW2_1:		LCD_DATA<=row_2[119:112];
			ROW2_2:		LCD_DATA<=row_2[111:104];
			ROW2_3:		LCD_DATA<=row_2[103: 96];
			ROW2_4:		LCD_DATA<=row_2[ 95: 88];
			ROW2_5:		LCD_DATA<=row_2[ 87: 80];
			ROW2_6:		LCD_DATA<=row_2[ 79: 72];
			ROW2_7:		LCD_DATA<=row_2[ 71: 64];
			ROW2_8:		LCD_DATA<=row_2[ 63: 56];
			ROW2_9:		LCD_DATA<=row_2[ 55: 48];
			ROW2_A:		LCD_DATA<=row_2[ 47: 40];
			ROW2_B:		LCD_DATA<=row_2[ 39: 32];
			ROW2_C:		LCD_DATA<=row_2[ 31: 24];
			ROW2_D:		LCD_DATA<=row_2[ 23: 16];
			ROW2_E:		LCD_DATA<=row_2[ 15:  8];
			ROW2_F:		LCD_DATA<=row_2[  7:  0];
		endcase
	else
		LCD_DATA<=LCD_DATA;
end		
endmodule