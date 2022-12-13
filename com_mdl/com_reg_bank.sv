//============================================================
//Module   : com_reg_bank
//Function : regsiter instance & access ctrl.
//File Tree: com_reg_bank
//            |--ro_reg
//            |--rw_reg
//            |--rwc_reg
//            |--wo_reg
//            |--rww_reg
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module com_reg_bank import com_pkg::*; 
#(
    `include "com_param.svh"
    parameter END_OF_LIST = 1
)(
    //spi reg access interface 
    input  logic                                        i_spi_reg_ren                   ,
    input  logic                                        i_spi_reg_wen                   ,
    input  logic [REG_AW-1:         0]                  i_spi_reg_addr                  ,
    input  logic [REG_DW-1:         0]                  i_spi_reg_wdata                 ,
    input  logic [REG_CRC_W-1:      0]                  i_spi_reg_wcrc                  ,
    
    output logic                                        o_reg_spi_wack                  ,
    output logic                                        o_reg_spi_rack                  ,
    output logic [REG_DW-1:         0]                  o_reg_spi_rdata                 ,
    output logic [REG_CRC_W-1:      0]                  o_reg_spi_rcrc                  ,
        
    //inner flop-flip data
    input  logic [REG_DW-1:         0]                  i_int_status1                   ,
    input  logic [REG_DW-1:         0]                  i_int_status2                   ,
    
    //output to inner logic
    output str_reg_mode                                 o_reg_mode                      ,
    output str_reg_com_config1                          o_reg_com_config1               ,
    output str_reg_com_config2                          o_reg_com_config2               ,
    output str_reg_status1                              o_reg_status1                   ,
    output str_reg_mask1                                o_reg_mask1                     ,
    output str_reg_status2                              o_reg_status2                   ,
    output str_reg_mask2                                o_reg_mask2                     ,
    
    input  logic                                        i_test_st_reg_en                ,
    input  logic                                        i_cfg_st_reg_en                 ,
    input  logic                                        i_spi_ctrl_reg_en               ,
    input  logic                                        i_efuse_ctrl_reg_en             ,
    input  logic                                        i_clk                           ,
    input  logic                                        i_hrst_n                        ,
    output logic                                        o_rst_n                     
);
//==================================
//local param delcaration
//==================================
logic                  srst_n                   ;
logic                  rst_n                    ;
    
logic                  spi_reg_wen              ;
logic                  spi_reg_ren              ;
logic [REG_AW-1:    0] spi_reg_addr             ;
logic [REG_DW-1:    0] spi_reg_wdata            ;
logic [REG_CRC_W-1: 0] spi_reg_wcrc             ;
logic [REG_DW-1:    0] reg_spi_rdata            ;
logic [REG_CRC_W-1: 0] reg_spi_rcrc             ;
        
logic [REG_DW-1:    0] rdata_lvhv_device_id     ;
logic [REG_DW-1:    0] rdata_mode               ;
logic [REG_CRC_W-1: 0] rcrc_mode                ;
logic [REG_DW-1:    0] rdata_com_config1        ;
logic [REG_CRC_W-1: 0] rcrc_com_config1         ;
logic [REG_DW-1:    0] rdata_com_config2        ;
logic [REG_CRC_W-1: 0] rcrc_com_config2         ;
logic [REG_DW-1:    0] rdata_status1            ;
logic [REG_DW-1:    0] rdata_mask1              ;
logic [REG_CRC_W-1: 0] rcrc_mask1               ;
logic [REG_DW-1:    0] rdata_status2            ;
logic [REG_DW-1:    0] rdata_mask2              ;
logic [REG_CRC_W-1: 0] rcrc_mask2               ;
    
logic [REG_DW-1:    0] reg_mode                 ;
logic [REG_DW-1:    0] reg_com_config1          ;
logic [REG_DW-1:    0] reg_com_config2          ;
logic [REG_DW-1:    0] reg_status1              ;
logic [REG_DW-1:    0] reg_mask1                ;
logic [REG_DW-1:    0] reg_status2              ;
logic [REG_DW-1:    0] reg_mask2                ;
//==================================
//var delcaration
//==================================
    
//==================================
//main code
//==================================
assign srst_n = reg_mode[0:0];
    
rstn_merge U_RSTN_MERGE(
    .i_hrst_n   (i_hrst_n),
    .i_srst_n   (srst_n  ),
    .o_rst_n    (rst_n   )
);
assign o_rst_n = rst_n;
    
//instance regsister
//LVHV_DEVICE_ID REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h00      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_LVHV_DEVICE_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({HV_DV_ID, LV_DV_ID}                         ),
    .o_rdata              (rdata_lvhv_device_id                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
//MODE REGISTER
rw_reg #(
    .DW                     (7          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (7          ),
    .DEFAULT_VAL            (7'h08      ),
    .REG_ADDR               (7'h01      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_MODE_H(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[7:1]                           ),
    .i_crc_data           (spi_reg_wcrc[7:1]                            ),
    .o_rdata              (rdata_mode[7:1]                              ),
    .o_reg_data           (reg_mode[7:1]                                ),
    .o_rcrc               (rcrc_mode[7:1]                               ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
rw_reg #(
    .DW                     (1          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (1          ),
    .DEFAULT_VAL            (1'h0       ),
    .REG_ADDR               (7'h01      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_MODE_L(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[0:0]                           ),
    .i_crc_data           (spi_reg_wcrc[0:0]                            ),
    .o_rdata              (rdata_mode[0:0]                              ),
    .o_reg_data           (reg_mode[0:0]                                ),
    .o_rcrc               (rcrc_mode[0:0]                               ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_mode = reg_mode;
    
//COM_CONFIG1 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h2B      ),
    .REG_ADDR               (7'h02      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_COM_CONFIG1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_com_config1                            ),
    .o_reg_data           (reg_com_config1                              ),
    .o_rcrc               (rcrc_com_config1                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_com_config1 = reg_com_config1;
    
//COM_CONFIG2 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hFF      ),
    .REG_ADDR               (7'h03      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_COM_CONFIG2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_com_config2                            ),
    .o_reg_data           (reg_com_config2                              ),
    .o_rcrc               (rcrc_com_config2                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_com_config2 = reg_com_config2;

//STATUS1 REGISTER
rwc_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h08      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_STATUS1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_status1                                ),
    .o_reg_data           (reg_status1                                  ),
    .i_lgc_wen            (i_int_status1                                ),
    .i_lgc_wdata          (8'hFF                                        ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_status1 = reg_status1;

//MASK1 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h09      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_MASK1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_mask1                                  ),
    .o_reg_data           (reg_mask1                                    ),
    .o_rcrc               (rcrc_mask1                                   ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_mask1 = reg_mask1;

//STATUS2 REGISTER
rwc_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h0A      ),
    .SUPPORT_TEST_MODE_WR   (1'b0       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b1       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_STATUS2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_status2                                ),
    .o_reg_data           (reg_status2                                  ),
    .i_lgc_wen            (i_int_status2                                ),
    .i_lgc_wdata          (8'hFF                                        ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_status2 = reg_status2;

//MASK2 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h0B      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_MASK2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_mask2                                  ),
    .o_reg_data           (reg_mask2                                    ),
    .o_rcrc               (rcrc_mask2                                   ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_mask2 = reg_mask2;

assign spi_reg_ren      = i_spi_reg_ren    ;
assign spi_reg_wen      = i_spi_reg_wen    ;
assign spi_reg_addr     = i_spi_reg_addr   ;
assign spi_reg_wdata    = i_spi_reg_wdata  ;
assign spi_reg_wcrc     = i_spi_reg_wcrc   ;

assign o_reg_spi_wack   = spi_reg_wen      ;
assign o_reg_spi_rack   = spi_reg_ren      ;
assign o_reg_spi_rdata  = reg_spi_rdata    ;
assign o_reg_spi_rcrc   = reg_spi_rcrc     ;

assign reg_spi_rdata = rdata_lvhv_device_id | rdata_mode | rdata_com_config1 | rdata_com_config2 | 
                       rdata_status1 | rdata_mask1 | rdata_status2 | rdata_mask2 ;

assign reg_spi_rcrc = rcrc_mode | rcrc_com_config1 | rcrc_com_config2 | rcrc_mask1 | rcrc_mask2;
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
