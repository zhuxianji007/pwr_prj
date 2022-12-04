//============================================================
//Module   : lv_hv_shadow_reg
//Function : rd hv reg and store them in lv
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_hv_shadow_reg #(
    include "lv_param.vh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_owt_rx_ack   ,
    input  logic [OWT_CMD_BIT_NUM-1:    0]  i_owt_rx_cmd   ,
    input  logic [OWT_ADCD_BIT_NUM-1:   0]  i_owt_rx_data  ,
    input  logic                            i_owt_rx_status,//0: normal; 1: error. 

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
logic               reg_wen  ;
logic [REG_AW-1: 0] reg_addr ;
logic [ADC_DW-1: 0] reg_wdata;              
//==================================
//main code
//==================================
assign reg_wen   = i_owt_rx_ack & ~i_owt_rx_status & i_owt_rx_cmd[OWT_CMD_BIT_NUM-1]    ;
assign reg_addr  = i_owt_rx_cmd[OWT_CMD_BIT_NUM-2: 0]                                   ;
assign reg_wdata = i_owt_rx_data                                                        ;

rw_reg #(
    .DW                     (ADC_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h1F      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       )
)U_HV_ADC1_DATA(
    .i_ren                (1'b0                        ),
    .i_wen                (reg_wen                     ),
    .i_test_mode_status   (1'b0                        ),
    .i_cfg_mode_status    (1'b1                        ),
    .i_addr               (reg_addr                    ),
    .i_wdata              (reg_wdata[ADC_DW-1: 0]      ),
    .i_crc_data           ({REG_CRC_W{1'b0}}           ),
    .o_rdata              (                            ),
    .o_reg_data           (o_adc1_data                 ),
    .o_rcrc               (                            ),
    .i_clk                (i_clk                       ),
    .i_rst_n              (rst_n                       )
);

rw_reg #(
    .DW                     (ADC_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h1F      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       )
)U_HV_ADC2_DATA(
    .i_ren                (1'b0                                     ),
    .i_wen                (reg_wen                                  ),
    .i_test_mode_status   (1'b0                                     ),
    .i_cfg_mode_status    (1'b1                                     ),
    .i_addr               (reg_addr                                 ),
    .i_wdata              (reg_wdata[OWT_ADCD_BIT_NUM-1 -: ADC_DW]  ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                        ),
    .o_rdata              (                                         ),
    .o_reg_data           (o_adc2_data                              ),
    .o_rcrc               (                                         ),
    .i_clk                (i_clk                                    ),
    .i_rst_n              (rst_n                                    )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule