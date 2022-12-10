//============================================================
//Module   : lv_reg_slv
//Function : regsiter instance & access ctrl.
//File Tree: lv_reg_slv
//            |--ro_reg
//            |--rw_reg
//            |--rwc_reg
//            |--wo_reg
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_reg_slv import lv_pkg::*; 
#(
    `include "lv_param.svh"
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
    input logic [REG_DW-1:         0]                   i_adc_status                    ,

    input logic                                         i_efuse_reg_update              ,
    input logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]    i_efuse_reg_data                ,

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

    output str_reg_iso_bgr_trim                         o_reg_iso_bgr_trim              ,
    output str_reg_iso_con_ibias_trim                   o_reg_iso_con_ibias_trim        ,
    output str_reg_iso_osc48m_trim                      o_reg_iso_osc48m_trim           ,
    output str_reg_iso_oscb_freq_adj                    o_reg_iso_oscb_freq_adj         ,
    output str_reg_iso_reserved_reg                     o_reg_iso_reserved_reg          ,
    output str_reg_iso_amp_ibias                        o_reg_iso_amp_ibias             ,
    output str_reg_iso_demo_trim                        o_reg_iso_demo_trim             ,
    output str_reg_iso_test_sw                          o_reg_iso_test_sw               ,
    output str_reg_iso_osc_jit                          o_reg_iso_osc_jit               ,
    output str_reg_config0_t_deat_time                  o_reg_config0_t_deat_time       ,
    
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
logic                  rst_n                    ;

logic                  spi_reg_wen              ;
logic                  spi_reg_ren              ;
logic [REG_AW-1:    0] spi_reg_addr             ;
logic [REG_DW-1:    0] spi_reg_wdata            ;
logic [REG_CRC_W-1: 0] spi_reg_wcrc             ;
logic [REG_DW-1:    0] reg_spi_rdata            ;
logic [REG_CRC_W-1: 0] reg_spi_rcrc             ;

logic                  com_reg_wack             ;
logic                  com_reg_rack             ;
logic [REG_DW-1:    0] com_reg_rdata            ;
logic [REG_CRC_W-1: 0] com_reg_rcrc             ;

logic [REG_DW-1:    0] rdata_die1_id            ;
logic [REG_DW-1:    0] rdata_die2_id            ;
logic [REG_DW-1:    0] rdata_die3_id            ;
logic [REG_DW-1:    0] rdata_iso_bgr_trim       ;
logic [REG_DW-1:    0] rdata_iso_con_ibias_trim ;
logic [REG_DW-1:    0] rdata_iso_osc48m_trim    ;
logic [REG_DW-1:    0] rdata_iso_oscb_freq_adj  ;
logic [REG_DW-1:    0] rdata_iso_reserved_reg   ;
logic [REG_DW-1:    0] rdata_iso_amp_ibias      ;
logic [REG_DW-1:    0] rdata_iso_demo_trim      ;
logic [REG_DW-1:    0] rdata_iso_test_sw        ;
logic [REG_DW-1:    0] rdata_iso_osc_jit        ;
logic [REG_DW-1:    0] rdata_ana_reserved_reg   ;
logic [REG_DW-1:    0] rdata_config0_t_deat_time;

logic [REG_DW-1:    0] reg_die1_id              ;
logic [REG_DW-1:    0] reg_die2_id              ;
logic [REG_DW-1:    0] reg_die3_id              ;
logic [REG_DW-1:    0] reg_iso_bgr_trim         ;
logic [REG_DW-1:    0] reg_iso_con_ibias_trim   ;
logic [REG_DW-1:    0] reg_iso_osc48m_trim      ;
logic [REG_DW-1:    0] reg_iso_oscb_freq_adj    ;
logic [REG_DW-1:    0] reg_iso_reserved_reg     ;
logic [REG_DW-1:    0] reg_iso_amp_ibias        ;
logic [REG_DW-1:    0] reg_iso_demo_trim        ;
logic [REG_DW-1:    0] reg_iso_test_sw          ;
logic [REG_DW-1:    0] reg_iso_osc_jit          ;
logic [REG_DW-1:    0] reg_ana_reserved_reg     ;
logic [REG_DW-1:    0] reg_config0_t_deat_time  ;
//==================================
//var delcaration
//==================================

//==================================
//main code
//==================================
com_reg_bank U_LV_COM_REG_BANK(
    .i_spi_reg_ren                 (spi_reg_ren             ),
    .i_spi_reg_wen                 (spi_reg_wen             ),
    .i_spi_reg_addr                (spi_reg_addr            ),
    .i_spi_reg_wdata               (spi_reg_wdata           ),

    .o_reg_spi_wack                (com_reg_wack            ),
    .o_reg_spi_rack                (com_reg_rack            ),
    .o_reg_spi_rdata               (com_reg_rdata           ),
    .o_reg_spi_rcrc                (com_reg_rcrc            ),
        
    .i_int_bist_fail               (i_int_bist_fail         ),
    .i_int_pwm_mmerr               (i_int_pwm_mmerr         ),
    .i_int_pwm_dterr               (i_int_pwm_dterr         ),
    .i_int_wdg_err                 (i_int_wdg_err           ),
    .i_int_com_err                 (i_int_com_err           ),
    .i_int_crc_err                 (i_int_crc_err           ),
    .i_int_spi_err                 (i_int_spi_err           ),

    .i_int_hv_scp_flt              (i_int_hv_scp_flt        ),
    .i_int_hv_desat_flt            (i_int_hv_desat_flt      ),
    .i_int_hv_oc                   (i_int_hv_oc             ),
    .i_int_hv_ot                   (i_int_hv_ot             ),
    .i_int_hv_vcc_ov               (i_int_hv_vcc_ov         ),
    .i_int_hv_vcc_uv               (i_int_hv_vcc_uv         ),
    .i_int_lv_vsup_ov              (i_int_lv_vsup_ov        ),
    .i_int_lv_vsup_uv              (i_int_lv_vsup_uv        ),

    .i_vrtmon                      (i_vrtmon                ),
    .i_io_fsifo                    (i_io_fsifo              ),
    .i_io_pwma                     (i_io_pwma               ),
    .i_io_pwm                      (i_io_pwm                ),
    .i_io_fsstate                  (i_io_fsstate            ),
    .i_io_fsenb                    (i_io_fsenb              ),
    .i_io_intb_lv                  (i_io_intb_lv            ),
    .i_io_intb_hv                  (i_io_intb_hv            ),

    .i_fsm_state                   (i_fsm_state             ),   
    .i_adc1_data                   (i_adc1_data             ),
    .i_adc2_data                   (i_adc2_data             ),
    .i_bist_rult                   (i_bist_rult             ),

    .o_reg_mode                    (o_reg_mode              ),
    .o_reg_com_config1             (o_reg_com_config1       ),
    .o_reg_com_config2             (o_reg_com_config2       ),
    .o_reg_status1                 (o_reg_status1           ),
    .o_reg_mask1                   (o_reg_mask1             ),
    .o_reg_status2                 (o_reg_status2           ),
    .o_reg_mask2                   (o_reg_mask2             ),
    .o_reg_die1_efuse_config       (o_reg_die1_efuse_config ),
    .o_reg_die1_efuse_status       (o_reg_die1_efuse_status ),
    .o_reg_die2_efuse_config       (o_reg_die2_efuse_config ),
    .o_reg_die2_efuse_status       (o_reg_die2_efuse_status ),

    .i_test_st_reg_en              (i_test_st_reg_en        ),
    .i_cfg_st_reg_en               (i_cfg_st_reg_en         ),
    .i_spi_ctrl_reg_en             (i_spi_ctrl_reg_en       ),
    .i_efuse_ctrl_reg_en           (i_efuse_ctrl_reg_en     ),
    .i_clk                         (i_clk                   ),
    .i_hrst_n                      (i_hrst_n                ),
    .o_rst_n                       (rst_n                   )
);

//DIE1_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h20      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE1_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_die1_id                                ),
    .o_reg_data           (reg_die1_id                                  ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[0]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE2_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h21      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE2_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_die2_id                                ),
    .o_reg_data           (reg_die2_id                                  ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[1]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE3_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h22      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE3_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_die3_id                                ),
    .o_reg_data           (reg_die3_id                                  ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[2]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//ISO_BGR_TRIM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h23      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_BGR_TRIM(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_iso_bgr_trim                           ),
    .o_reg_data           (reg_iso_bgr_trim                             ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[3]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_bgr_trim = reg_bgr_trim;

//ISO_CON_IBIAS_TRM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (7'h24      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_CON_IBIAS_TRM(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_iso_con_ibias_trim                     ),
    .o_reg_data           (reg_iso_con_ibias_trim                       ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[4]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_con_ibias_trim = reg_iso_con_ibias_trim;

//ISO_OSC48M_TRIM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (7'h25      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_OSC48M_TRIM(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_iso_osc48m_trim                        ),
    .o_reg_data           (reg_iso_osc48m_trim                          ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[5]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_osc48m_trim = reg_iso_osc48m_trim;

//ISO_OSCB_FREQ_ADJ REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hDF      ),
    .REG_ADDR               (7'h26      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_OSCB_FREQ_ADJ(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_iso_freq_adj                           ),
    .o_reg_data           (reg_iso_freq_adj                             ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[6]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_freq_adj = reg_iso_freq_adj;

//ISO_RESERVED_REG REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h27      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_OSCB_FREQ_ADJ(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_iso_reserved_reg                       ),
    .o_reg_data           (reg_iso_reserved_reg                         ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[7]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_reserved_reg = reg_iso_reserved_reg;

//ISO_AMP_IBIAS REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h24      ),
    .REG_ADDR               (7'h28      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_AMP_IBIAS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_amp_ibias                          ),
    .o_reg_data           (reg_iso_amp_ibias                            ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_iso_amp_ibias_amp_ibias8u      = reg_iso_amp_ibias[5:3];
assign o_iso_amp_ibias_amp_ibias8u_ptat = reg_iso_amp_ibias[2:0];

//ISO_RX_DEMO REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h05      ),
    .REG_ADDR               (7'h29      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_RX_DEMO(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_rx_demo                            ),
    .o_reg_data           (reg_iso_rx_demo                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_reg_iso_rx_demo_demo_pulse = reg_iso_rx_demo[4:3];
assign o_reg_iso_rx_demo_demo_vth   = reg_iso_rx_demo[2:0];

//ISO_TEST_SW REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h2A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_TEST_SW(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_test_sw                            ),
    .o_reg_data           (reg_iso_test_sw                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_iso_test_sw_reserved = reg_iso_test_sw;

//ISO_OSC_JIT REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h2B      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_OSC_JIT(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_osc_jit                            ),
    .o_reg_data           (reg_iso_osc_jit                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_iso_osc_jit_iso_tx_jit_adj = reg_iso_osc_jit[3:0];

//ANA_RESERVED_REG REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h2C      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ANA_RESERVED_REG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_ana_reserved_reg                       ),
    .o_reg_data           (reg_ana_reserved_reg                         ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_ana_reserved_reg_reserved = reg_ana_reserved_reg;

//T_DEAT_TIME REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h50      ),
    .REG_ADDR               (7'h30      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_T_DEAT_TIME(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_t_dead_time                            ),
    .o_reg_data           (reg_t_dead_time                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_t_dead_time_tdt_tdt = reg_t_dead_time[7:4];

assign spi_reg_ren   = i_spi_reg_ren    ;
assign spi_reg_wen   = i_spi_reg_wen    ;
assign spi_reg_addr  = i_spi_reg_addr   ;
assign spi_reg_wdata = i_spi_reg_wdata  ;
assign spi_reg_wcrc  = i_spi_reg_wcrc   ;

assign o_reg_spi_wack= spi_reg_wen      ;

//rdata proc zone
always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rack <= 1'b0;
    end
    else begin
        o_reg_spi_rack <= spi_reg_ren;
    end
end

assign reg_spi_rdata = rdata_lvhv_device_id | rdata_mode | rdata_com_config1 | rdata_com_config2 | rdata_status1 | rdata_mask1 | rdata_status2 | rdata_mask2
                       rdata_status3 | rdata_status4 | rdata_adc1_data_low | rdata_adc1_data_hig | rdata_adc2_data_low | rdata_adc2_data_hig |
                       rdata_bist_rult1 | rdata_bist_rult2 | rdata_adc_status | rdata_die1_id | rdata_die2_id | rdata_die3_id | rdata_iso_bgr_trim | rdata_iso_con_ibias_trim |
                       rdata_iso_osc48m_trim | rdata_iso_oscb_freq_adj | rdata_iso_reserved_reg | rdata_iso_amp_ibias | rdata_iso_demo_trim | rdata_iso_test_sw | rdata_iso_osc_jit |
                       rdata_ana_reserved_reg | rdata_config0_t_deat_time;

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rdata <= {REG_DW{1'b0}};
    end
    else begin
        o_reg_spi_rdata <= spi_reg_ren ? reg_spi_rdata : o_reg_spi_rdata;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule






















































































