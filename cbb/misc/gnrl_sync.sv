//============================================================
//Module   : gnrl_sync
//Function : general sync singal from one clk zone to another clk zone.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module gnrl_sync #(
    parameter DW                   = 8      ,
    parameter DEF_VAL              = DW'(0) ,
    parameter SYNC_PIPE_NUM        = 2      ,
    parameter END_OF_LIST          = 1
)( 
    input  logic [DW-1:     0]  i_data              ,
    output logic [DW-1:     0]  o_data              ,
    input  logic                i_clk	            ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic [SYNC_PIPE_NUM: 0][DW-1: 0] data;
//==================================
//main code
//==================================
assign data[0] = i_data;

generate
for(genvar i=0; i<SYNC_PIPE_NUM; i=i+1) begin: PIPE_DATA_BLK
    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            data[i+1] <= DEF_VAL;
        end
        else begin
	        data[i+1] <= data[i];
        end
    end
end
endgenerate

assign o_data = data[SYNC_PIPE_NUM];

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule
