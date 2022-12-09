//============================================================
//Module   : lv_pkg
//Function : define structure
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================

`ifndef COM_PKG_SV
`defien COM_PKG_SV

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

endpackage

`endif //COM_PKG_SV
