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

    output logic [ADC_DW-1:             0]  o_adc1_data     ,
    output logic [ADC_DW-1:             0]  o_adc2_data     ,

    input  logic                            i_clk           ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                       fsm_spi_slv_en      ;
logic                       spi_rac_wr_req      ;
logic                       spi_rac_rd_req      ;
logic [REG_AW-1:        0]  spi_rac_addr        ; 
logic [REG_DW-1:        0]  spi_rac_wdata       ;
logic [REG_CRC_W-1:     0]  spi_rac_wcrc        ; 
logic                       rac_spi_wack        ;
logic                       rac_spi_rack        ;
logic [REG_DW-1:        0]  rac_spi_data        ;
logic [REG_AW-1:        0]  rac_spi_addr        ; 
logic                       spi_reg_slv_err     ; 

logic                       wdg_scan_rac_rd_req ;
logic [REG_AW-1:        0]  wdg_scan_rac_addr   ;
logic                       rac_wdg_scan_ack    ;
logic [REG_DW-1:        0]  rac_wdg_scan_data   ;
logic [REG_CRC_W-1:     0]  rac_wdg_scan_crc    ;

logic                       spi_owt_wr_req      ;
logic                       spi_owt_rd_req      ;
logic [REG_AW-1:        0]  spi_owt_addr        ;
logic [REG_DW-1:        0]  spi_owt_data        ;
logic                       owt_spi_wack        ;
logic                       owt_spi_rack        ;
logic                       spi_rst_wdg         ;

logic                       rac_reg_ren         ;
logic                       rac_reg_wen         ;
logic [REG_AW-1:        0]  rac_reg_addr        ;
logic [REG_DW-1:        0]  rac_reg_wdata       ;
logic [REG_CRC_W-1:     0]  rac_reg_wcrc        ;

logic                       reg_rac_wack        ;
logic                       reg_rac_rack        ;
logic [REG_DW-1:        0]  reg_rac_rdata       ;
logic [REG_CRC_W-1:     0]  reg_rac_rcrc        ;
//==================================
//main code
//==================================
spi_slv U_SPI_SLV(
    .i_spi_sclk                 (i_spi_sclk             ),
    .i_spi_csb                  (i_spi_csb              ),
    .i_spi_mosi                 (i_spi_mosi             ),
    .o_spi_miso                 (o_spi_miso             ),

    .i_spi_slv_en               (fsm_spi_slv_en         ),

    .o_spi_rac_wr_req           (spi_rac_wr_req         ),
    .o_spi_rac_rd_req           (spi_rac_rd_req         ),
    .o_spi_rac_addr             (spi_rac_addr           ),
    .o_spi_rac_wdata            (spi_rac_wdata          ),
    .o_spi_rac_wcrc             (spi_rac_wcrc           ),

    .i_reg_spi_wack             (rac_spi_wack           ),
    .i_reg_spi_rack             (rac_spi_rack           ),
    .i_reg_spi_data             (rac_spi_data           ),
    .i_reg_spi_addr             (rac_spi_addr           ),

    .o_spi_err                  (spi_reg_slv_err        ),

    .i_clk	                    (i_clk                  ),
    .i_rst_n                    (i_rst_n                )
);

lv_reg_access_ctrl U_LV_REG_ACCESS_CTRL(
    .i_wdg_scan_rac_rd_req      (wdg_scan_rac_rd_req    ),
    .i_wdg_scan_rac_addr        (wdg_scan_rac_addr      ),
    .o_rac_wdg_scan_ack         (rac_wdg_scan_ack       ),
    .o_rac_wdg_scan_data        (rac_wdg_scan_data      ),
    .o_rac_wdg_scan_crc         (rac_wdg_scan_crc       ),

    .i_spi_rac_wr_req           (spi_rac_wr_req         ),
    .i_spi_rac_rd_req           (spi_rac_rd_req         ),
    .i_spi_rac_addr             (spi_rac_addr           ),
    .i_spi_rac_wdata            (spi_rac_wdata          ),
    .i_spi_rac_wcrc             (spi_rac_wcrc           ),

    .o_rac_spi_wack             (rac_spi_wack           ),
    .o_rac_spi_rack             (rac_spi_rack           ),
    .o_rac_spi_data             (rac_spi_data           ),
    .o_rac_spi_addr             (rac_spi_addr           ),

    .o_spi_owt_wr_req           (spi_owt_wr_req         ),
    .o_spi_owt_rd_req           (spi_owt_rd_req         ),
    .o_spi_owt_addr             (spi_owt_addr           ),
    .o_spi_owt_data             (spi_owt_data           ),
    .i_owt_spi_wack             (owt_spi_wack           ),
    .i_owt_spi_rack             (owt_spi_rack           ),
    .o_spi_rst_wdg              (spi_rst_wdg            ),

    .o_rac_reg_ren              (rac_reg_ren            ),
    .o_rac_reg_wen              (rac_reg_wen            ),
    .o_rac_reg_addr             (rac_reg_addr           ),
    .o_rac_reg_wdata            (rac_reg_wdata          ),
    .o_rac_reg_wcrc             (rac_reg_wcrc           ),

    .i_reg_rac_wack             (reg_rac_wack           ),
    .i_reg_rac_rack             (reg_rac_rack           ),
    .i_reg_rac_rdata            (reg_rac_rdata          ),
    .i_reg_rac_rcrc             (reg_rac_rcrc           ),

    .i_clk                      (i_clk                  ),
    .i_rst_n                    (i_rst_n                )
);

lv_owt_tx_ctrl U_LV_OWT_TX_CTRL(
    .i_spi_owt_wr_req           (spi_owt_wr_req         ),
    .i_spi_owt_rd_req           (spi_owt_rd_req         ),
    .i_spi_owt_addr             (spi_owt_addr           ),
    .i_spi_owt_data             (spi_owt_data           ),
    .o_owt_spi_ack              (),
    
    input  logic                            i_wdg_owt_adc_req   ,
    output logic                            o_owt_wdg_adc_ack   ,

    output logic                            o_lv_hv_owt_tx      ,

    output logic [OWT_CMD_BIT_NUM-1:    0]  o_owt_tx_cmd_lock   ,
    
    input  logic                            i_clk	            ,
    input  logic                            i_rst_n
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule