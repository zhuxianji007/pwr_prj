//============================================================
//Module   : hv_pkg
//Function : define structure
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================

`ifndef HV_PKG_SV
`define HV_PKG_SV

package hv_pkg;

    import com_pkg::*;

    typedef struct packed{
        logic                   mulit_en_dig          ;
        logic                   sen_on_fb_en          ;
        logic                   sen_off_fb_en         ;
        logic [4:       3]      if1_ir1_sel           ;
        logic                   ana_dig_16p           ;
        logic [1:       0]      fcdly_sel             ;                
    } str_reg_config1_dr_src_snk_both; 

    typedef struct packed{
        logic [7:       5]      ir2_sel               ;
        logic [4:       3]      vr1_sel               ;
        logic                   src_flt_sel           ;
        logic [1:       0]      snk_vth_sel           ;                
    } str_reg_config2_dr_src_sel;

    typedef struct packed{
        logic [7:       5]      if3_sel               ;
        logic [4:       3]      snk_flt_sel           ;
        logic [2:       1]      iflp5_sel             ;
        logic                   rsv                   ;                        
    } str_reg_config3_dri_snk_sel;

    typedef struct packed{
        logic                   tlt_sof_sel           ;        
        logic [6:       4]      v_tltoff              ;
        logic [3:       2]      t_tltoff              ;
        logic [1:       0]      rsv                   ;                       
    } str_reg_config4_tltoff_sel1;    

    typedef struct packed{       
        logic [7:       4]      i_tltoff1             ;
        logic [3:       0]      i_tltoff2             ;                     
    } str_reg_config5_tltoff_sel2; 

    typedef struct packed{ 
        logic                   desat_dig_en          ;
        logic                   vcedet_dig_en         ;      
        logic [5:       3]      desat_vref_sel        ;
        logic [2:       0]      desat_blanking        ;                     
    } str_reg_config6_desat_sel1; 

    typedef struct packed{       
        logic [7:       5]      desat_deglitch_sel    ;
        logic [4:       3]      idesat_sel            ;   
        logic [2:       0]      vreg_ldo_trim         ;                          
    } str_reg_config7_desat_sel2;

    typedef struct packed{       
        logic                   ocp_dig_en            ;
        logic [6:       4]      ocp_deglitch_sel      ;   
        logic [3:       1]      vocp_sel              ;
        logic                   rsv                   ;                          
    } str_reg_config8_oc_sel;

    typedef struct packed{       
        logic                   scp_dig_en            ;
        logic [6:       4]      scp_deglitch_sel      ;   
        logic [3:       1]      vscth_sel             ;
        logic                   rsv                   ;                          
    } str_reg_config9_sc_sel;

    typedef struct packed{       
        logic [7:       3]      rsv                   ;   
        logic [2:       0]      dvdt_ref_src          ;                         
    } str_reg_config10_dvdt_ref_src;

    typedef struct packed{       
        logic [7:       3]      rsv                   ;   
        logic [2:       0]      dvdt_ref_sink         ;                         
    } str_reg_config11_dvdt_ref_sink;

    typedef struct packed{       
        logic [7:       2]      rsv                   ;   
        logic                   adc2_en               ; 
        logic                   adc1_en               ;                        
    } str_reg_config12_adc_en;

    typedef struct packed{       
        logic [7:       6]      rsv                   ;   
        logic [5:       0]      bgr_trim              ;                        
    } str_reg_bgr_code_drv;

    typedef struct packed{       
        logic [7:       4]      off_vbn               ;   
        logic [3:       0]      on_vbn                ;                        
    } str_reg_cap_trim_code;   

    typedef struct packed{       
        logic [7:       4]      del_trim              ;   
        logic [3:       0]      rsv                   ;                        
    } str_reg_csdel_cmp;       

    typedef struct packed{       
        logic [7:       4]      dvdt_value_adj_off    ;   
        logic [3:       0]      dvdt_value_adj_on     ;                        
    } str_reg_dvdt_value_adj;

    typedef struct packed{       
        logic [7:       4]      adc_vadj              ;   
        logic [3:       0]      adc_radj              ;                        
    } str_reg_adc_adj1; 

    typedef struct packed{       
        logic [7:       4]      rsv                   ;   
        logic [3:       0]      adc2_iadj             ;                        
    } str_reg_adc_adj2;       

    typedef struct packed{ 
        logic                   d2_efuse_vld          ;      
        logic [6:       5]      rsv                   ;   
        logic [4:       0]      corner                ;                        
    } str_reg_ibias_code_drv;     

    typedef struct packed{  
        logic [7:       0]      cap_read_en           ;                        
    } str_reg_dvdt_tm;  

    typedef struct packed{ 
        logic [7:       6]      rsv                   ;         
        logic [5:       0]      cnt_del_read          ;                        
    } str_reg_cnt_del_read;  

    typedef struct packed{ 
        logic [7:       6]      dvdt_en               ;
        logic                   dvdt_delay_match_en   ;
        logic [4:       3]      rsv_0                 ;
        logic                   csd_en                ;
        logic                   cap_code_sel          ;
        logic                   rsv_1                 ;                                         
    } str_reg_dvdt_win_value_en;

    typedef struct packed{ 
        logic [7:       4]      dvdt_delay_set_off    ;
        logic [3:       0]      dvdt_delay_set_on     ;                                         
    } str_reg_preset_delay;

    typedef struct packed{ 
        logic [7:       0]      drive_delay_set       ;                                        
    } str_reg_drive_delay_set;

    typedef struct packed{ 
        logic [7:       0]      cmp_del               ;                                        
    } str_reg_cmp_del;

    typedef struct packed{ 
        logic                   rsv                   ;
        logic                   test_en_48m           ;
        logic                   digtest_en            ;
        logic [4:       0]      test_mux              ;                                        
    } str_reg_test_mux;

    typedef struct packed{ 
        logic [7:       2]      rsv                   ; 
        logic [1:       0]      cmp_adj               ;                                        
    } str_reg_cmp_adj_vreg;
endpackage

`endif //HV_PKG_SV







