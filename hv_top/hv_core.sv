//============================================================
//Module   : hv_core
//Function : 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_core import com_pkg::*; import hv_pkg::*;
#(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                                        i_spi_sclk                      ,
    input  logic                                        i_spi_csb                       ,
    input  logic                                        i_spi_mosi                      ,
    output logic                                        o_spi_miso                      , 

    output logic                                        o_hv_lv_owt_tx                  ,
    input  logic                                        i_lv_hv_owt_rx                  ,

    input  logic                                        i_io_test_mode                  ,
    input  logic                                        i_io_fsenb_n                    ,
    output logic                                        o_fsm_ang_test_en               ,
    input  logic                                        i_hv_vcc_uv                     ,
    input  logic                                        i_hv_vcc_ov                     ,
    input  logic                                        i_hv_ot                         ,
    input  logic                                        i_hv_oc                         ,
    input  logic                                        i_hv_desat_flt                  ,
    input  logic                                        i_hv_scp_flt                    ,

    input  logic                                        i_vrtmon                        ,
    input  logic                                        i_io_fsifo                      ,
    input  logic                                        i_io_pwma                       ,
    input  logic                                        i_io_pwm                        ,
    input  logic                                        i_io_fsstate                    ,
    input  logic                                        i_io_fsenb                      ,
    input  logic                                        i_io_intb_lv                    ,
    input  logic                                        i_io_intb_hv                    ,

    input  logic                                        i_ang_dgt_pwm_wv                , //analog pwm ctrl to digtial pwm ctrl pwm wave
    input  logic                                        i_ang_dgt_pwm_fs                ,

    output logic                                        o_dgt_ang_pwm_en                ,
    output logic                                        o_dgt_ang_fsc_en                ,
    output logic                                        o_io_pwm_l2h                    ,
  
    output str_reg_iso_bgr_trim                         o_reg_iso_bgr_trim              ,
    output str_reg_iso_con_ibias_trim                   o_reg_iso_con_ibias_trim        ,
    output str_reg_iso_osc48m_trim                      o_reg_iso_osc48m_trim           ,
    output str_reg_iso_oscb_freq_adj                    o_reg_iso_oscb_freq_adj         ,
    output str_reg_iso_reserved_reg                     o_reg_iso_reserved_reg          ,
    output str_reg_iso_amp_ibias                        o_reg_iso_amp_ibias             ,
    output str_reg_iso_demo_trim                        o_reg_iso_demo_trim             ,
    output str_reg_iso_test_sw                          o_reg_iso_test_sw               ,
    output str_reg_iso_osc_jit                          o_reg_iso_osc_jit               ,
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

    output logic                                        o_intb_n                        ,

    input  logic                                        i_clk                           ,
    input  logic                                        i_rst_n
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                                               fsm_spi_slv_en          ;
logic                                               spi_rac_wr_req          ;
logic                                               spi_rac_rd_req          ;
logic [REG_AW-1:            0]                      spi_rac_addr            ; 
logic [REG_DW-1:            0]                      spi_rac_wdata           ;
logic [REG_CRC_W-1:         0]                      spi_rac_wcrc            ; 
logic                                               rac_spi_wack            ;
logic                                               rac_spi_rack            ;
logic [REG_DW-1:            0]                      rac_spi_data            ;
logic [REG_AW-1:            0]                      rac_spi_addr            ; 
logic                                               spi_reg_slv_err         ; 
    
logic                                               wdg_scan_rac_rd_req     ;
logic [REG_AW-1:            0]                      wdg_scan_rac_addr       ;
logic                                               rac_wdg_scan_ack        ;
logic [REG_DW-1:            0]                      rac_wdg_scan_data       ;
logic [REG_CRC_W-1:         0]                      rac_wdg_scan_crc        ;
    
logic                                               spi_owt_wr_req          ;
logic                                               spi_owt_rd_req          ;
logic [REG_AW-1:            0]                      spi_owt_addr            ;
logic [REG_DW-1:            0]                      spi_owt_data            ;
logic                                               owt_tx_spi_ack          ;
logic                                               owt_rx_spi_rsp          ;
logic                                               spi_rst_wdg             ;
    
logic                                               rac_reg_ren             ;
logic                                               rac_reg_wen             ;
logic [REG_AW-1:            0]                      rac_reg_addr            ;
logic [REG_DW-1:            0]                      rac_reg_wdata           ;
logic [REG_CRC_W-1:         0]                      rac_reg_wcrc            ;
    
logic                                               reg_rac_wack            ;
logic                                               reg_rac_rack            ;
logic [REG_DW-1:            0]                      reg_rac_rdata           ;
logic [REG_CRC_W-1:         0]                      reg_rac_rcrc            ;
    
logic                                               wdg_owt_adc_req         ;
logic                                               owt_wdg_adc_ack         ;
    
logic [OWT_CMD_BIT_NUM-1:   0]                      owt_tx_cmd_lock         ;
    
logic                                               owt_rx_rac_vld          ;
logic [OWT_CMD_BIT_NUM-1:   0]                      owt_rx_rac_cmd          ;
logic [OWT_DATA_BIT_NUM-1:  0]                      owt_rx_rac_data         ;
logic                                               owt_rx_rac_status       ;//0: normal; 1: error. 
    
logic                                               owt_rx_rst_wdg_owt      ;
logic                                               wdg_owt_rx_tmo          ;  
    
str_reg_com_config1                                 reg_com_config1         ;
logic                                               owt_rx_reg_slv_owtcomerr;//owt_com_err.
    
logic                                               wdg_scan_en             ;
logic                                               wdg_scan_reg_slv_crcerr ;//cerr = crc_err.
    
logic                                               bist_scan_reg_req       ;
logic                                               scan_reg_bist_ack       ;
logic                                               scan_reg_bist_err       ;
    
logic                                               wdg_owt_en              ;
logic                                               wdg_owt_tx_adc_req      ;
logic                                               owt_tx_wdg_adc_ack      ;
    
logic                                               fsm_wdg_owt_tx_req      ;
logic                                               bist_wdg_owt_tx_req     ;
    
logic                                               wdg_owt_reg_slv_tmoerr  ;//timeout_err
str_reg_com_config2                                 reg_com_config2         ;
    
logic                                               hv_vcc_uverr            ;
logic                                               hv_vcc_overr            ;
logic                                               hv_ot_err               ;
logic                                               hv_oc_err               ;
logic                                               hv_desat_err            ;
logic                                               hv_scp_err              ;
            
logic                                               efuse_reg_update        ;
logic [EFUSE_DATA_NUM-1:     0][EFUSE_DW-1: 0]      efuse_reg_data          ;
    
str_reg_mode                                        reg_mode                ;
str_reg_status1                                     reg_status1             ;
str_reg_status2                                     reg_status2             ;
str_reg_efuse_config                                reg_die1_efuse_config   ;
str_reg_efuse_status                                reg_die1_efuse_status   ;
    
logic                                               test_st_reg_en          ;
logic                                               cfg_st_reg_en           ;
logic                                               spi_ctrl_reg_en         ;
logic                                               efuse_ctrl_reg_en       ;
    
logic [CTRL_FSM_ST_W-1:      0]                     lv_ctrl_cur_st          ;
    
logic                                               fsm_dgt_pwm_en          ;
logic                                               fsm_dgt_fsc_en          ;
logic                                               bist_en                 ;
    
logic                                               efuse_load_req          ;
logic                                               efuse_load_done         ; //hardware lanch, indicate efuse have load done.
    
logic                                               lbist_en                ;
logic                                               lv_bist_fail            ;
    
logic                                               owt_rx_rac_vld          ;
logic [OWT_CMD_BIT_NUM-1:    0]                     owt_rx_rac_cmd          ;
logic [OWT_DATA_BIT_NUM-1:   0]                     owt_rx_rac_data         ;
logic [OWT_CRC_BIT_NUM-1:    0]                     owt_rx_rac_crc          ;
logic                                               owt_rx_rac_status       ;


logic                                               rac_owt_tx_wr_cmd_vld   ;
logic                                               rac_owt_tx_rd_cmd_vld   ;
logic [REG_AW-1:             0]                     rac_owt_tx_addr         ;
logic [OWT_ADCD_BIT_NUM-1:             0]           rac_owt_tx_data         ;    
//==================================        
//main code
//==================================
spi_slv U_SPI_SLV(
    .i_spi_sclk                 (i_spi_sclk                         ),
    .i_spi_csb                  (i_spi_csb                          ),
    .i_spi_mosi                 (i_spi_mosi                         ),
    .o_spi_miso                 (o_spi_miso                         ),

    .i_spi_slv_en               (fsm_spi_slv_en                     ),

    .o_spi_rac_wr_req           (spi_rac_wr_req                     ),
    .o_spi_rac_rd_req           (spi_rac_rd_req                     ),
    .o_spi_rac_addr             (spi_rac_addr                       ),
    .o_spi_rac_wdata            (spi_rac_wdata                      ),
    .o_spi_rac_wcrc             (spi_rac_wcrc                       ),

    .i_rac_spi_wack             (rac_spi_wack                       ),
    .i_rac_spi_rack             (rac_spi_rack                       ),
    .i_rac_spi_data             (rac_spi_data                       ),
    .i_rac_spi_addr             (rac_spi_addr                       ),

    .o_spi_err                  (spi_reg_slv_err                    ),

    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

hv_owt_rx_ctrl U_HV_OWT_RX_CTRL(
    .i_lv_hv_owt_rx             (i_lv_hv_owt_rx                     ),
    .o_owt_rx_rac_vld           (owt_rx_rac_vld                     ),
    .o_owt_rx_rac_cmd           (owt_rx_rac_cmd                     ),
    .o_owt_rx_rac_data          (owt_rx_rac_data                    ),
    .o_owt_rx_rac_crc           (owt_rx_rac_crc                     )
    .o_owt_rx_status            (owt_rx_rac_status                  ),

    .o_owt_rx_rst_wdg_owt       (owt_rx_rst_wdg_owt                 ),
                         
    .i_reg_comerr_mode          (reg_com_config1.comerr_mode        ),
    .i_reg_comerr_config        (reg_com_config1.comerr_config      ),
    .o_owt_com_err              (owt_rx_reg_slv_owtcomerr           ),
       
    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
   
lv_reg_access_ctrl U_LV_REG_ACCESS_CTRL(
    .i_wdg_scan_rac_rd_req      (wdg_scan_rac_rd_req                ),
    .i_wdg_scan_rac_addr        (wdg_scan_rac_addr                  ),
    .o_rac_wdg_scan_ack         (rac_wdg_scan_ack                   ),
    .o_rac_wdg_scan_data        (rac_wdg_scan_data                  ),
    .o_rac_wdg_scan_crc         (rac_wdg_scan_crc                   ),

    .i_spi_rac_wr_req           (spi_rac_wr_req                     ),
    .i_spi_rac_rd_req           (spi_rac_rd_req                     ),
    .i_spi_rac_addr             (spi_rac_addr                       ),
    .i_spi_rac_wdata            (spi_rac_wdata                      ),
    .i_spi_rac_wcrc             (spi_rac_wcrc                       ),

    .o_rac_spi_wack             (rac_spi_wack                       ),
    .o_rac_spi_rack             (rac_spi_rack                       ),
    .o_rac_spi_data             (rac_spi_data                       ),
    .o_rac_spi_addr             (rac_spi_addr                       ),

    .i_owt_rx_rac_vld           (owt_rx_rac_vld                     ),
    .i_owt_rx_rac_cmd           (owt_rx_rac_cmd                     ),
    .i_owt_rx_rac_data          (owt_rx_rac_data                    ),
    .i_owt_rx_rac_crc           (owt_rx_rac_crc                     ),
    .i_owt_rx_rac_status        (owt_rx_rac_status                  ),

    o_rac_owt_tx_wr_cmd_vld     (rac_owt_tx_wr_cmd_vld              ),
    o_rac_owt_tx_rd_cmd_vld     (rac_owt_tx_rd_cmd_vld              ),
    o_rac_owt_tx_addr           (rac_owt_tx_addr                    ),
    o_rac_owt_tx_data           (rac_owt_tx_data                    ),

    .o_rac_reg_ren              (rac_reg_ren                        ),
    .o_rac_reg_wen              (rac_reg_wen                        ),
    .o_rac_reg_addr             (rac_reg_addr                       ),
    .o_rac_reg_wdata            (rac_reg_wdata                      ),
    .o_rac_reg_wcrc             (rac_reg_wcrc                       ),

    .i_reg_rac_wack             (reg_rac_wack                       ),
    .i_reg_rac_rack             (reg_rac_rack                       ),
    .i_reg_rac_rdata            (reg_rac_rdata                      ),
    .i_reg_rac_rcrc             (reg_rac_rcrc                       ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
    
lv_owt_tx_ctrl U_LV_OWT_TX_CTRL(
    .i_rac_owt_tx_wr_cmd_vld    (rac_owt_tx_wr_cmd_vld              ),
    .i_rac_owt_tx_rd_cmd_vld    (rac_owt_tx_rd_cmd_vld              ),
    .i_rac_owt_tx_addr          (rac_owt_tx_addr                    ),
    .i_rac_owt_tx_data          (rac_owt_tx_data                    ),
    .o_lv_hv_owt_tx             (o_hv_lv_owt_tx                     ),
    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
   
lv_wdg_ctrl U_LV_WDG_CTRL(
    .i_wdg_scan_en              (wdg_scan_en                        ),
    .o_wdg_scan_rac_rd_req      (wdg_scan_rac_rd_req                ), //wdg_scan to rac, rac = reg_access_ctrl
    .o_wdg_scan_rac_addr        (wdg_scan_rac_addr                  ),
    .i_rac_wdg_scan_ack         (rac_wdg_scan_ack                   ),
    .i_rac_wdg_scan_data        (rac_wdg_scan_data                  ),
    .i_rac_wdg_scan_crc         (rac_wdg_scan_crc                   ),
    .o_wdg_scan_crc_err         (wdg_scan_reg_slv_crcerr            ),

    .i_bist_scan_reg_req        (bist_scan_reg_req                  ),
    .o_scan_reg_bist_ack        (scan_reg_bist_ack                  ),
    .o_scan_reg_bist_err        (scan_reg_bist_err                  ),

    .i_wdg_owt_en               (wdg_owt_en                         ),
    .i_owt_rx_rst_wdg_owt       (owt_rx_rst_wdg_owt                 ),

    .o_wdg_timeout_err          (wdg_owt_reg_slv_tmoerr             ),

    .i_wdgtmo_config            (reg_com_config2.hv_wdgtmo_config   ),
    .i_wdgcrc_config            (reg_com_config2.wdgcrc_config      ),

    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
    
hv_analog_int_proc U_HV_ANALOG_INT_PRO(
    .i_hv_vcc_uv                (i_hv_vcc_uv                        ),
    .i_hv_vcc_ov                (i_hv_vcc_ov                        ),
    .i_hv_ot                    (i_hv_ot                            ),
    .i_hv_oc                    (i_hv_oc                            ),
    .i_hv_desat_flt             (i_hv_desat_flt                     ),
    .i_hv_scp_flt               (i_hv_scp_flt                       ),

    .o_hv_vcc_uverr             (hv_vcc_uverr                       ),
    .o_hv_vcc_overr             (hv_vcc_overr                       ),
    .o_hv_ot_err                (hv_ot_err                          ),
    .o_hv_oc_err                (hv_oc_err                          ),
    .o_hv_desat_err             (hv_desat_err                       ),
    .o_hv_scp_err               (hv_scp_err                         ),

    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);
    
assign lv_status1 = {lv_bist_fail, 1'b0, lv_pwm_mmerr, lv_pwm_dterr,
                     wdg_owt_reg_slv_tmoerr, owt_rx_reg_slv_owtcomerr, wdg_scan_reg_slv_crcerr, spi_reg_slv_err};
    
assign lv_status2 = {6'b0, i_lv_vsup_ov, ~i_lv_vsup_uv_n};
    
assign lv_status3 = {i_vrtmon,     i_io_fsifo, i_io_pwma, i_io_pwm,
                     i_io_fsstate, i_io_fsenb, i_io_intb_lv, i_io_intb_hv};
    
assign lv_status4 = {4'b0, lv_ctrl_cur_st};   
    
hv_reg_slv U_HV_REG_SLV(
    .i_spi_reg_ren              (rac_reg_ren                        ),
    .i_spi_reg_wen              (rac_reg_wen                        ),
    .i_spi_reg_addr             (rac_reg_addr                       ),
    .i_spi_reg_wdata            (rac_reg_wdata                      ),
    .i_spi_reg_wcrc             (rac_reg_wcrc                       ),

    .o_reg_spi_wack             (reg_rac_wack                       ),
    .o_reg_spi_rack             (reg_rac_rack                       ),
    .o_reg_spi_rdata            (reg_rac_rdata                      ),
    .o_reg_spi_rcrc             (reg_rac_rcrc                       ),

    .i_hv_status1               (reg_hv_status1                     ),
    .i_hv_status2               (reg_hv_status2                     ),
    .i_hv_status3               (reg_hv_status3                     ),
    .i_hv_status4               (reg_hv_status4                     ),
    .i_hv_adc1_data             (reg_hv_adc1_data                   ),
    .i_hv_adc2_data             (reg_hv_adc2_data                   ),
    .i_hv_bist1                 (reg_hv_bist1                       ),
    .i_hv_bist2                 (reg_hv_bist2                       ),

    .i_efuse_reg_update         (efuse_reg_update                   ),
    .i_efuse_reg_data           (efuse_reg_data                     ),

    .o_reg_mode                 (reg_mode                           ),
    .o_reg_com_config1          (reg_com_config1                    ),
    .o_reg_com_config2          (reg_com_config2                    ),
    .o_reg_status1              (reg_status1                        ),
    .o_reg_status2              (reg_status2                        ),
    .o_reg_die2_efuse_config    (reg_die2_efuse_config              ),
    .o_reg_die2_efuse_status    (reg_die2_efuse_status              ),

    .o_reg_iso_bgr_trim         (o_reg_iso_bgr_trim                 ),
    .o_reg_iso_con_ibias_trim   (o_reg_iso_con_ibias_trim           ),
    .o_reg_iso_osc48m_trim      (o_reg_iso_osc48m_trim              ),
    .o_reg_iso_oscb_freq_adj    (o_reg_iso_oscb_freq_adj            ),
    .o_reg_iso_reserved_reg     (o_reg_iso_reserved_reg             ),
    .o_reg_iso_amp_ibias        (o_reg_iso_amp_ibias                ),
    .o_reg_iso_demo_trim        (o_reg_iso_demo_trim                ),
    .o_reg_iso_test_sw          (o_reg_iso_test_sw                  ),
    .o_reg_iso_osc_jit          (o_reg_iso_osc_jit                  ),
    .o_reg_config0_t_deat_time  (o_reg_config0_t_deat_time          ),
    
    .i_test_st_reg_en           (test_st_reg_en                     ),
    .i_cfg_st_reg_en            (cfg_st_reg_en                      ),
    .i_spi_ctrl_reg_en          (spi_ctrl_reg_en                    ),
    .i_efuse_ctrl_reg_en        (efuse_ctrl_reg_en                  ),

    .i_clk                      (i_clk                              ),
    .i_hrst_n                   (i_rst_n                            ),
    .o_rst_n                    (                                   )
);



input logic [5:                0]                   i_cnt_del_read                  ,

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


lv_ctrl_unit U_LV_CTRL_UNIT(
    .i_pwr_on                   (i_pwr_on                           ),
    .i_io_test_mode             (i_io_test_mode                     ),
    .i_reg_efuse_vld            (o_reg_iso_reserved_reg.efuse_vld   ),
    .i_reg_efuse_done           (reg_mode.efuse_done                ),//soft lanch, make test_st -> wait_st
    .i_io_fsenb_n               (i_io_fsenb_n                       ),
    .i_reg_spi_err              (reg_status1[0]                     ),
    .i_reg_scan_crc_err         (reg_status1[1]                     ),    
    .i_reg_owt_com_err          (reg_status1[2]                     ),
    .i_reg_wdg_tmo_err          (reg_status1[3]                     ),//tmo = timeout
    .i_reg_lv_pwm_dterr         (reg_status1[4]                     ),
    .i_reg_lv_pwm_mmerr         (reg_status1[5]                     ),
    .i_reg_lv_vsup_uverr        (reg_status2[0]                     ),
    .i_reg_lv_vsup_overr        (reg_status2[1]                     ),
    .i_reg_hv_vcc_uverr         (reg_status2[2]                     ),
    .i_reg_hv_vcc_overr         (reg_status2[3]                     ),
    .i_reg_hv_ot_err            (reg_status2[4]                     ),
    .i_reg_hv_oc_err            (reg_status2[5]                     ),
    .i_reg_hv_desat_err         (reg_status2[6]                     ),
    .i_reg_hv_scp_err           (reg_status2[7]                     ),

    .i_reg_nml_en               (reg_mode.normal_en                 ),
    .i_reg_cfg_en               (reg_mode.cfg_en                    ),
    .i_reg_bist_en              (reg_mode.bist_en                   ),
    .i_reg_rst_en               (reg_mode.reset_en                  ),

    .o_pwm_en                   (fsm_dgt_pwm_en                     ),
    .o_fsc_en                   (fsm_dgt_fsc_en                     ),
    .o_wdg_scan_en              (wdg_scan_en                        ),
    .o_spi_en                   (fsm_spi_slv_en                     ),
    .o_owt_com_en               (wdg_owt_en                         ),
    .o_cfg_st_reg_en            (cfg_st_reg_en                      ),//when in cfg_st support reg read & write.
    .o_test_st_reg_en           (test_st_reg_en                     ),//when in test_st support reg read & write.
    .o_spi_ctrl_reg_en          (spi_ctrl_reg_en                    ),//when spi enable support reg read & write.
    .o_bist_en                  (bist_en                            ),
    .o_fsm_ang_test_en          (o_fsm_ang_test_en                  ),//ctrl analog mdl into test mode.

    .i_hv_intb_n                (hv_intb_n                          ),
    .o_intb_n                   (o_intb_n                           ),

    .o_efuse_load_req           (efuse_load_req                     ),
    .i_efuse_load_done          (efuse_load_done                    ), //hardware lanch, indicate efuse have load done.
    
    .o_fsm_wdg_owt_tx_req       (fsm_wdg_owt_tx_req                 ),
    .i_owt_rx_ack               (owt_rx_ack                         ),
    
    .o_lv_ctrl_cur_st           (lv_ctrl_cur_st                     ),

    .i_clk	                    (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);



    
    lv_pwm_intb_decode U_LV_PWM_INTB_DECODE(
        .i_hv_pwm_intb_n            (i_hv_pwm_intb_n                    ),
        .o_lv_pwm_gwave             (                                   ),
        .o_hv_intb_n                (hv_intb_n                          ),
        .i_clk	                    (i_clk                              ),
        .i_rst_n                    (i_rst_n                            )
    );
    
    lv_abist U_LV_ABIST(
        .i_bist_en                  (bist_en                            ),     
        .i_bist_lv_ov               (i_bist_lv_ov                       ),
        .i_lv_vsup_ov               (i_lv_vsup_ov                       ),
        .o_lbist_en                 (lbist_en                           ),
        .i_clk                      (i_clk                              ),
        .i_rst_n                    (i_rst_n                            )
    );
    
    lv_lbist U_LV_LBIST(
        .i_bist_en                  (lbist_en                           ),
        .o_bist_wdg_owt_tx_req      (bist_wdg_owt_tx_req                ),
        .i_owt_rx_ack               (owt_rx_ack                         ),
        .i_owt_rx_status            (owt_rx_status                      ),
        .o_bist_scan_reg_req        (bist_scan_reg_req                  ),
        .i_scan_reg_bist_ack        (scan_reg_bist_ack                  ),
        .i_scan_reg_bist_err        (scan_reg_bist_err                  ),
        .o_lv_bist_fail             (lv_bist_fail                       ),
        .i_clk                      (i_clk                              ),
        .i_rst_n                    (i_rst_n                            )
    );
    
    lv_dgt_pwm_ctrl U_LV_DGT_PWM_CTRL(
        .i_ang_dgt_pwm_wv           (i_ang_dgt_pwm_wv                   ), //analog pwm ctrl to digtial pwm ctrl pwm wave
        .i_ang_dgt_pwm_fs           (i_ang_dgt_pwm_fs                   ),
        .i_fsm_dgt_pwm_en           (fsm_dgt_pwm_en                     ),
        .i_fsm_dgt_fsc_en           (fsm_dgt_fsc_en                     ),
        .o_dgt_ang_pwm_en           (o_dgt_ang_pwm_en                   ),
        .o_dgt_ang_fsc_en           (o_dgt_ang_fsc_en                   ),
        .o_io_pwm_l2h               (o_io_pwm_l2h                       ),
        .i_clk                      (i_clk                              ),
        .i_rst_n                    (i_rst_n                            )
    );
    // synopsys translate_off    
    //==================================
    //assertion
    //==================================
    //    
    // synopsys translate_on    
    endmodule
    

    

    

    
