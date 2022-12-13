//============================================================
//Module   : signal_extend
//Function : input signal extend n cycle.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module signal_extend #(
    parameter  EXTEND_CYC_NUM = 12,
    localparam CNT_W          = (EXTEND_CYC_NUM==1) ? 1 : $clog2(EXTEND_CYC_NUM),
    parameter  END_OF_LIST    = 1
)( 
    input  logic           i_vld        ,
    input  logic           i_vld_data   ,
    output logic           o_vld        ,
    output logic           o_vld_data   ,
    output logic           o_done       ,
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
logic               vld_lock        ;
logic               vld_data_lock   ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    vld_lock        <= 1'b0;
        vld_data_lock   <= 1'b0;
	end
  	else if(i_vld) begin
        vld_lock        <= 1'b1;
        vld_data_lock   <= i_vld_data;
    end
    else if(cnt==(EXTEND_CYC_NUM-1)) begin
        vld_lock        <= 1'b0;
        vld_data_lock   <= 1'b0;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    cnt <= CNT_W'(0);
	end
  	else if(i_vld | vld_lock) begin
        cnt <= (cnt==(EXTEND_CYC_NUM-1)) ? CNT_W'(0) : (cnt+1'b1);
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    o_vld        <= 1'b0;
        o_vld_data   <= 1'b0;
        o_done       <= 1'b0;
	end
  	else begin
        o_vld        <= i_vld | vld_lock;
        o_vld_data   <= (i_vld & i_vld_data) | (vld_lock & vld_data_lock);
        o_done       <= (cnt==(EXTEND_CYC_NUM-1));    
    end
end
// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif   
// synopsys translate_on    
endmodule

