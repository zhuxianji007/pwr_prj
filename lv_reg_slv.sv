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
module lv_reg_slv #(
    `include "lv_param.vh"
    parameter END_OF_LIST          = 1
)(
    //spi reg access interface 
    input  logic                    i_spi_reg_ren                   ,
    input  logic                    i_spi_reg_wen                   ,
    input  logic [REG_AW-1:   0]    i_spi_reg_addr                  ,
    input  logic [REG_DW-1:   0]    i_spi_reg_wdata                 ,
    output logic                    o_reg_spi_rack                  ,
    output logic                    o_reg_spi_rstatus               ,
    output logic [REG_DW-1:   0]    o_reg_spi_rdata                 ,
    
    //inner flop-flip data
    input  logic [REG_DW-1:   0]    i_lvhv_device_id                ,
    input  logic                    i_int_bist_fail                 ,
    input  logic                    i_int_pwm_mmerr                 ,
    input  logic                    i_int_pwm_dterr                 ,
    input  logic                    i_int_wdg_err                   ,
    input  logic                    i_int_com_err                   ,
    input  logic                    i_int_crc_err                   ,
    input  logic                    i_int_spi_err                   ,

    input logic                     i_int_hv_scp_flt                ,
    input logic                     i_int_hv_desat_flt              ,
    input logic                     i_int_hv_oc                     ,
    input logic                     i_int_hv_ot                     ,
    input logic                     i_int_hv_vcc_ov                 ,
    input logic                     i_int_hv_vcc_uv_n               ,
    input logic                     i_int_lv_vsup_ov                ,
    input logic                     i_int_lv_vsup_uv_n              ,

    input logic                     i_int_vrtmon                    ,
    input logic                     i_int_fsifo                     ,
    input logic                     i_int_pwma                      ,
    input logic                     i_int_pwm                       ,
    input logic                     i_int_fsstate                   ,
    input logic                     i_int_fsenb                     ,
    input logic                     i_int_intb_lv                   ,
    input logic                     i_int_intb_hv                   ,

    input logic [REG_DW-1:    0]    i_fsm_status                    ,   
    input logic [9:           0]    i_adc1_data                     ,
    input logic [9:           0]    i_adc2_data                     ,
    input logic [15:          0]    i_bist_rult                     ,
    input logic [REG_DW-1:    0]    i_adc_status                    ,

    //output to inner logic
    output logic                    o_mode_efuse_done               ,
    output logic                    o_mode_adc2_en                  ,
    output logic                    o_mode_adc1_en                  ,
    output logic                    o_mode_fsiso_en                 ,
    output logic                    o_mode_bist_en                  ,
    output logic                    o_mode_cfg_en                   ,
    output logic                    o_mode_normal_en                ,
    output logic                    o_mode_reset_en                 ,

    output logic                    o_com_config0_rtmon             ,
    output logic                    o_com_config0_comerr_mode       ,
    output logic [3:          0]    o_com_config0_comerr_config     ,

    output logic [1:          0]    o_com_config1_wdgintb_config    ,
    output logic [1:          0]    o_com_config1_wdgtmo_config     ,
    output logic [1:          0]    o_com_config1_wdgrefresh_config ,
    output logic [1:          0]    o_com_config1_wdgcrc_config     ,

    output logic                    o_status1_bist_fail             ,
    output logic                    o_status1_pwm_mmerr             ,
    output logic                    o_status1_pwm_dterr             ,
    output logic                    o_status1_wdg_err               ,
    output logic                    o_status1_com_err               ,
    output logic                    o_status1_crc_err               ,
    output logic                    o_status1_spi_err               ,

    output logic                    o_status1_hv_scp_flt            ,
    output logic                    o_status1_hv_desat_flt          ,
    output logic                    o_status1_hv_oc                 ,
    output logic                    o_status1_hv_ot                 ,
    output logic                    o_status1_hv_vcc_ov             ,
    output logic                    o_status1_hv_vcc_uv             ,
    output logic                    o_status1_lv_vsup_ov            ,
    output logic                    o_status1_lv_vsup_uv            ,

    output logic [5:          0]    o_bgr_code_iso_bgr_trim         ,
    output logic                    o_ibias_coe_iso_efuse_bum_com   ,
    output logic [4:          0]    o_ibias_coe_iso_corner          ,
    output logic [4:          0]    o_osc48m_osc48m_trim            ,
    output logic [7:          0]    o_iso_oscb_freq_adj             ,
    output logic [7:          0]    o_iso_reserved_reg              ,
    output logic [2:          0]    o_iso_amp_ibias_amp_ibias8u     ,
    output logic [2:          0]    o_iso_amp_ibias_amp_ibias8u_ptat,
    output logic [1:          0]    o_reg_iso_rx_demo_demo_pulse    ,
    output logic [2:          0]    o_reg_iso_rx_demo_demo_vth      ,
    output logic [7:          0]    o_iso_test_sw_reserved          ,
    output logic [3:          0]    o_iso_osc_jit_iso_tx_jit_adj    ,
    output logic [7:          0]    o_ana_reserved_reg_reserved     ,
    output logic [3:          0]    o_t_dead_time_tdt_tdt           ,
    
    //to mcu interrput
    input  logic                    i_intb_hv_n                     ,
    output logic                    o_intb_n                        ,

    input  logic                    i_test_mode_status              ,
    input  logic                    i_cfg_mode_status               ,
    input  logic                    i_clk                           ,
    input  logic                    i_hrst_n                        ,
    input  logic                    i_srst_n                        ,
    output logic                    o_rst_n                     
);
//==================================
//local param delcaration
//==================================
logic                  rst_n                    ;

logic                  spi_reg_wen              ;
logic                  spi_reg_ren              ;
logic [REG_AW-1:    0] spi_reg_addr             ;
logic [REG_DW-1:    0] spi_reg_wdata            ;
logic [REG_DW-1:    0] reg_spi_rdata            ;
logic [REG_CRC_W-1: 0] crc_data                 ;

logic [REG_DW-1:    0] status1_lgc_wen          ;
logic [REG_DW-1:    0] status2_lgc_wen          ;
logic [REG_DW-1:    0] status3_in               ;
logic                  intb_lv_n                ;

logic [REG_DW-1:    0] rdata_lvhv_device_id     ;
logic [REG_DW-1:    0] rdata_mode               ;
logic [REG_DW-1:    0] rdata_com_config0        ;
logic [REG_DW-1:    0] rdata_com_config1        ;
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
logic [REG_DW-1:    0] rdata_die1_id            ;
logic [REG_DW-1:    0] rdata_die2_id            ;
logic [REG_DW-1:    0] rdata_die3_id            ;
logic [REG_DW-1:    0] rdata_bgr_trim           ;
logic [REG_DW-1:    0] rdata_ibias_coe_iso      ;
logic [REG_DW-1:    0] rdata_osc48m             ;
logic [REG_DW-1:    0] rdata_iso_oscb_freq_adj  ;
logic [REG_DW-1:    0] rdata_iso_reserved_reg   ;
logic [REG_DW-1:    0] rdata_iso_amp_ibias      ;
logic [REG_DW-1:    0] rdata_iso_rx_demo        ;
logic [REG_DW-1:    0] rdata_iso_test_sw        ;
logic [REG_DW-1:    0] rdata_iso_osc_jit        ;
logic [REG_DW-1:    0] rdata_ana_reserved_reg   ;
logic [REG_DW-1:    0] rdata_t_dead_time        ;


logic [REG_DW-1:    0] reg_mode                 ;
logic [REG_DW-1:    0] reg_com_config0          ;
logic [REG_DW-1:    0] reg_com_config1          ;
logic [REG_DW-1:    0] reg_status1              ;
logic [REG_DW-1:    0] reg_mask1                ;
logic [REG_DW-1:    0] reg_status2              ;
logic [REG_DW-1:    0] reg_mask2                ;
logic [REG_DW-1:    0] reg_bgr_trim             ;
logic [REG_DW-1:    0] reg_ibias_coe_iso        ;
logic [REG_DW-1:    0] reg_osc48m               ;
logic [REG_DW-1:    0] reg_iso_oscb_freq_adj    ;
logic [REG_DW-1:    0] reg_iso_reserved_reg     ;
logic [REG_DW-1:    0] reg_iso_amp_ibias        ;
logic [REG_DW-1:    0] reg_iso_rx_demo          ;
logic [REG_DW-1:    0] reg_iso_test_sw          ;
logic [REG_DW-1:    0] reg_iso_osc_jit          ;
logic [REG_DW-1:    0] reg_ana_reserved_reg     ;
logic [REG_DW-1:    0] reg_t_dead_time          ;
//==================================
//var delcaration
//==================================

//==================================
//main code
//==================================
rstn_merge U_RSTN_MERGE(
    .i_hrst_n   (i_hrst_n),
    .i_srst_n   (i_srst_n),
    .o_rst_n    (rst_n   )
);
assign o_rst_n = rst_n;

gen_reg_crc U_GEN_REG_CRC(
    .data_in    (i_spi_reg_wdata    ),
    .crc_en     (i_spi_reg_wen      ),
    .crc_out    (crc_data           ),
    .rst        (rst_n              ),
    .clk        (i_clk              )
);

//instance regsister
//LVHV_DEVICE_ID REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (8'h00      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_LVHV_DEVICE_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_lvhv_device_id                             ),
    .o_rdata              (rdata_lvhv_device_id                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//MODE REGISTER
rw_reg #(
    .DW                     (7          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (7'h00      ),
    .REG_ADDR               (8'h01      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_MODE_H(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (1'b1                                         ),
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
    .REG_ADDR               (8'h01      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_MODE_L(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (1'b1                                         ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[0:0]                           ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mode[0:0]                              ),
    .o_reg_data           (reg_mode[0:0]                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (hrst_n                                       )
);

assign o_mode_efuse_done = reg_mode[7:7];
assign o_mode_adc2_en    = reg_mode[6:6];
assign o_mode_adc1_en    = reg_mode[5:5];
assign o_mode_fsiso_en   = reg_mode[4:4];
assign o_mode_bist_en    = reg_mode[3:3];
assign o_mode_cfg_en     = reg_mode[2:2];
assign o_mode_normal_en  = reg_mode[1:1];
assign o_mode_reset_en   = reg_mode[0:0];

//COM_CONFIG0 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h0A      ),
    .REG_ADDR               (8'h02      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_COM_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_com_config0                            ),
    .o_reg_data           (reg_com_config0                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_com_config_rtmon          = reg_com_config0[7:7];
assign o_com_config_comerr_mode    = reg_com_config0[6:6];
assign o_com_config_comerr_config  = reg_com_config0[3:0];

//COM_CONFIG1 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hFF      ),
    .REG_ADDR               (8'h03      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_COM_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_com_config1                            ),
    .o_reg_data           (reg_com_config1                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_com_config1_wdgintb_config    = reg_com_config1[7:6];
assign o_com_config1_wdgtmo_config     = reg_com_config1[5:4];
assign o_com_config1_wdgrefresh_config = reg_com_config1[3:2];
assign o_com_config1_wdgcrc_config     = reg_com_config1[1:0];

//STATUS1 REGISTER
assign status1_lgc_wen = {i_int_bist_fail, 1'b0, i_int_pwm_mmerr, i_int_pwm_dterr, 
                           i_int_wdg_err, i_int_com_err, i_int_crc_err, i_int_spi_err};
rwc_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h08      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_STATUS1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_status1                                ),
    .o_reg_data           (reg_status1                                  ),
    .i_lgc_wen            (status1_lgc_wen                              ),
    .i_lgc_wdata          (8'hFF                                        ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_status1_bist_fail = reg_status1[7:7];
assign o_status1_pwm_mmerr = reg_status1[5:5];
assign o_status1_pwm_dterr = reg_status1[4:4];
assign o_status1_wdg_err   = reg_status1[3:3];
assign o_status1_com_err   = reg_status1[2:2];
assign o_status1_crc_err   = reg_status1[1:1];
assign o_status1_spi_err   = reg_status1[0:0];

//MASK1 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h09      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_MASK1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mask1                                  ),
    .o_reg_data           (reg_mask1                                    ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//STATUS2 REGISTER
assign status2_lgc_wen = {i_int_hv_scp_flt, i_int_hv_desat_flt, i_int_hv_oc, i_int_hv_ot, 
                           i_int_hv_vcc_ov, i_int_hv_vcc_uv_n, i_int_lv_vsup_ov, i_int_lv_vsup_uv_n};
rwc_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h0A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_STATUS2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_status2                                ),
    .o_reg_data           (reg_status2                                  ),
    .i_lgc_wen            (status2_lgc_wen                              ),
    .i_lgc_wdata          (8'hFF                                        ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_status1_hv_scp_flt    = reg_status2[7:7];
assign o_status1_hv_desat_flt  = reg_status2[6:6];
assign o_status1_hv_oc         = reg_status2[5:5];
assign o_status1_hv_ot         = reg_status2[4:4];
assign o_status1_hv_vcc_ov     = reg_status2[3:3];
assign o_status1_hv_vcc_uv     = reg_status2[2:2];
assign o_status1_lv_vsup_ov    = reg_status2[1:1];
assign o_status1_lv_vsup_uv    = reg_status2[0:0];

//MASK2 REGISTER
rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h0B      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_MASK2(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mask2                                  ),
    .o_reg_data           (reg_mask2                                    ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

//STATUS3 REGISTER
assign status3_in = {i_int_vrtmon, i_int_fsifo, i_int_pwma, i_int_pwm
                      i_int_fsstate, i_int_fsenb, i_int_intb_lv, i_int_intb_hv};
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (8'h0C      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_STATUS3(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h0D      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_STATUS4(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_fsm_status                                 ),
    .o_rdata              (rdata_status4                                ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

 //ADC1_DATA_LOW REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (8'h10      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ADC1_DATA_LOW(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h11      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ADC1_DATA_HIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h12      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ADC2_DATA_LOW(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h13      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ADC2_DATA_HIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h14      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_BIST_RESULT1(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h15      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_BIST_RESULT2(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h1F      ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ADC_REQ(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_adc_status                                 ),
    .o_rdata              (rdata_adc_status                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

 //DIE1_ID REGISTER
rw_reg #(
    .DW                     (3          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h20      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_DIE1_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[7:5]                           ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die1_id[7:5]                           ),
    .o_reg_data           (                                             ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign rdata_die1_id[4:0] = 5'b0;

//DIE2_ID REGISTER
rw_reg #(
    .DW                     (3          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h21      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_DIE2_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[7:5]                           ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die2_id[7:5]                           ),
    .o_reg_data           (                                             ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign rdata_die2_id[4:0] = 5'b0;

//DIE3_ID REGISTER
rw_reg #(
    .DW                     (3          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h22      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_DIE3_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[7:5]                           ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_die3_id[7:5]                           ),
    .o_reg_data           (                                             ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign rdata_die3_id[4:0] = 5'b0;

//BGR_CODE_ISO REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h23      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_BGR_CODE_ISO(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_bgr_trim                               ),
    .o_reg_data           (reg_bgr_trim                                 ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_bgr_code_iso_bgr_trim = reg_bgr_trim[5:0];

//IBIAS_COE_ISO REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (8'h24      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_IBIAS_COE_ISO(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_ibias_coe_iso                          ),
    .o_reg_data           (reg_ibias_coe_iso                            ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);

assign o_ibias_coe_iso_efuse_bum_com = reg_ibias_coe_iso[7:7];
assign o_ibias_coe_iso_corner        = reg_ibias_coe_iso[4:0];

//OSC48M REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h10      ),
    .REG_ADDR               (8'h25      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_OSC48M(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_osc48m                                 ),
    .o_reg_data           (reg_osc48m                                   ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_osc48m_osc48m_trim = reg_osc48m[4:0];

//ISO_OSCB_FREQ_ADJ REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hDF      ),
    .REG_ADDR               (8'h26      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ISO_OSCB_FREQ_ADJ(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_oscb_freq_adj                      ),
    .o_reg_data           (reg_iso_oscb_freq_adj                        ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_iso_oscb_freq_adj = reg_iso_oscb_freq_adj;

//ISO_RESERVED_REG REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (8'h27      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ISO_RESERVED_REG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_iso_reserved_reg                       ),
    .o_reg_data           (reg_iso_reserved_reg                         ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
);
assign o_iso_reserved_reg = reg_iso_reserved_reg;

//ISO_AMP_IBIAS REGISTER
rw_reg #(
    .DW                     (8          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h24      ),
    .REG_ADDR               (8'h28      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ISO_AMP_IBIAS(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h29      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ISO_RX_DEMO(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h2A      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ISO_TEST_SW(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h2B      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b0       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ISO_OSC_JIT(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h2C      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_ANA_RESERVED_REG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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
    .REG_ADDR               (8'h30      ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
)U_T_DEAT_TIME(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
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

//spi reg in
always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        spi_reg_ren <= 1'b0;
        spi_reg_wen <= 1'b0;
    end
    else begin
        spi_reg_ren <= i_spi_reg_ren;
        spi_reg_wen <= i_spi_reg_wen;
    end
end

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        spi_reg_addr  <= REG_AW'(0);
        spi_reg_wdata <= REG_DW'(0);
    end
    else begin
        spi_reg_addr  <= (i_spi_reg_ren | i_spi_reg_wen) ? i_spi_reg_addr  : spi_reg_addr ;
        spi_reg_wdata <= (i_spi_reg_wen                ) ? i_spi_reg_wdata : spi_reg_wdata;
    end
end

//rdata proc zone
always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rack <= 1'b0;
    end
    else begin
        o_reg_spi_rack <= spi_reg_ren;
    end
end

assign reg_spi_rdata = rdata_lvhv_device_id | rdata_mode | rdata_com_config0 | rdata_com_config1 | rdata_status1 | rdata_mask1 | rdata_status2 | rdata_mask2
                       rdata_status3 | rdata_status4 | rdata_adc1_data_low | rdata_adc1_data_hig | rdata_adc2_data_low | rdata_adc2_data_hig |
                       rdata_bist_rult1 | rdata_bist_rult2 | rdata_adc_status | rdata_die1_id | rdata_die2_id | rdata_die3_id | rdata_bgr_trim | rdata_ibias_coe_iso |
                       rdata_osc48m | rdata_iso_oscb_freq_adj | rdata_iso_reserved_reg | rdata_iso_amp_ibias | rdata_iso_rx_demo | rdata_iso_test_sw | rdata_iso_osc_jit |
                       rdata_ana_reserved_reg | rdata_t_dead_time;

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rdata <= {REG_DW{1'b0}};
    end
    else begin
        o_reg_spi_rdata <= reg_spi_rdata;
    end
end

//interrupt proc
assign intb_lv_n = ~(|((reg_status1 & reg_mask1) | (reg_status2 & reg_mask2)));

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_intb_n <= 1'b1;
    end
    else begin
        o_intb_n <= intb_lv_n & i_intb_hv_n;
    end
end



// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

