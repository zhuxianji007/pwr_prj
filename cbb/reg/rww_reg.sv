//============================================================
//Module   : rww_reg
//Function : read&write&write register, can be write&read by cpu & set by inner logic circuit
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module rww_reg #(
    parameter DW                   = 8          ,
    parameter AW                   = 8          ,
    parameter DEFAULT_VAL          = {DW{1'b0}} ,
    parameter REG_ADDR             = {AW{1'b0}} ,
    parameter SUPPORT_TEST_MODE_WR = 1'b1       ,
    parameter SUPPORT_TEST_MODE_RD = 1'b1       ,
    parameter SUPPORT_CFG_MODE_WR  = 1'b1       ,
    parameter SUPPORT_CFG_MODE_RD  = 1'b1       ,
    parameter SUPPORT_SPI_EN_WR    = 1'b1       ,
    parameter SUPPORT_SPI_EN_RD    = 1'b1       ,
    parameter SUPPORT_EFUSE_WR     = 1'b1       , 
    parameter END_OF_LIST          = 1
)( 
    input  logic           i_wen                ,
    input  logic           i_ren                ,
    input  logic           i_test_st_reg_en     ,
    input  logic           i_cfg_st_reg_en      ,
    input  logic           i_spi_ctrl_reg_en    ,
    input  logic           i_efuse_ctrl_reg_en  ,	
    input  logic [AW-1: 0] i_addr               ,
    input  logic [DW-1: 0] i_wdata              ,
    output logic [DW-1: 0] o_rdata              ,
    output logic [DW-1: 0] o_reg_data           ,
    input  logic           i_lgc_wen            ,
    input  logic [DW-1: 0] i_lgc_wdata          ,
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
logic           lgc_wen ;
logic           ren     ;
logic           hit     ;
logic [DW-1: 0] reg_data;
//==================================
//main code
//==================================
assign hit      = (i_addr==REG_ADDR);
assign wen      = i_wen & hit & ((i_test_st_reg_en & SUPPORT_TEST_MODE_WR) | (i_cfg_st_reg_en & SUPPORT_CFG_MODE_WR) | (i_spi_ctrl_reg_en & SUPPORT_SPI_EN_WR));
assign ren      = i_ren & hit & ((i_test_st_reg_en & SUPPORT_TEST_MODE_RD) | (i_cfg_st_reg_en & SUPPORT_CFG_MODE_RD) | (i_spi_ctrl_reg_en & SUPPORT_SPI_EN_RD));
assign lgc_wen  = i_lgc_wen & (i_efuse_ctrl_reg_en & SUPPORT_EFUSE_WR);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        reg_data <= DEFAULT_VAL;
    end
    else if(wen) begin
        reg_data <= i_wdata;
    end
    else if(lgc_wen) begin
        reg_data <= i_lgc_wdata;
    end
    else;
end

assign o_reg_data = reg_data                   ;    
assign o_rdata    = ren ? reg_data : {DW{1'b0}}; 

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule























