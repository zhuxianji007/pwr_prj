//============================================================
//Module   : signal_detect
//Function : detect n contiune 1 or 0, and output 1 or 0.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module signal_detect #(
    parameter CNT_W         = 10        ,
    parameter DN_TH         = CNT_W'(4) ,//dn == down, th == threshold
    parameter UP_TH         = CNT_W'(8) ,//up == up,
    parameter MODE          = 1         ,//0: pwm mode; 1: owt mode.           
    parameter END_OF_LIST   = 1
)( 
    input  logic           i_vld        ,
    input  logic           i_vld_data   ,
    output logic           o_vld        ,
    output logic           o_vld_data   ,
    input  logic           i_clk        ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic [CNT_W-1: 0]  cnt             ;
logic               detect_start    ;
logic               detect_continue ;
logic               detect_end      ;
logic               last_vld        ;
logic               last_vld_data   ;
logic               detect_restart  ;
//==================================
//main code
//==================================
assign detect_start     = i_vld & (cnt==CNT_W'(0));
assign detect_continue  = i_vld & last_vld & (i_vld_data==last_vld_data);
generate
    if(MODE==0) begin: PWM_MODE
        assign detect_end       = i_vld & last_vld & (i_vld_data!=last_vld_data) & (cnt>=DN_TH) & (cnt<=UP_TH);
        assign detect_restart   = i_vld & last_vld & (i_vld_data==last_vld_data) & (cnt>=UP_TH);

        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
	            cnt <= CNT_W'(0);
	        end
            else if(detect_end | detect_restart) begin
                cnt <= CNT_W'(1);
            end
  	        else if(detect_start | detect_continue) begin
	            cnt <= cnt + 1'b1;
	        end
            else begin
                cnt <= CNT_W'(0);
            end
        end
    end
    else begin: OWT_MODE
        assign detect_end = i_vld & last_vld & (i_vld_data==last_vld_data) & (cnt>=DN_TH) & (cnt<UP_TH);

        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
	            cnt <= CNT_W'(0);
	        end
            else if(detect_end) begin
                cnt <= CNT_W'(0);
            end
  	        else if(detect_start | detect_continue) begin
	            cnt <= cnt + 1'b1;
	        end
            else begin
                cnt <= CNT_W'(0);
            end
        end        
    end
endgenerate

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    last_vld        <= 1'b0;
        last_vld_data   <= 1'b0;
	end
  	else if(i_vld) begin
        last_vld        <= 1'b1;
        last_vld_data   <= i_vld_data;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    o_vld        <= 1'b0;
        o_vld_data   <= 1'b0;
	end
  	else begin
        o_vld        <= detect_end;
        o_vld_data   <= last_vld_data;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON
para_dn_up_th_chk : assert property(dn_up_th_chk);
property dn_up_th_chk;
	@(posedge i_clk) (UP_TH >= DN_TH);
endproperty
`endif   
// synopsys translate_on    
endmodule



