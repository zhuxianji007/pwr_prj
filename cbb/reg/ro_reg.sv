//============================================================
//Module   : ro_reg
//Function : read only register
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module ro_reg #(
    parameter DW                   = 8          ,
    parameter AW                   = 8          ,
    parameter REG_ADDR             = {AW{1'b0}} ,
    parameter SUPPORT_TEST_MODE_RD = 1'b1       ,
    parameter SUPPORT_CFG_MODE_RD  = 1'b1       ,
    parameter SUPPORT_SPI_EN_RD    = 1'b1       , 
    parameter END_OF_LIST          = 1
)( 
    input  logic 		   i_ren                ,
    input  logic           i_test_st_reg_en     ,
    input  logic           i_cfg_st_reg_en      ,
    input  logic           i_spi_ctrl_reg_en    ,
    input  logic [AW-1: 0] i_addr               ,
    input  logic [DW-1: 0] i_ff_data            ,//from inner logic flip_flop
    output logic [DW-1: 0] o_rdata              ,
    input  logic           i_clk                ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic ren;
logic hit;
//==================================
//main code
//==================================
assign hit = (i_addr==REG_ADDR);
assign ren = i_ren & hit & ((i_test_st_reg_en & SUPPORT_TEST_MODE_RD) | (i_cfg_st_reg_en & SUPPORT_CFG_MODE_RD) | (i_spi_ctrl_reg_en & SUPPORT_SPI_EN_RD));
   
assign o_rdata = ren ? i_ff_data : {DW{1'b0}}; 

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
