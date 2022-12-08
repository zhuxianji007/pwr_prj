//============================================================
//Module   : lv_abist
//Function : lv analog circuit bist.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_abist #(
    `include "com_param.vh"
    parameter END_OF_LIST          = 1
)( 
    input  logic 		   i_bist_lv_ov         ,
    input  logic           i_lv_vsup_ov         ,

    output logic           o_bist_lv_ov_status  ,//1: bist success; 0: bist failure.
    input  logic           i_clk                ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
parameter BIST_70US_CYC_NUM    = 70*CLK_M                     ;
parameter BIST_CNT_W           = $clog2(BIST_70US_CYC_NUM+1)  ;
//==================================
//var delcaration
//==================================
logic [BIST_CNT_W-1: 0]  bist_cnt ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    bist_cnt <= BIST_CNT_W'(0);
	end
  	else if(i_bist_lv_ov) begin
	    bist_cnt <= (bist_cnt==BIST_70US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else begin
	    bist_cnt <= BIST_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    o_bist_lv_ov_status <= 1'b0;
	end
  	else if(i_lv_vsup_ov & (bist_cnt<BIST_70US_CYC_NUM)) begin
	    o_bist_lv_ov_status <= 1'b1;
	end
    else;
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
