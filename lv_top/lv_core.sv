//============================================================
//Module   : lv_core
//Function : 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_core import com_pkg::*; import lv_pkg::*;
#(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                                        i_spi_sclk                      ,
    input  logic                                        i_spi_csb                       ,
    input  logic                                        i_spi_mosi                      ,
    output logic                                        o_spi_miso                      , 

    input  logic                                        i_s32_sel                       , //1: sel 32pin logic; 0: sel 16pin logic
    input  logic                                        i_scan_mode                     ,

    output logic                                        o_lv_hv_owt_tx                  ,
    input  logic                                        i_hv_lv_owt_rx                  ,

    input  logic                                        i_setb                          ,
    input  logic                                        i_io_test_mode                  ,
    input  logic                                        i_io_fsenb_n                    ,
    output logic                                        o_fsm_ang_test_en               ,//vl_pins32
    input  logic                                        i_hv_pwm_intb_n                 ,
    input  logic                                        i_lv_vsup_ov                    ,
    input  logic                                        i_lv_vsup_uv_n                  ,
    input  logic                                        i_lv_pwm_dt                     ,
    input  logic                                        i_lv_gate_vs_pwm                ,

    input  logic                                        i_io_pwma                       ,
    input  logic                                        i_io_pwm                        ,
    input  logic                                        i_io_fsstate                    ,
    input  logic                                        i_io_intb                       ,
    input  logic                                        i_io_inta                       ,

    output logic                                        o_dgt_ang_pwm_en                ,
    output logic                                        o_dgt_ang_fsc_en                ,
  
    output logic [7:    0]                              o_adc1_data                     ,
    output logic [7:    0]                              o_adc2_data                     ,
    output logic                                        o_adc1_en                       ,
    output logic                                        o_adc2_en                       ,
    output logic                                        o_aout_wait                     ,
    output logic                                        o_aout_bist                     ,
    output logic                                        o_rtmon                         ,
    output logic                                        o_bistlv_ov                     ,

    output str_reg_iso_bgr_trim                         o_reg_iso_bgr_trim              ,
    output str_reg_iso_con_ibias_trim                   o_reg_iso_con_ibias_trim        ,
    output str_reg_iso_osc48m_trim                      o_reg_iso_osc48m_trim           ,
    output str_reg_iso_oscb_freq_adj                    o_reg_iso_oscb_freq_adj         ,
    output str_reg_iso_reserved_reg                     o_reg_iso_reserved_reg          ,
    output str_reg_iso_amp_ibias                        o_reg_iso_amp_ibias             ,
    output str_reg_iso_demo_trim                        o_reg_iso_demo_trim             ,
    output str_reg_iso_test_sw                          o_reg_iso_test_sw               ,
    output str_reg_iso_osc_jit                          o_reg_iso_osc_jit               ,
    output logic [7:    0]                              o_reg_ana_reserved_reg          ,
    output str_reg_config0_t_deat_time                  o_reg_config0_t_deat_time       ,

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

logic                                               owt_rx_ack              ;
logic [OWT_CMD_BIT_NUM-1:   0]                      owt_rx_cmd              ;
logic [OWT_ADCD_BIT_NUM-1:  0]                      owt_rx_data             ;
logic                                               owt_rx_status           ;//0: normal; 1: error. 

logic                                               owt_rx_wdg_rsp          ;
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

logic                                               lv_pwm_mmerr            ;
logic                                               lv_pwm_dterr            ;

logic [REG_DW-1:             0]                     lv_status1              ;
logic [REG_DW-1:             0]                     lv_status2              ;
logic [REG_DW-1:             0]                     lv_status3              ;
logic [REG_DW-1:             0]                     lv_status4              ;


str_reg_efuse_config                                reg_die2_efuse_config   ;
str_reg_efuse_status                                reg_die2_efuse_status   ;
logic [REG_DW-1:             0]                     reg_hv_status1          ;
logic [REG_DW-1:             0]                     reg_hv_status2          ;
logic [REG_DW-1:             0]                     reg_hv_status3          ;
logic [REG_DW-1:             0]                     reg_hv_status4          ;
logic [ADC_DW-1:             0]                     reg_hv_adc1_data        ;
logic [ADC_DW-1:             0]                     reg_hv_adc2_data        ;
logic [REG_DW-1:             0]                     reg_hv_bist1            ;
logic [REG_DW-1:             0]                     reg_hv_bist2            ;

logic                                               hv_reg_vld              ;
logic [REG_DW-1:             0]                     hv_ang_reg_data         ;

logic                                               efuse_op_finish         ;
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

    .i_clk                      (i_clk                              ),
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

    .o_spi_owt_wr_req           (spi_owt_wr_req                     ),
    .o_spi_owt_rd_req           (spi_owt_rd_req                     ),
    .o_spi_owt_addr             (spi_owt_addr                       ),
    .o_spi_owt_data             (spi_owt_data                       ),
    .i_owt_tx_spi_ack           (owt_tx_spi_ack                     ),
    .i_owt_rx_spi_rsp           (owt_rx_spi_rsp                     ),
    .o_spi_rst_wdg              (spi_rst_wdg                        ),

    .o_rac_reg_ren              (rac_reg_ren                        ),
    .o_rac_reg_wen              (rac_reg_wen                        ),
    .o_rac_reg_addr             (rac_reg_addr                       ),
    .o_rac_reg_wdata            (rac_reg_wdata                      ),
    .o_rac_reg_wcrc             (rac_reg_wcrc                       ),

    .i_reg_rac_wack             (reg_rac_wack                       ),
    .i_reg_rac_rack             (reg_rac_rack                       ),
    .i_reg_rac_rdata            (reg_rac_rdata                      ),
    .i_reg_rac_rcrc             (reg_rac_rcrc                       ),

    .i_hv_reg_vld               (hv_reg_vld                         ),
    .i_hv_ang_reg_data          (hv_ang_reg_data                    ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

lv_owt_tx_ctrl U_LV_OWT_TX_CTRL(
    .i_spi_owt_wr_req           (spi_owt_wr_req                     ),
    .i_spi_owt_rd_req           (spi_owt_rd_req                     ),
    .i_spi_owt_addr             (spi_owt_addr                       ),
    .i_spi_owt_data             (spi_owt_data                       ),
    .o_owt_tx_spi_ack           (owt_tx_spi_ack                     ),
    
    .i_wdg_owt_adc_req          (wdg_owt_adc_req                    ),
    .o_owt_wdg_adc_ack          (owt_wdg_adc_ack                    ),

    .o_lv_hv_owt_tx             (o_lv_hv_owt_tx                     ),

    .o_owt_tx_cmd_lock          (owt_tx_cmd_lock                    ),
    
    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

lv_owt_rx_ctrl U_LV_OWT_RX_CTRL(
    .i_hv_lv_owt_rx             (i_hv_lv_owt_rx                     ),
    .o_owt_rx_ack               (owt_rx_ack                         ),
    .o_owt_rx_cmd               (owt_rx_cmd                         ),
    .o_owt_rx_data              (owt_rx_data                        ),
    .o_owt_rx_status            (owt_rx_status                      ),//0: normal; 1: error. 

    .o_owt_rx_wdg_rsp           (owt_rx_wdg_rsp                     ),
    .i_wdg_owt_rx_tmo           (wdg_owt_rx_tmo                     ),//for test_st owt timeout, gen a owt_rx rsp.
    .i_ctrl_unit_cur_fsm_st     (lv_ctrl_cur_st                     ),                           

    .i_reg_comerr_mode          (reg_com_config1.comerr_mode        ),
    .i_reg_comerr_config        (reg_com_config1.comerr_config      ),
    .o_owt_com_err              (owt_rx_reg_slv_owtcomerr           ),

    .i_owt_tx_cmd_lock          (owt_tx_cmd_lock                    ),        
    
    .i_clk                      (i_clk                              ),
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
    .o_wdg_owt_tx_adc_req       (wdg_owt_adc_req                    ),
    .i_owt_tx_wdg_adc_ack       (owt_wdg_adc_ack                    ),
    .i_spi_rst_wdg              (spi_rst_wdg                        ),

    .i_fsm_wdg_owt_tx_req       (fsm_wdg_owt_tx_req                 ),
    .i_bist_wdg_owt_tx_req      (bist_wdg_owt_tx_req                ),

    .i_owt_rx_wdg_rsp           (owt_rx_wdg_rsp                     ),
    .o_wdg_owt_rx_tmo           (wdg_owt_rx_tmo                     ),
    .o_wdg_timeout_err          (wdg_owt_reg_slv_tmoerr             ),

    .i_wdgtmo_config            (reg_com_config2.lv_wdgtmo_config   ),
    .i_wdgrefresh_config        (reg_com_config2.wdgrefresh_config  ),
    .i_wdgcrc_config            (reg_com_config2.wdgcrc_config      ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

lv_hv_shadow_reg U_LV_HV_SHADOW_REG(
    .i_owt_rx_ack               (owt_rx_ack                         ),
    .i_owt_rx_cmd               (owt_rx_cmd                         ),
    .i_owt_rx_data              (owt_rx_data                        ),
    .i_owt_rx_status            (owt_rx_status                      ),//0: normal; 1: error. 

    .o_reg_die2_efuse_config    (reg_die2_efuse_config              ),
    .o_reg_die2_efuse_status    (reg_die2_efuse_status              ),
    .o_reg_status1              (reg_hv_status1                     ),
    .o_reg_status2              (reg_hv_status2                     ),
    .o_reg_status3              (reg_hv_status3                     ),
    .o_reg_status4              (reg_hv_status4                     ),
    .o_reg_adc1_data            (reg_hv_adc1_data                   ),
    .o_reg_adc2_data            (reg_hv_adc2_data                   ),
    .o_reg_bist1                (reg_hv_bist1                       ),
    .o_reg_bist2                (reg_hv_bist2                       ),

    .o_hv_reg_vld               (hv_reg_vld                         ),
    .o_hv_ang_reg_data          (hv_ang_reg_data                    ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

lv_analog_int_proc U_LV_ANALOG_INT_PROC(
    .i_lv_pwm_dt                (i_lv_pwm_dt                            ),
    .i_lv_gate_vs_pwm           (i_lv_gate_vs_pwm                       ),
    .i_vge_mon_dly              (o_reg_config0_t_deat_time.vge_mon_dly  ),

    .o_lv_pwm_mmerr             (lv_pwm_mmerr                           ),
    .o_lv_pwm_dterr             (lv_pwm_dterr                           ),

    .i_clk                      (i_clk                                  ),
    .i_rst_n                    (i_rst_n                                )
);

assign lv_status1 = {lv_bist_fail, 1'b0, lv_pwm_mmerr, lv_pwm_dterr,
                     wdg_owt_reg_slv_tmoerr, owt_rx_reg_slv_owtcomerr, wdg_scan_reg_slv_crcerr, spi_reg_slv_err};

assign lv_status2 = {6'b0, i_lv_vsup_ov, ~i_lv_vsup_uv_n};

assign lv_status3 = {1'b0,         1'b0,         i_io_pwma, i_io_pwm,
                     i_io_fsstate, i_io_fsenb_n, i_io_intb, i_io_inta};

assign lv_status4 = {4'b0, lv_ctrl_cur_st};   

lv_reg_slv U_LV_REG_SLV(
    .i_spi_reg_ren              (rac_reg_ren                        ),
    .i_spi_reg_wen              (rac_reg_wen                        ),
    .i_spi_reg_addr             (rac_reg_addr                       ),
    .i_spi_reg_wdata            (rac_reg_wdata                      ),
    .i_spi_reg_wcrc             (rac_reg_wcrc                       ),

    .o_reg_spi_wack             (reg_rac_wack                       ),
    .o_reg_spi_rack             (reg_rac_rack                       ),
    .o_reg_spi_rdata            (reg_rac_rdata                      ),
    .o_reg_spi_rcrc             (reg_rac_rcrc                       ),
    
    .i_lv_status1               (lv_status1                         ),
    .i_lv_status2               (lv_status2                         ),
    .i_lv_status3               (lv_status3                         ),
    .i_lv_status4               (lv_status4                         ),
    .i_lv_bist1                 (8'b0                               ),
    .i_lv_bist2                 (8'b0                               ),

    .i_reg_die2_efuse_config    (reg_die2_efuse_config              ),
    .i_reg_die2_efuse_status    (reg_die2_efuse_status              ),

    .i_hv_status1               (reg_hv_status1                     ),
    .i_hv_status2               (reg_hv_status2                     ),
    .i_hv_status3               (reg_hv_status3                     ),
    .i_hv_status4               (reg_hv_status4                     ),
    .i_hv_adc1_data             (reg_hv_adc1_data                   ),
    .i_hv_adc2_data             (reg_hv_adc2_data                   ),
    .i_hv_bist1                 (reg_hv_bist1                       ),
    .i_hv_bist2                 (reg_hv_bist2                       ),

    .i_efuse_op_finish          (1'b1                               ),
    .i_efuse_reg_update         (1'b1                               ),
    .i_efuse_reg_data           (efuse_reg_data                     ),

    .o_reg_mode                 (reg_mode                           ),
    .o_reg_com_config1          (reg_com_config1                    ),
    .o_reg_com_config2          (reg_com_config2                    ),
    .o_reg_status1              (reg_status1                        ),
    .o_reg_status2              (reg_status2                        ),
    .o_reg_die1_efuse_config    (reg_die1_efuse_config              ),
    .o_reg_die1_efuse_status    (reg_die1_efuse_status              ),

    .o_reg_iso_bgr_trim         (o_reg_iso_bgr_trim                 ),
    .o_reg_iso_con_ibias_trim   (o_reg_iso_con_ibias_trim           ),
    .o_reg_iso_osc48m_trim      (o_reg_iso_osc48m_trim              ),
    .o_reg_iso_oscb_freq_adj    (o_reg_iso_oscb_freq_adj            ),
    .o_reg_iso_reserved_reg     (o_reg_iso_reserved_reg             ),
    .o_reg_iso_amp_ibias        (o_reg_iso_amp_ibias                ),
    .o_reg_iso_demo_trim        (o_reg_iso_demo_trim                ),
    .o_reg_iso_test_sw          (o_reg_iso_test_sw                  ),
    .o_reg_iso_osc_jit          (o_reg_iso_osc_jit                  ),
    .o_reg_ana_reserved_reg     (o_reg_ana_reserved_reg             ),
    .o_reg_config0_t_deat_time  (o_reg_config0_t_deat_time          ),
    
    .i_test_st_reg_en           (test_st_reg_en                     ),
    .i_cfg_st_reg_en            (cfg_st_reg_en                      ),
    .i_spi_ctrl_reg_en          (spi_ctrl_reg_en                    ),
    .i_efuse_ctrl_reg_en        (efuse_ctrl_reg_en                  ),

    .i_clk                      (i_clk                              ),
    .i_hrst_n                   (i_rst_n                            ),
    .o_rst_n                    (                                   )
);

assign o_adc1_en    = reg_mode.adc1_en          ;
assign o_adc2_en    = reg_mode.adc2_en          ;
assign o_adc1_data  = reg_hv_adc1_data[9: 2]    ;
assign o_adc2_data  = reg_hv_adc2_data[9: 2]    ;
assign o_rtmon      = reg_com_config1.rtmon     ;

lv_ctrl_unit U_LV_CTRL_UNIT(
    .i_pwr_on                   (1'b1                               ),
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

    .o_pwm_en                   (o_dgt_ang_pwm_en                   ),
    .o_fsc_en                   (o_dgt_ang_fsc_en                   ),
    .o_wdg_scan_en              (wdg_scan_en                        ),
    .o_spi_en                   (fsm_spi_slv_en                     ),
    .o_owt_com_en               (wdg_owt_en                         ),
    .o_cfg_st_reg_en            (cfg_st_reg_en                      ),//when in cfg_st support reg read & write.
    .o_test_st_reg_en           (test_st_reg_en                     ),//when in test_st support reg read & write.
    .o_spi_ctrl_reg_en          (spi_ctrl_reg_en                    ),//when spi enable support reg read & write.
    .o_efuse_ctrl_reg_en        (efuse_ctrl_reg_en                  ),
    .o_bist_en                  (bist_en                            ),
    .o_fsm_ang_test_en          (o_fsm_ang_test_en                  ),//ctrl analog mdl into test mode.
    .o_aout_wait                (o_aout_wait                        ),
    .o_aout_bist                (o_aout_bist                        ),

    .i_hv_intb_n                (hv_intb_n                          ),
    .o_intb_n                   (o_intb_n                           ),

    .o_efuse_load_req           (efuse_load_req                     ),
    .i_efuse_load_done          (1'b0                               ), //hardware lanch, indicate efuse have load done.
    
    .o_fsm_wdg_owt_tx_req       (fsm_wdg_owt_tx_req                 ),
    .i_owt_rx_ack               (owt_rx_ack                         ),
    
    .o_lv_ctrl_cur_st           (lv_ctrl_cur_st                     ),

    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

lv_pwm_intb_decode U_LV_PWM_INTB_DECODE(
    .i_hv_pwm_intb_n            (i_hv_pwm_intb_n                    ),
    .o_lv_pwm_gwave             (                                   ),
    .o_hv_intb_n                (hv_intb_n                          ),
    .i_clk                      (i_clk                              ),
    .i_rst_n                    (i_rst_n                            )
);

lv_abist U_LV_ABIST(
    .i_bist_en                  (bist_en                            ),     
    .i_lv_vsup_ov               (i_lv_vsup_ov                       ),
    .o_lbist_en                 (lbist_en                           ),
    .o_lv_abist_fail            (                                   ),
    .o_bistlv_ov                (o_bistlv_ov                        ),
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

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule





























