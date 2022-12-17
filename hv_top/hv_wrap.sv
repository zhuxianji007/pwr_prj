//============================================================
//Module   : hv_wrap
//Function : 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_wrap  import com_pkg::*; import hv_pkg::*;
(
   input  logic                                        s32_16                           , 
   input  logic                                        sclk                             ,
   input  logic                                        csb                              ,
   input  logic                                        mosi                             ,
   output logic                                        miso                             , 
   input  logic                                        ow_data                          ,

   input  logic                                        d1d2_data                        , 
   input  logic                                        d2d1_data                        ,
   output logic                                        pwmn_intb                        , 

   input  logic                                        tm                               , 
   output logic                                        vh_pins32                        , 
   input  logic                                        setb                             ,
   input  logic [3:    0]                              off_vbn_read_i                   ,
   input  logic [3:    0]                              on_vbn_read_i                    ,  
   input  logic [5:    0]                              cnt_del_i                        ,

   input  logic                                        scan_mode                        ,

   output logic                                        pwm_en                           , 

   output logic                                        fsiso_en                         , 

   input  logic                                        uv_vcc                           , 
   input  logic                                        ov_vcc                           ,
   input  logic                                        otp                              ,
   input  logic                                        desat_fault                      , 
   input  logic                                        ocp_fault                        ,
   input  logic                                        scp_fault                        ,

   output logic                                        bisthv_ov                        ,
   output logic                                        bisthv_ot                        ,
   output logic                                        bisthv_desat                     ,
   output logic                                        bisthv_oc                        ,
   output logic                                        bisthv_sc                        ,         
   output logic                                        bisthv_adc                       ,

   input  logic [9:    0]                              adc_data1                        ,
   input  logic [9:    0]                              adc_data2                        ,
   input  logic                                        adc_ready1                       ,
   input  logic                                        adc_ready2                       ,

   input  logic                                        fsiso_i                          ,
   input  logic                                        vge_vce_i                        ,
   output logic                                        rtmon                            ,


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

    input  logic                                        clk                             ,
    input  logic                                        rst_n
);
//==================================
//local param delcaration
//==================================
    
//==================================
//var delcaration
//==================================
 
//==================================        
//main code
//==================================
HV_core U_HV_CORE(

);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    
