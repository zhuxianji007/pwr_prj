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
	`include "com_param.svh"
    parameter END_OF_LIST          = 1
)(
    input  logic 		   i_bist_en            , 

    input  logic           i_lv_vsup_ov         ,

    output logic           o_lbist_en           ,
	output logic 		   o_lv_abist_fail      ,
	output logic 		   o_bistlv_ov 			,
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
logic [BIST_CNT_W-1: 0]  bist_cnt           ;
logic                    lv_abist_fail      ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    bist_cnt <= BIST_CNT_W'(0);
	end
  	else if(i_bist_en) begin
	    bist_cnt <= (bist_cnt==BIST_70US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else begin
	    bist_cnt <= BIST_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    lv_abist_fail <= 1'b0;
	end
	else if(i_bist_en) begin
  		if(i_lv_vsup_ov & (bist_cnt<BIST_70US_CYC_NUM)) begin
		    lv_abist_fail <= 1'b0;
		end
		else if(~i_lv_vsup_ov & (bist_cnt>=BIST_70US_CYC_NUM)) begin
		    lv_abist_fail <= 1'b1;		
		end
	end
    else begin
	    lv_abist_fail <= 1'b0;	
	end
end

assign o_lv_abist_fail = lv_abist_fail;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    o_lbist_en <= 1'b0;
	end
  	else if(i_bist_en) begin
        if(bist_cnt>=BIST_70US_CYC_NUM) begin
	        o_lbist_en <= 1'b1;
        end
        else;
	end
    else begin
	    o_lbist_en <= 1'b0;    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    o_bistlv_ov <= 1'b0;
	end
  	else if(i_bist_en) begin
	    o_bistlv_ov <= (bist_cnt<BIST_70US_CYC_NUM) ? 1'b1 : 1'b0;
	end
    else begin
	    o_bistlv_ov <= 1'b0;  
    end
end
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule



