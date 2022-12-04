//============================================================
//Module   : rstn_sync
//Function : asyn rstn, sync release rst.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module rstn_sync #(
    parameter END_OF_LIST = 1
)( 
    input  logic           i_clk        ,
    input  logic           i_asyn_rst_n ,
    output logic           o_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam RST_SYNC_LVL = 2;
//==================================
//var delcaration
//==================================
logic [RST_SYNC_LVL-1: 0] rst_n;
//==================================
//main code
//==================================  
always_ff@(posedge i_clk or negedge i_asyn_rst_n) begin
    if(~i_asyn_rst_n) begin
	    rst_n[RST_SYNC_LVL-1: 0] <= {RST_SYNC_LVL{1'b0}};
	end
  	else begin
	    rst_n[RST_SYNC_LVL-1: 0] <= {rst_n[RST_SYNC_LVL-2: 0], 1'b1};
	end
end

assign o_rst_n = rst_n[RST_SYNC_LVL-1];    

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
