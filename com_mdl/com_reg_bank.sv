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
    input  logic                                        i_int_bist_fail                 ,
    input  logic                                        i_int_pwm_mmerr                 ,
    input  logic                                        i_int_pwm_dterr                 ,
    input  logic                                        i_int_wdg_err                   ,
    input  logic                                        i_int_com_err                   ,
    input  logic                                        i_int_crc_err                   ,
    input  logic                                        i_int_spi_err                   ,
    
    input logic                                         i_int_hv_scp_flt                ,
    input logic                                         i_int_hv_desat_flt              ,
    input logic                                         i_int_hv_oc                     ,
    input logic                                         i_int_hv_ot                     ,
    input logic                                         i_int_hv_vcc_ov                 ,
    input logic                                         i_int_hv_vcc_uv                 ,
    input logic                                         i_int_lv_vsup_ov                ,
    input logic                                         i_int_lv_vsup_uv                ,
    
    input logic                                         i_vrtmon                        ,
    input logic                                         i_io_fsifo                      ,
    input logic                                         i_io_pwma                       ,
    input logic                                         i_io_pwm                        ,
    input logic                                         i_io_fsstate                    ,
    input logic                                         i_io_fsenb                      ,
    input logic                                         i_io_intb_lv                    ,
    input logic                                         i_io_intb_hv                    ,
    
    input logic [REG_DW-1:         0]                   i_fsm_state                     ,   
    input logic [ADC_DW-1:         0]                   i_adc1_data                     ,
    input logic [ADC_DW-1:         0]                   i_adc2_data                     ,
    input logic [15:               0]                   i_bist_rult                     ,
    
    //output to inner logic
    output str_reg_mode                                 o_reg_mode                      ,
    output str_reg_com_config1                          o_reg_com_config1               ,
    output str_reg_com_config2                          o_reg_com_config2               ,
    output str_reg_status1                              o_reg_status1                   ,
    output str_reg_mask1                                o_reg_mask1                     ,
    output str_reg_status2                              o_reg_status2                   ,
    output str_reg_mask2                                o_reg_mask2                     ,
    output str_reg_efuse_config                         o_reg_die1_efuse_config         ,
    output str_reg_efuse_status                         o_reg_die1_efuse_status         ,
    output str_reg_efuse_config                         o_reg_die2_efuse_config         ,
    output str_reg_efuse_status                         o_reg_die2_efuse_status         ,
    
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
    
logic [REG_DW-1:    0] status1_lgc_wen          ;
logic [REG_DW-1:    0] status2_lgc_wen          ;
logic [REG_DW-1:    0] status3_in               ;
    
logic [REG_DW-1:    0] rdata_lvhv_device_id     ;
logic [REG_DW-1:    0] rdata_mode               ;
logic [REG_DW-1:    0] rdata_com_config1        ;
logic [REG_DW-1:    0] rdata_com_config2        ;
logic [REG_DW-1:    0] rdata_die1_efuse_config  ;
logic [REG_DW-1:    0] rdata_die1_efuse_status  ;
logic [REG_DW-1:    0] rdata_die2_efuse_config  ;
logic [REG_DW-1:    0] rdata_die2_efuse_status  ;
logic [REG_DW-1:    0] rdata_status1            ;
logic [REG_DW-1:    0] rdata_mask1              ;
logic [REG_DW-1:    0] rdata_status2            ;
logic [REG_DW-1:    0] rdata_mask2              ;
logic [REG_DW-1:    0] rdata_status3            ;
logic [REG_DW-1:    0] rdata_status4            ;
logic [REG_DW-1:    0] rdata_adc1_data_low      ;
logic [REG_DW-1:    0] rdata_adc1_data_hig      ;
logic [REG_DW-1:    0] rdata_adc2_data_low      ;
logic [REG_DW-1:    0] rdata_adc2_data_hig      ;
logic [REG_DW-1:    0] rdata_bist_rult1         ;
logic [REG_DW-1:    0] rdata_bist_rult2         ;
logic [REG_DW-1:    0] rdata_adc_status         ;
    
    
logic [REG_DW-1:    0] reg_mode                 ;
logic [REG_DW-1:    0] reg_com_config1          ;
logic [REG_DW-1:    0] reg_com_config2          ;
logic [REG_DW-1:    0] reg_die1_efuse_config    ;
logic [REG_DW-1:    0] reg_die1_efuse_status    ;
logic [REG_DW-1:    0] reg_die2_efuse_config    ;
logic [REG_DW-1:    0] reg_die2_efuse_status    ;
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
    .CRC_W                  (REG_CRC_W  ),
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
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mode[7:1]                              ),
    .o_reg_data           (reg_mode[7:1]                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
rw_reg #(
    .DW                     (1          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
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
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mode[0:0]                              ),
    .o_reg_data           (reg_mode[0:0]                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (hrst_n                                       )
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
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_com_config1                            ),
    .o_reg_data           (reg_com_config1                              ),
    .o_rcrc               (                                             ),
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
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_com_config2                            ),
    .o_reg_data           (reg_com_config2                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_com_config2 = reg_com_config2;

//DIE1_EFUSE_CONFIG REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h04      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DIE1_EFUSE_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die1_efuse_config                      ),
    .o_reg_data           (reg_die1_efuse_config                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_die1_efuse_config = reg_die1_efuse_config;

//DIE1_EFUSE_STATUS REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h05      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DIE1_EFUSE_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die1_efuse_status                      ),
    .o_reg_data           (reg_die1_efuse_status                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_die1_efuse_status = reg_die1_efuse_status;

//DIE2_EFUSE_CONFIG REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h06      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DIE2_EFUSE_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die2_efuse_config                      ),
    .o_reg_data           (reg_die2_efuse_config                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_die2_efuse_config = reg_die2_efuse_config;

//DIE2_EFUSE_STATUS REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h07      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DIE2_EFUSE_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die2_efuse_status                      ),
    .o_reg_data           (reg_die2_efuse_status                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_die2_efuse_status = reg_die2_efuse_status;

//STATUS1 REGISTER
assign status1_lgc_wen = {i_int_bist_fail, 1'b0, i_int_pwm_mmerr, i_int_pwm_dterr, 
                           i_int_wdg_err, i_int_com_err, i_int_crc_err, i_int_spi_err};
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
    .i_lgc_wen            (status1_lgc_wen                              ),
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
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_mask1 = reg_mask1;

//STATUS2 REGISTER
assign status2_lgc_wen = {i_int_hv_scp_flt, i_int_hv_desat_flt, i_int_hv_oc,      i_int_hv_ot,
                          i_int_hv_vcc_ov,  i_int_hv_vcc_uv,    i_int_lv_vsup_ov, i_int_lv_vsup_uv};

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
    .i_lgc_wen            (status2_lgc_wen                              ),
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
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_mask2 = reg_mask2;

//STATUS3 REGISTER
assign status3_in = {i_vrtmon, i_io_fsifo, i_io_pwma, i_io_pwm
                      i_io_fsstate, i_io_fsenb, i_io_intb_lv, i_io_intb_hv};
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h0C      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_STATUS3(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (status3_in                                   ),
    .o_rdata              (rdata_status3                                ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//STATUS4 REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h0D      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_STATUS4(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_fsm_state                                  ),
    .o_rdata              (rdata_status4                                ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC1_DATA_LOW REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h10      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC1_DATA_LOW(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_adc1_data[7:0]                             ),
    .o_rdata              (rdata_adc1_data_low                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC1_DATA_HIG REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h11      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC1_DATA_HIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({6'b0, i_adc1_data[9:8]}                     ),
    .o_rdata              (rdata_adc1_data_hig                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC2_DATA_LOW REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h12      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC2_DATA_LOW(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_adc2_data[7:0]                             ),
    .o_rdata              (rdata_adc2_data_low                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC2_DATA_HIG REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h13      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC2_DATA_HIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({6'b0, i_adc2_data[9:8]}                     ),
    .o_rdata              (rdata_adc2_data_hig                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//BIST_RESULT1 REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h14      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_BIST_RESULT1(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_bist_rult[7:0]                             ),
    .o_rdata              (rdata_bist_rult1                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);


//BIST_RESULT2 REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h15      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_BIST_RESULT2(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_bist_rult[15:8]                            ),
    .o_rdata              (rdata_bist_rult2                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ADC_REQ REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h1F      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       )
)U_ADC_REQ(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (8'h00                                        ),
    .o_rdata              (rdata_adc_status                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);


assign spi_reg_ren      = i_spi_reg_ren    ;
assign spi_reg_wen      = i_spi_reg_wen    ;
assign spi_reg_addr     = i_spi_reg_addr   ;
assign spi_reg_wdata    = i_spi_reg_wdata  ;
assign spi_reg_wcrc     = i_spi_reg_wcrc   ;

assign o_reg_spi_wack   = spi_reg_wen      ;
assign o_reg_spi_rack   = spi_reg_ren      ;


assign reg_spi_rdata = rdata_lvhv_device_id | rdata_mode | rdata_com_config1 | rdata_com_config2 | rdata_die1_efuse_config | rdata_die1_efuse_status |
                       rdata_die2_efuse_config | rdata_die2_efuse_status |
                       rdata_status1 | rdata_mask1 | rdata_status2 | rdata_mask2 |
                       rdata_status3 | rdata_status4 | rdata_adc1_data_low | rdata_adc1_data_hig | rdata_adc2_data_low | rdata_adc2_data_hig |
                       rdata_bist_rult1 | rdata_bist_rult2 | rdata_adc_status;

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
