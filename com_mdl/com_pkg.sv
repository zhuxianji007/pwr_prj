//============================================================
//Module   : com_pkg
//Function : define structure
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================

`ifndef COM_PKG_SV
`define COM_PKG_SV

package com_pkg;

    typedef struct packed{
        logic                    efuse_done                 ;
        logic                    adc2_en                    ;
        logic                    adc1_en                    ;
        logic                    fsiso_en                   ;
        logic                    bist_en                    ;
        logic                    cfg_en                     ;
        logic                    normal_en                  ;
        logic                    reset_en                   ;
    } str_reg_mode;

    typedef struct packed{
        logic                   rtmon                       ;
        logic                   comerr_mode                 ;
        logic [3:       0]      comerr_config               ;
        logic [1:       0]      wdgintb_config              ;
    } str_reg_com_config1;

    typedef struct packed{
        logic [1:       0]      hv_wdgtmo_config            ;
        logic [1:       0]      lv_wdgtmo_config            ;
        logic [1:       0]      wdgrefresh_config           ;
        logic [1:       0]      wdgcrc_config               ;
    } str_reg_com_config2;

    typedef struct packed{
        logic                   bist_fail                   ;
        logic                   rsv                         ;
        logic                   pwm_mmerr                   ;
        logic                   pwm_dterr                   ;
        logic                   wdg_err                     ;
        logic                   com_err                     ;
        logic                   crc_err                     ;
        logic                   spi_err                     ;
    } str_reg_status1;

    typedef struct packed{
        logic                   bist_failm                  ;
        logic                   rsv                         ;
        logic                   pwm_mmerrm                  ;
        logic                   pwm_dterrm                  ;
        logic                   wdg_errm                    ;
        logic                   com_errm                    ;
        logic                   crc_errm                    ;
        logic                   spi_errm                    ;
    } str_reg_mask1;

    typedef struct packed{
        logic                   hv_scp_flt                  ;
        logic                   hv_desat_flt                ;
        logic                   hv_oc                       ;
        logic                   hv_ot                       ;
        logic                   hv_vcc_ov                   ;
        logic                   hv_vcc_uv                   ;
        logic                   lv_vsup_ov                  ;
        logic                   lv_vsup_uv                  ;
    } str_reg_status2;

    typedef struct packed{
        logic                   hv_scp_fltm                 ;
        logic                   hv_desat_fltm               ;
        logic                   hv_ocm                      ;
        logic                   hv_otm                      ;
        logic                   hv_vcc_ovm                  ;
        logic                   hv_vcc_uvm                  ;
        logic                   lv_vsup_ovm                 ;
        logic                   lv_vsup_uvm                 ;
    } str_reg_mask2;

    typedef struct packed{
        logic                   vrtmon                      ;
        logic                   io_fsifo                    ;
        logic                   io_pwma                     ;
        logic                   io_pwm                      ;
        logic                   io_fsstate                  ;
        logic                   io_fsenb                    ;
        logic                   io_intb_lv                  ;
        logic                   io_intb_hv                  ;
    } str_reg_status3;

    typedef struct packed{
        logic [3:       0]      hv_state                    ;
        logic [3:       0]      lv_state                    ;        
    } str_reg_status4;

    typedef struct packed{
        logic                   efuse_mode                  ;
        logic [6:       0]      efuse_bit_addr              ;        
    } str_reg_efuse_config;

    typedef struct packed{
        logic [7:       4]      rsv                         ;
        logic [3:       3]      spi_read_efuse_en           ;
        logic [2:       2]      efuse_wr                    ;
        logic [1:       1]      efuse_rd                    ;
        logic [0:       0]      efuse_op_done               ;         
    } str_reg_efuse_status;

    typedef struct packed{
        logic [7:       6]      rsv                         ;
        logic [5:       0]      bgr_trim                    ;
    } str_reg_iso_bgr_trim;

    typedef struct packed{
        logic [7:       5]      rsv                         ;
        logic [4:       0]      corner                      ;
    } str_reg_iso_con_ibias_trim;

    typedef struct packed{
        logic [7:       5]      rsv                         ;
        logic [4:       0]      osc48m_trim                 ;
    } str_reg_iso_osc48m_trim;

    typedef struct packed{
        logic [7:       0]      iso_oscb_freq_adj           ;
    } str_reg_iso_oscb_freq_adj;

    typedef struct packed{
        logic                   efuse_vld                   ;
        logic [6:       0]      rsv                         ;
    } str_reg_iso_reserved_reg;

    typedef struct packed{
        logic [7:       6]      rsv                         ;
        logic [5:       3]      amp_ibias8u                 ;
        logic [2:       0]      amp_ibias8u_ptat            ;
    } str_reg_iso_amp_ibias;

    typedef struct packed{
        logic [7:       5]      rsv                         ;
        logic [4:       3]      demo_pulse                  ;
        logic [2:       0]      demo_vth                    ;
    } str_reg_iso_demo_trim;

    typedef struct packed{
        logic [7:       0]      rsv                         ;
    } str_reg_iso_test_sw;

    typedef struct packed{
        logic [7:       3]      rsv                         ;
        logic [2:       0]      iso_tx_jit_adj              ;
    } str_reg_iso_osc_jit;

    typedef struct packed{
        logic [7:       4]      tdt                         ;
        logic [3:       0]      vge_mon_dly                 ;
    } str_reg_config0_t_deat_time;

endpackage

`endif //COM_PKG_SV






