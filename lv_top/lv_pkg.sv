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
    typedef struct packed{
        logic                    efuse_done               ;
        logic                    adc2_en                  ;
        logic                    adc1_en                  ;
        logic                    fsiso_en                 ;
        logic                    bist_en                  ;
        logic                    cfg_en                   ;
        logic                    normal_en                ;
        logic                    reset_en                 ;
    } reg_mode_str;
endpackage

`endif //LV_PKG_SV
