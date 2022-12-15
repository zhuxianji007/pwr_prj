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
module lv_hv_shadow_reg import com_pkg::*; 
#(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_owt_rx_ack            ,
    input  logic [OWT_CMD_BIT_NUM-1:    0]  i_owt_rx_cmd            ,
    input  logic [OWT_ADCD_BIT_NUM-1:   0]  i_owt_rx_data           ,
    input  logic                            i_owt_rx_status         ,//0: normal; 1: error. 

    output str_reg_efuse_config             o_reg_die2_efuse_config ,
    output str_reg_efuse_status             o_reg_die2_efuse_status ,
    output logic [REG_DW-1:             0]  o_reg_status1           ,
    output logic [REG_DW-1:             0]  o_reg_status2           ,
    output logic [REG_DW-1:             0]  o_reg_status3           ,
    output logic [REG_DW-1:             0]  o_reg_status4           ,
    output logic [ADC_DW-1:             0]  o_reg_adc1_data         ,
    output logic [ADC_DW-1:             0]  o_reg_adc2_data         ,
    output logic [REG_DW-1:             0]  o_reg_bist1             ,
    output logic [REG_DW-1:             0]  o_reg_bist2             ,

    output logic                            o_hv_reg_vld            ,
    output logic [REG_DW-1:             0]  o_hv_ang_reg_data       ,

    input  logic                            i_clk                   ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                  reg_wen          ;
logic [REG_AW-1:    0] reg_addr         ;
logic [2*ADC_DW-1:  0] reg_wdata        ;             
//==================================
//main code
//==================================
assign reg_wen          = i_owt_rx_ack & ~i_owt_rx_status & i_owt_rx_cmd[OWT_CMD_BIT_NUM-1]         ;
assign reg_addr         = i_owt_rx_cmd[OWT_CMD_BIT_NUM-2: 0]                                        ;
assign reg_wdata        = i_owt_rx_data                                                             ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_reg_vld <= 1'b0;
    end
    else begin
        o_hv_reg_vld <= i_owt_rx_ack;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_ang_reg_data <= REG_DW'(0);
    end
    else begin
        o_hv_ang_reg_data <= i_owt_rx_data;
    end
end

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h06      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_EFUSE_CONFIG(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_die2_efuse_config                      ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h07      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_EFUSE_STATUS(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_die2_efuse_status                      ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h08      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_STATUS1(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_status1                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h0A      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_STATUS2(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_status2                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h0C      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_STATUS3(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_status3                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h0D      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_STATUS4(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_status4                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h14      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_BIST1(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_bist1                                  ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h15      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_BIST2(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[REG_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_bist2                                  ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (ADC_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h1F      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_ADC1_DATA(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[ADC_DW-1: 0]                       ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_adc1_data                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);

rw_reg #(
    .DW                     (ADC_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (10'h00     ),
    .REG_ADDR               (7'h1F      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b0       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_HV_ADC2_DATA(
    .i_ren                (1'b0                                         ),
    .i_wen                (reg_wen                                      ),
    .i_test_st_reg_en     (1'b0                                         ),
    .i_cfg_st_reg_en      (1'b0                                         ),
    .i_spi_ctrl_reg_en    (1'b1                                         ),
    .i_efuse_ctrl_reg_en  (1'b0                                         ),
    .i_addr               (reg_addr                                     ),
    .i_wdata              (reg_wdata[OWT_ADCD_BIT_NUM-1 -: ADC_DW]      ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (                                             ),
    .o_reg_data           (o_reg_adc2_data                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule




















