//============================================================
//Module   : wo_reg
//Function : write only register, generate pulse signal
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module wo_reg #(
    parameter DW                   = 8          ,
    parameter AW                   = 8          ,
    parameter DEFAULT_VAL          = {DW{1'b0}} ,
    parameter REG_ADDR             = {AW{1'b0}} ,
    parameter SUPPORT_TEST_MODE_WR = 1'b1       ,
    parameter SUPPORT_CFG_MODE_WR  = 1'b1       ,
    parameter SUPPORT_SPI_EN_WR    = 1'b1       ,
    parameter SUPPORT_EFUSE_WR     = 1'b1       , 
    parameter END_OF_LIST          = 1
)( 
    input  logic           i_wen                ,
    input  logic           i_test_st_reg_en     ,
    input  logic           i_cfg_st_reg_en      ,
    input  logic           i_spi_ctrl_reg_en    ,
    input  logic           i_efuse_ctrl_reg_en  ,
    input  logic [AW-1: 0] i_addr               ,
    input  logic [DW-1: 0] i_wdata              ,
    output logic [DW-1: 0] o_rdata              ,
    output logic [DW-1: 0] o_reg_data           ,
    input  logic           i_clk                ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic           wen     ;
logic           ren     ;
logic           hit     ;
logic [DW-1: 0] reg_data;
//==================================
//main code
//==================================
assign hit = (i_addr==REG_ADDR);
assign wen = i_wen & hit & ((i_test_st_reg_en & SUPPORT_TEST_MODE_WR) | (i_cfg_st_reg_en & SUPPORT_CFG_MODE_WR) | (i_spi_ctrl_reg_en & SUPPORT_SPI_EN_WR) | (i_efuse_ctrl_reg_en & SUPPORT_EFUSE_WR));
  
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    reg_data <= DEFAULT_VAL;
	end
  	else begin
	    reg_data <= wen ? i_wdata : DEFAULT_VAL;
	end
end

assign o_reg_data = reg_data    ;    
assign o_rdata    = {DW{1'b0}}  ; 

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
