//============================================================
//Module   : lv_core
//Function : rd hv reg and store them in lv
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_core #(
    include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_spi_sclk      ,
    input  logic                            i_spi_csb       ,
    input  logic                            i_spi_mosi      ,
    output logic                            o_spi_miso      , 

    output logic [ADC_DW-1:             0]  o_adc1_data    ,
    output logic [ADC_DW-1:             0]  o_adc2_data    ,

    input  logic                            i_clk          ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic       fsm_spi_slv_en  ;             
//==================================
//main code
//==================================
spi_slv U_SPI_SLV(
    .i_spi_sclk          (i_spi_sclk    ),
    .i_spi_csb           (i_spi_csb     ),
    .i_spi_mosi          (i_spi_mosi    ),
    .o_spi_miso          (o_spi_miso    ),

    .i_spi_slv_en        (fsm_spi_slv_en),

    .o_spi_reg_wr_req    ,
    .o_spi_reg_rd_req    ,
    .o_spi_reg_addr      ,
    .o_spi_reg_wdata     ,
    .o_spi_reg_wcrc      ,

    .i_reg_spi_wack      ,
    .i_reg_spi_rack      ,
    .i_reg_spi_data      ,
    .i_reg_spi_addr      ,

    .o_spi_err           ,

    .i_clk	            ,
    .i_rst_n
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule