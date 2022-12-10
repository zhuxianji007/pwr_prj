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

`ifndef LV_PKG_SV
`defien LV_PKG_SV

package lv_pkg;

    import com_pkg::*;

    typedef struct packed{
        logic [7:       6]      rsv                   ;
        logic [5:       0]      bgr_trim              ;
    } str_reg_iso_bgr_trim;

    typedef struct packed{
        logic [7:       5]      rsv                   ;
        logic [4:       0]      corner                ;
    } str_reg_iso_con_ibias_trim;

    typedef struct packed{
        logic [7:       5]      rsv                   ;
        logic [4:       0]      osc48m_trim           ;
    } str_reg_iso_osc48m_trim;

    typedef struct packed{
        logic [7:       0]      iso_oscb_freq_adj     ;
    } str_reg_iso_oscb_freq_adj;

    typedef struct packed{
        logic                   d1_efuse_vld          ;
        logic [6:       0]      rsv                   ;
    } str_reg_iso_reserved_reg;

    typedef struct packed{
        logic [7:       6]      rsv                   ;
        logic [5:       3]      amp_ibias8u           ;
        logic [2:       0]      amp_ibias8u_ptat      ;
    } str_reg_iso_amp_ibias;

    typedef struct packed{
        logic [7:       5]      rsv                   ;
        logic [4:       3]      demo_pulse            ;
        logic [2:       0]      demo_vth              ;
    } str_reg_iso_demo_trim;

    typedef struct packed{
        logic [7:       0]      rsv                   ;
    } str_reg_iso_test_sw;

    typedef struct packed{
        logic [7:       3]      rsv                   ;
        logic [2:       0]      iso_tx_jit_adj        ;
    } str_reg_iso_osc_jit;

    typedef struct packed{
        logic [7:       4]      tdt                   ;
        logic [3:       0]      vge_mon_dly           ;
    } str_reg_config0_t_deat_time;
endpackage

`endif //LV_PKG_SV
