//============================================================
//Module   : hv_reg_slv
//Function : regsiter instance & access ctrl.
//File Tree: hv_reg_slv
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
module hv_reg_slv import com_pkg::*; import hv_pkg::*; 
#(
    `include "hv_param.svh"
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
    input logic [REG_DW-1:         0]                   i_hv_status1                    ,
    input logic [REG_DW-1:         0]                   i_hv_status2                    ,
    input logic [REG_DW-1:         0]                   i_hv_status3                    ,
    input logic [REG_DW-1:         0]                   i_hv_status4                    ,
    input logic [REG_DW-1:         0]                   i_hv_bist1                      ,
    input logic [REG_DW-1:         0]                   i_hv_bist2                      ,

    input logic [5:                0]                   i_cnt_del_read                  ,

    input logic                                         i_efuse_op_finish               ,
    input logic                                         i_efuse_reg_update              ,
    input logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]    i_efuse_reg_data                ,

    //output to inner logic
    output str_reg_mode                                 o_reg_mode                      ,
    output str_reg_com_config1                          o_reg_com_config1               ,
    output str_reg_com_config2                          o_reg_com_config2               ,
    output str_reg_status1                              o_reg_status1                   ,
    output str_reg_status2                              o_reg_status2                   ,
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
    output logic [REG_DW-1:      0]                     o_reg_ana_reserved_reg          ,
    output logic [REG_DW-1:      0]                     o_reg_ana_reserved_reg2         ,
    output str_reg_config1_dr_src_snk_both              o_reg_config1_dr_src_snk_both   ,
    output str_reg_config2_dr_src_sel                   o_reg_config2_dr_src_sel        ,
    output str_reg_config3_dri_snk_sel                  o_reg_config3_dri_snk_sel       ,
    output str_reg_config4_tltoff_sel1                  o_reg_config4_tltoff_sel1       ,
    output str_reg_config5_tltoff_sel2                  o_reg_config5_tltoff_sel2       ,
    output str_reg_config6_desat_sel1                   o_reg_config6_desat_sel1        ,
    output str_reg_config7_desat_sel2                   o_reg_config7_desat_sel2        ,
    output str_reg_config8_oc_sel                       o_reg_config8_oc_sel            ,
    output str_reg_config9_sc_sel                       o_reg_config9_sc_sel            ,
    output str_reg_config10_dvdt_ref_src                o_reg_config10_dvdt_ref_src     ,
    output str_reg_config11_dvdt_ref_sink               o_reg_config11_dvdt_ref_sink    ,
    output str_reg_config12_adc_en                      o_reg_config12_adc_en           ,
    output str_reg_bgr_code_drv                         o_reg_bgr_code_drv              ,
    output str_reg_cap_trim_code                        o_reg_cap_trim_code             ,     
    output str_reg_csdel_cmp                            o_reg_csdel_cmp                 , 
    output str_reg_dvdt_value_adj                       o_reg_dvdt_value_adj            , 
    output str_reg_adc_adj1                             o_reg_adc_adj1                  , 
    output str_reg_adc_adj2                             o_reg_adc_adj2                  , 
    output str_reg_ibias_code_drv                       o_reg_ibias_code_drv            ,
    output str_reg_dvdt_tm                              o_reg_dvdt_tm                   , 
    output str_reg_dvdt_win_value_en                    o_reg_dvdt_win_value_en         , 
    output str_reg_preset_delay                         o_reg_preset_delay              , 
    output str_reg_drive_delay_set                      o_reg_drive_delay_set           ,
    output str_reg_cmp_del                              o_reg_cmp_del                   ,
    output str_reg_test_mux                             o_reg_test_mux                  , 
    output str_reg_cmp_adj_vreg                         o_reg_cmp_adj_vreg              ,            
    
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
logic                  rst_n                            ;

logic                  spi_reg_wen                      ;
logic                  spi_reg_ren                      ;
logic [REG_AW-1:    0] spi_reg_addr                     ;
logic [REG_DW-1:    0] spi_reg_wdata                    ;
logic [REG_CRC_W-1: 0] spi_reg_wcrc                     ;
logic [REG_DW-1:    0] reg_spi_rdata                    ;
logic [REG_CRC_W-1: 0] reg_spi_rcrc                     ;

logic [REG_DW-1:    0] reg_status1                      ;
logic [REG_DW-1:    0] reg_mask1                        ;
logic [REG_DW-1:    0] reg_status2                      ;
logic [REG_DW-1:    0] reg_mask2                        ;

logic                  com_reg_wack                     ;
logic                  com_reg_rack                     ;
logic [REG_DW-1:    0] com_reg_rdata                    ;
logic [REG_CRC_W-1: 0] com_reg_rcrc                     ;

logic [REG_DW-1:    0] rdata_die2_efuse_config          ;
logic [REG_DW-1:    0] rdata_die2_efuse_status          ;
logic [REG_DW-1:    0] rdata_status3                    ;
logic [REG_DW-1:    0] rdata_status4                    ;
logic [REG_DW-1:    0] rdata_bist_rult1                 ;
logic [REG_DW-1:    0] rdata_bist_rult2                 ;
logic [REG_DW-1:    0] rdata_die1_id                    ;
logic [REG_DW-1:    0] rdata_die2_id                    ;
logic [REG_DW-1:    0] rdata_die3_id                    ;
logic [REG_DW-1:    0] rdata_iso_bgr_trim               ;
logic [REG_DW-1:    0] rdata_iso_con_ibias_trim         ;
logic [REG_DW-1:    0] rdata_iso_osc48m_trim            ;
logic [REG_DW-1:    0] rdata_iso_oscb_freq_adj          ;
logic [REG_DW-1:    0] rdata_iso_reserved_reg           ;
logic [REG_DW-1:    0] rdata_iso_amp_ibias              ;
logic [REG_DW-1:    0] rdata_iso_demo_trim              ;
logic [REG_DW-1:    0] rdata_iso_test_sw                ;
logic [REG_DW-1:    0] rdata_iso_osc_jit                ;
logic [REG_DW-1:    0] rdata_ana_reserved_reg           ;
logic [REG_DW-1:    0] rdata_ana_reserved_reg2          ;
logic [REG_DW-1:    0] rdata_config1_dr_src_snk_both    ;
logic [REG_CRC_W-1: 0] rcrc_config1_dr_src_snk_both     ;
logic [REG_DW-1:    0] rdata_config2_dr_src_sel         ;
logic [REG_CRC_W-1: 0] rcrc_config2_dr_src_sel          ;
logic [REG_DW-1:    0] rdata_config3_dri_snk_sel        ;
logic [REG_CRC_W-1: 0] rcrc_config3_dri_snk_sel         ;
logic [REG_DW-1:    0] rdata_config4_tltoff_sel1        ;
logic [REG_CRC_W-1: 0] rcrc_config4_tltoff_sel1         ;
logic [REG_DW-1:    0] rdata_config5_tltoff_sel2        ;
logic [REG_CRC_W-1: 0] rcrc_config5_tltoff_sel2         ;
logic [REG_DW-1:    0] rdata_config6_desat_sel1         ;
logic [REG_CRC_W-1: 0] rcrc_config6_desat_sel1          ;
logic [REG_DW-1:    0] rdata_config7_desat_sel2         ;
logic [REG_CRC_W-1: 0] rcrc_config7_desat_sel2          ;
logic [REG_DW-1:    0] rdata_config8_oc_sel             ;
logic [REG_CRC_W-1: 0] rcrc_config8_oc_sel              ;
logic [REG_DW-1:    0] rdata_config9_sc_sel             ;
logic [REG_CRC_W-1: 0] rcrc_config9_sc_sel              ;
logic [REG_DW-1:    0] rdata_config10_dvdt_ref_src      ;
logic [REG_CRC_W-1: 0] rcrc_config10_dvdt_ref_src       ;
logic [REG_DW-1:    0] rdata_config11_dvdt_ref_sink     ;
logic [REG_CRC_W-1: 0] rcrc_config11_dvdt_ref_sink      ;
logic [REG_DW-1:    0] rdata_config12_adc_en            ;
logic [REG_CRC_W-1: 0] rcrc_config12_adc_en             ;
logic [REG_DW-1:    0] rdata_bgr_code_drv               ;
logic [REG_DW-1:    0] rdata_cap_trim_code              ;
logic [REG_DW-1:    0] rdata_csdel_cmp                  ;
logic [REG_DW-1:    0] rdata_dvdt_value_adj             ;
logic [REG_DW-1:    0] rdata_adc_adj1                   ;
logic [REG_DW-1:    0] rdata_adc_adj2                   ;
logic [REG_DW-1:    0] rdata_ibias_code_drv             ;
logic [REG_DW-1:    0] rdata_dvdt_tm                    ;
logic [REG_DW-1:    0] rdata_cnt_del_read               ;
logic [REG_DW-1:    0] rdata_dvdt_win_value_en          ;
logic [REG_DW-1:    0] rdata_preset_delay               ;
logic [REG_DW-1:    0] rdata_drive_delay_set            ;
logic [REG_DW-1:    0] rdata_cmp_del                    ;
logic [REG_DW-1:    0] rdata_test_mux                   ;
logic [REG_DW-1:    0] rdata_cmp_adj_vreg               ;

logic [REG_DW-1:    0] reg_die2_efuse_config            ;
logic [REG_DW-1:    0] reg_die2_efuse_status            ;
logic [REG_DW-1:    0] reg_die1_id                      ;
logic [REG_DW-1:    0] reg_die2_id                      ;
logic [REG_DW-1:    0] reg_die3_id                      ;
logic [REG_DW-1:    0] reg_iso_bgr_trim                 ;
logic [REG_DW-1:    0] reg_iso_con_ibias_trim           ;
logic [REG_DW-1:    0] reg_iso_osc48m_trim              ;
logic [REG_DW-1:    0] reg_iso_oscb_freq_adj            ;
logic [REG_DW-1:    0] reg_iso_reserved_reg             ;
logic [REG_DW-1:    0] reg_iso_amp_ibias                ;
logic [REG_DW-1:    0] reg_iso_demo_trim                ;
logic [REG_DW-1:    0] reg_iso_test_sw                  ;
logic [REG_DW-1:    0] reg_iso_osc_jit                  ;
logic [REG_DW-1:    0] reg_ana_reserved_reg             ;
logic [REG_DW-1:    0] reg_ana_reserved_reg2            ;
logic [REG_DW-1:    0] reg_config1_dr_src_snk_both      ;
logic [REG_DW-1:    0] reg_config2_dr_src_sel           ;
logic [REG_DW-1:    0] reg_config3_dri_snk_sel          ;
logic [REG_DW-1:    0] reg_config4_tltoff_sel1          ;
logic [REG_DW-1:    0] reg_config5_tltoff_sel2          ;
logic [REG_DW-1:    0] reg_config6_desat_sel1           ;
logic [REG_DW-1:    0] reg_config7_desat_sel2           ;
logic [REG_DW-1:    0] reg_config8_oc_sel               ;
logic [REG_DW-1:    0] reg_config9_sc_sel               ;
logic [REG_DW-1:    0] reg_config10_dvdt_ref_src        ;
logic [REG_DW-1:    0] reg_config11_dvdt_ref_sink       ;
logic [REG_DW-1:    0] reg_config12_adc_en              ;
logic [REG_DW-1:    0] reg_bgr_code_drv                 ;
logic [REG_DW-1:    0] reg_cap_trim_code                ;
logic [REG_DW-1:    0] reg_csdel_cmp                    ;
logic [REG_DW-1:    0] reg_dvdt_value_adj               ;
logic [REG_DW-1:    0] reg_adc_adj1                     ;
logic [REG_DW-1:    0] reg_adc_adj2                     ;
logic [REG_DW-1:    0] reg_ibias_code_drv               ;
logic [REG_DW-1:    0] reg_dvdt_tm                      ;
logic [REG_DW-1:    0] reg_dvdt_win_value_en            ;
logic [REG_DW-1:    0] reg_preset_delay                 ;
logic [REG_DW-1:    0] reg_drive_delay_set              ;
logic [REG_DW-1:    0] reg_cmp_del                      ;
logic [REG_DW-1:    0] reg_test_mux                     ;
logic [REG_DW-1:    0] reg_cmp_adj_vreg                 ;

//==================================
//var delcaration
//==================================

//==================================
//main code
//==================================
assign o_reg_status1 = reg_status1 & ~reg_mask1 ;
assign o_reg_status2 = reg_status2 & ~reg_mask2 ;

com_reg_bank U_LV_COM_REG_BANK(
    .i_spi_reg_ren                 (spi_reg_ren             ),
    .i_spi_reg_wen                 (spi_reg_wen             ),
    .i_spi_reg_addr                (spi_reg_addr            ),
    .i_spi_reg_wdata               (spi_reg_wdata           ),
    .i_spi_reg_wcrc                (spi_reg_wcrc            ),

    .o_reg_spi_wack                (com_reg_wack            ),
    .o_reg_spi_rack                (com_reg_rack            ),
    .o_reg_spi_rdata               (com_reg_rdata           ),
    .o_reg_spi_rcrc                (com_reg_rcrc            ),
        
    .i_int_status1                 (i_hv_status1            ),
    .i_int_status2                 (i_hv_status2            ),

    .o_reg_mode                    (o_reg_mode              ),
    .o_reg_com_config1             (o_reg_com_config1       ),
    .o_reg_com_config2             (o_reg_com_config2       ),
    .o_reg_status1                 (reg_status1             ),
    .o_reg_mask1                   (reg_mask1               ),
    .o_reg_status2                 (reg_status2             ),
    .o_reg_mask2                   (reg_mask2               ),

    .i_test_st_reg_en              (i_test_st_reg_en        ),
    .i_cfg_st_reg_en               (i_cfg_st_reg_en         ),
    .i_spi_ctrl_reg_en             (i_spi_ctrl_reg_en       ),
    .i_efuse_ctrl_reg_en           (i_efuse_ctrl_reg_en     ),
    .i_clk                         (i_clk                   ),
    .i_hrst_n                      (i_hrst_n                ),
    .o_rst_n                       (rst_n                   )
);

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
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h07      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DIE2_EFUSE_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_die2_efuse_status                      ),
    .o_reg_data           (reg_die2_efuse_status                        ),
    .i_lgc_wen            (i_efuse_op_finish                            ),
    .i_lgc_wdata          ({reg_die2_efuse_status[7:1], 1'b1}           ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
    
assign o_reg_die2_efuse_status = reg_die2_efuse_status;

//STATUS3 REGISTER
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
    .i_ff_data            (i_hv_status3                                 ),
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
    .i_ff_data            (i_hv_status4                                 ),
    .o_rdata              (rdata_status4                                ),
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
    .i_ff_data            (i_hv_bist1                                   ),
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
    .i_ff_data            (i_hv_bist2                                   ),
    .o_rdata              (rdata_bist_rult2                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DIE1_ID REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h40      ),
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
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h41      ),
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
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h42      ),
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
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h43      ),
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

assign o_reg_iso_bgr_trim = reg_iso_bgr_trim;

//ISO_CON_IBIAS_TRM REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (7'h44      ),
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
    .DEFAULT_VAL            (8'h20      ),
    .REG_ADDR               (7'h45      ),
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
    .DEFAULT_VAL            (8'hDF      ),
    .REG_ADDR               (7'h46      ),
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
    .o_rdata              (rdata_iso_oscb_freq_adj                      ),
    .o_reg_data           (reg_iso_oscb_freq_adj                        ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[6]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_oscb_freq_adj = reg_iso_oscb_freq_adj;

//ISO_RESERVED_REG REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h47      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ISO_RESERVED_REG(
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
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h24      ),
    .REG_ADDR               (7'h48      ),
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

assign o_reg_iso_amp_ibias = reg_iso_amp_ibias;

//ISO_DEMO_TRIM REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h05      ),
    .REG_ADDR               (7'h49      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_ISO_DEMO_TRIM(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_demo_trim                          ),
    .o_reg_data           (reg_iso_demo_trim                            ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_iso_demo_trim = reg_iso_demo_trim;

//ISO_TEST_SW REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h4A      ),
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

assign o_reg_iso_test_sw = reg_iso_test_sw;

//ISO_OSC_JIT REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h4B      ),
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

assign o_reg_iso_osc_jit = reg_iso_osc_jit;

//ANA_RESERVED_REG REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h4C      ),
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

assign o_reg_ana_reserved_reg = reg_ana_reserved_reg;

//ANA_RESERVED_REG2 REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h4D      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ANA_RESERVED2_REG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_ana_reserved_reg2                      ),
    .o_reg_data           (reg_ana_reserved_reg2                        ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[8]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_ana_reserved_reg2 = reg_ana_reserved_reg2;

//CONFIG1_DR_SRC_SNK_BOTH REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hEC      ),
    .REG_ADDR               (7'h50      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG1_DR_SRC_SNK_BOTH(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config1_dr_src_snk_both                ),
    .o_reg_data           (reg_config1_dr_src_snk_both                  ),
    .o_rcrc               (rcrc_config1_dr_src_snk_both                 ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config1_dr_src_snk_both = reg_config1_dr_src_snk_both;

//CONFIG2_DR_SRC_SEL REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h23      ),
    .REG_ADDR               (7'h51      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG2_DR_SRC_SEL(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config2_dr_src_sel                     ),
    .o_reg_data           (reg_config2_dr_src_sel                       ),
    .o_rcrc               (rcrc_config2_dr_src_sel                      ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config2_dr_src_sel = reg_config2_dr_src_sel;

//CONFIG3_DRI_SNK_SEL REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h22      ),
    .REG_ADDR               (7'h52      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG3_DRI_SNK_SEL(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config3_dri_snk_sel                    ),
    .o_reg_data           (reg_config3_dri_snk_sel                      ),
    .o_rcrc               (rcrc_config3_dri_snk_sel                     ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config3_dri_snk_sel = reg_config3_dri_snk_sel;

//CONFIG4_TLTOFF_SEL1 REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h54      ),
    .REG_ADDR               (7'h53      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG4_TLTOFF_SEL1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config4_tltoff_sel1                    ),
    .o_reg_data           (reg_config4_tltoff_sel1                      ),
    .o_rcrc               (rcrc_config4_tltoff_sel1                     ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config4_tltoff_sel1 = reg_config4_tltoff_sel1;

//CONFIG5_TLTOFF_SEL2 REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h1A      ),
    .REG_ADDR               (7'h54      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG5_TLTOFF_SEL2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config5_tltoff_sel2                    ),
    .o_reg_data           (reg_config5_tltoff_sel2                      ),
    .o_rcrc               (rcrc_config5_tltoff_sel2                     ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config5_tltoff_sel2 = reg_config5_tltoff_sel2;

//CONFIG6_DESAT_SEL1 REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h6C      ),
    .REG_ADDR               (7'h55      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG6_DESAT_SEL1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config6_desat_sel1                     ),
    .o_reg_data           (reg_config6_desat_sel1                       ),
    .o_rcrc               (rcrc_config6_desat_sel1                      ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config6_desat_sel1 = reg_config6_desat_sel1;

//CONFIG7_DESAT_SEL2 REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h18      ),
    .REG_ADDR               (7'h56      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG7_DESAT_SEL2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config7_desat_sel2                     ),
    .o_reg_data           (reg_config7_desat_sel2                       ),
    .o_rcrc               (rcrc_config7_desat_sel2                      ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config7_desat_sel2 = reg_config7_desat_sel2;

//CONFIG8_OC_SEL REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hB0      ),
    .REG_ADDR               (7'h57      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG8_OC_SEL(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config8_oc_sel                         ),
    .o_reg_data           (reg_config8_oc_sel                           ),
    .o_rcrc               (rcrc_config8_oc_sel                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config8_oc_sel = reg_config8_oc_sel;

//CONFIG9_SC_SEL REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h90      ),
    .REG_ADDR               (7'h58      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG9_SC_SEL(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config9_sc_sel                         ),
    .o_reg_data           (reg_config9_sc_sel                           ),
    .o_rcrc               (rcrc_config9_sc_sel                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config9_sc_sel = reg_config9_sc_sel;

//CONFIG10_DVDT_REF_SRC REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h03      ),
    .REG_ADDR               (7'h59      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG10_DVDT_REF_SRC(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config10_dvdt_ref_src                  ),
    .o_reg_data           (reg_config10_dvdt_ref_src                    ),
    .o_rcrc               (rcrc_config10_dvdt_ref_src                   ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config10_dvdt_ref_src = reg_config10_dvdt_ref_src;

//CONFIG11_DVDT_REF_SINK REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h03      ),
    .REG_ADDR               (7'h5A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG11_DVDT_REF_SINK(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config11_dvdt_ref_sink                 ),
    .o_reg_data           (reg_config11_dvdt_ref_sink                   ),
    .o_rcrc               (rcrc_config11_dvdt_ref_sink                  ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config11_dvdt_ref_sink = reg_config11_dvdt_ref_sink;

//CONFIG12_ADC_EN REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h5A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b1       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CONFIG12_ADC_EN(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_config12_adc_en                        ),
    .o_reg_data           (reg_config12_adc_en                          ),
    .o_rcrc               (rcrc_config12_adc_en                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_config12_adc_en = reg_config12_adc_en;

//BGR_CODE_DRV REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h60      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_BGR_CODE_DRV(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_bgr_code_drv                           ),
    .o_reg_data           (reg_bgr_code_drv                             ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[9]                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_bgr_code_drv = reg_bgr_code_drv;

//CAP_TRIM_CODE REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h88      ),
    .REG_ADDR               (7'h61      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_CAP_TRIM_CODE(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_cap_trim_code                          ),
    .o_reg_data           (reg_cap_trim_code                            ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[10]                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_cap_trim_code = reg_cap_trim_code;

//CSDEL_CMP REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h70      ),
    .REG_ADDR               (7'h62      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_CSDEL_CMP(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_csdel_cmp                              ),
    .o_reg_data           (reg_csdel_cmp                                ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[11]                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_csdel_cmp = reg_csdel_cmp;

//DVDT_VALUE_ADJ REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h88      ),
    .REG_ADDR               (7'h63      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_DVDT_VALUE_ADJ(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_dvdt_value_adj                         ),
    .o_reg_data           (reg_dvdt_value_adj                           ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[12]                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_dvdt_value_adj = reg_dvdt_value_adj;

//ADC_ADJ1 REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h88      ),
    .REG_ADDR               (7'h64      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ADC_ADJ1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_adc_adj1                               ),
    .o_reg_data           (reg_adc_adj1                                 ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[13]                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_adc_adj1 = reg_adc_adj1;

//ADC_ADJ2 REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h08      ),
    .REG_ADDR               (7'h65      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_ADC_ADJ2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_adc_adj2                               ),
    .o_reg_data           (reg_adc_adj2                                 ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[14]                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_adc_adj2 = reg_adc_adj2;

//IBIAS_CODE_DRV REGISTER
rww_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (7'h66      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b1       )
)U_IBIAS_CODE_DRV(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (i_spi_reg_wdata                              ),
    .o_rdata              (rdata_ibias_code_drv                         ),
    .o_reg_data           (reg_ibias_code_drv                           ),
    .i_lgc_wen            (i_efuse_reg_update                           ),
    .i_lgc_wdata          (i_efuse_reg_data[15]                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_ibias_code_drv = reg_ibias_code_drv;

//DVDT_TM REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h67      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DVDT_TM(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_dvdt_tm                                ),
    .o_reg_data           (reg_dvdt_tm                                  ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_dvdt_tm = reg_dvdt_tm;

//CNT_DEL_READ REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (7'h68      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       )
)U_CNT_DEL_READ(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),    
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({2'b0, i_cnt_del_read}                       ),
    .o_rdata              (rdata_cnt_del_read                           ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//DVDT_WIN_VALUE_EN REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h36      ),
    .REG_ADDR               (7'h69      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DVDT_WIN_VALUE_EN(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_dvdt_win_value_en                      ),
    .o_reg_data           (reg_dvdt_win_value_en                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_dvdt_win_value_en = reg_dvdt_win_value_en;

//PRESET_DELAY REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h6A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_PRESET_DELAY(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_preset_delay                           ),
    .o_reg_data           (reg_preset_delay                             ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_preset_delay = reg_preset_delay;

//DRIVE_DELAY_SET REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h55      ),
    .REG_ADDR               (7'h6B      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_DRIVE_DELAY_SET(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_drive_delay_set                        ),
    .o_reg_data           (reg_drive_delay_set                          ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_drive_delay_set = reg_drive_delay_set;

//CMP_DEL REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hAA      ),
    .REG_ADDR               (7'h6C      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CMP_DEL(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_cmp_del                                ),
    .o_reg_data           (reg_cmp_del                                  ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_cmp_del = reg_cmp_del;

//TEST_MUX REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (7'h6D      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_TEST_MUX(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_test_mux                               ),
    .o_reg_data           (reg_test_mux                                 ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_test_mux = reg_test_mux;

//CMP_ADJ_VREG REGISTER 
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h02      ),
    .REG_ADDR               (7'h6E      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b0       ),
    .SUPPORT_SPI_EN_WR      (1'b0       ),
    .SUPPORT_SPI_EN_RD      (1'b0       ),
    .SUPPORT_EFUSE_WR       (1'b0       )
)U_CMP_ADJ_VREG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_st_reg_en     (i_test_st_reg_en                             ),
    .i_cfg_st_reg_en      (i_cfg_st_reg_en                              ),
    .i_spi_ctrl_reg_en    (i_spi_ctrl_reg_en                            ),
    .i_efuse_ctrl_reg_en  (i_efuse_ctrl_reg_en                          ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           (spi_reg_wcrc                                 ),
    .o_rdata              (rdata_cmp_adj_vreg                           ),
    .o_reg_data           (reg_cmp_adj_vreg                             ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_reg_cmp_adj_vreg = reg_cmp_adj_vreg;


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

assign reg_spi_rdata = com_reg_rdata | rdata_die2_efuse_config | rdata_die2_efuse_status | 
                       rdata_status3 | rdata_status4 | 
                       rdata_bist_rult1 | rdata_bist_rult2 | 
                       rdata_die1_id | rdata_die2_id | rdata_die3_id | rdata_iso_bgr_trim | rdata_iso_con_ibias_trim |
                       rdata_iso_osc48m_trim | rdata_iso_oscb_freq_adj | rdata_iso_reserved_reg | rdata_iso_amp_ibias | 
                       rdata_iso_demo_trim | rdata_iso_test_sw | rdata_iso_osc_jit |
                       rdata_ana_reserved_reg | rdata_config1_dr_src_snk_both | rdata_config2_dr_src_sel | rdata_config3_dri_snk_sel |
                       rdata_config4_tltoff_sel1 | rdata_config5_tltoff_sel2 | rdata_config6_desat_sel1 | rdata_config7_desat_sel2 |
                       rdata_config8_oc_sel | rdata_config9_sc_sel | rdata_config10_dvdt_ref_src | rdata_config11_dvdt_ref_sink  | 
                       rdata_config12_adc_en | rdata_bgr_code_drv | rdata_cap_trim_code | rdata_csdel_cmp | rdata_dvdt_value_adj |
                       rdata_adc_adj1 | rdata_adc_adj2 | rdata_ibias_code_drv | rdata_dvdt_tm | rdata_cnt_del_read | rdata_dvdt_win_value_en |
                       rdata_preset_delay | rdata_drive_delay_set | rdata_cmp_del | rdata_test_mux | rdata_cmp_adj_vreg;

assign reg_spi_rcrc = com_reg_rcrc | rcrc_config1_dr_src_snk_both | rcrc_config2_dr_src_sel | rcrc_config3_dri_snk_sel |
                      rcrc_config4_tltoff_sel1 | rcrc_config5_tltoff_sel2 | rcrc_config6_desat_sel1 | rcrc_config7_desat_sel2 |
                      rcrc_config8_oc_sel | rcrc_config9_sc_sel | rcrc_config10_dvdt_ref_src | rcrc_config11_dvdt_ref_sink |
                      rcrc_config12_adc_en;

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rdata <= {REG_DW{1'b0}};
    end
    else begin
        o_reg_spi_rdata <= spi_reg_ren ? reg_spi_rdata : o_reg_spi_rdata;
    end
end

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rcrc <= {REG_CRC_W{1'b0}};
    end
    else begin
        o_reg_spi_rcrc <= spi_reg_ren ? reg_spi_rcrc : o_reg_spi_rcrc;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule















