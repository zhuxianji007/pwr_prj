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
   output logic                                        d2d1_data                        ,
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


    output str_reg_iso_bgr_trim                         iso_bgr_trim                ,
    output str_reg_iso_con_ibias_trim                   iso_con_ibias_trim          ,
    output str_reg_iso_osc48m_trim                      iso_osc48m_trim             ,
    output str_reg_iso_oscb_freq_adj                    iso_oscb_freq_adj           ,
    output str_reg_iso_reserved_reg                     iso_reserved_reg            ,
    output str_reg_iso_amp_ibias                        iso_amp_ibias               ,
    output str_reg_iso_demo_trim                        iso_demo_trim               ,
    output str_reg_iso_test_sw                          iso_test_sw                 ,
    output str_reg_iso_osc_jit                          iso_osc_jit                 ,
    output logic [7:      0]                            ana_reserved_reg            ,
    output logic [7:      0]                            ana_reserved_reg2           ,
    output str_reg_config1_dr_src_snk_both              config1                     ,
    output str_reg_config2_dr_src_sel                   config2                     ,
    output str_reg_config3_dri_snk_sel                  config3                     ,
    output str_reg_config4_tltoff_sel1                  config4                     ,
    output str_reg_config5_tltoff_sel2                  config5                     ,
    output str_reg_config6_desat_sel1                   config6                     ,
    output str_reg_config7_desat_sel2                   config7                     ,
    output str_reg_config8_oc_sel                       config8                     ,
    output str_reg_config9_sc_sel                       config9                     ,
    output str_reg_config10_dvdt_ref_src                config10                    ,
    output str_reg_config11_dvdt_ref_sink               config11                    ,
    output str_reg_config12_adc_en                      config12                    ,
    output str_reg_bgr_code_drv                         bgr_code_drv                ,
    output str_reg_cap_trim_code                        cap_trim_code               ,     
    output str_reg_csdel_cmp                            csdel_cmp                   , 
    output str_reg_dvdt_value_adj                       dvdt_value_adj              , 
    output str_reg_adc_adj1                             adc_adj1                    , 
    output str_reg_adc_adj2                             adc_adj2                    , 
    output str_reg_ibias_code_drv                       ibias_code_drv              ,
    output str_reg_dvdt_tm                              dvdt_tm                     ,  
    output str_reg_dvdt_win_value_en                    dvdt_win_value_en           , 
    output str_reg_preset_delay                         preset_delay                , 
    output str_reg_drive_delay_set                      drive_delay_set             ,
    output str_reg_cmp_del                              cmp_del                     ,
    output str_reg_test_mux                             test_mux                    , 
    output str_reg_cmp_adj_vreg                         cmp_adj_vreg                ,

    input  logic                                        clk                         ,
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
hv_core U_HV_CORE(
    .i_spi_sclk                      (sclk              ),
    .i_spi_csb                       (csb               ),
    .i_spi_mosi                      (mosi              ),
    .o_spi_miso                      (miso              ), 

    .o_hv_lv_owt_tx                  (d2d1_data         ),
    .i_lv_hv_owt_rx                  (d1d2_data         ),

    .i_io_test_mode                  (tm                ),
    .o_fsm_ang_test_en               (vh_pins32         ),
    .i_hv_vcc_uv                     (uv_vcc            ),
    .i_hv_vcc_ov                     (ov_vcc            ),
    .i_hv_ot                         (otp               ),
    .i_hv_oc                         (ocp_fault         ),
    .i_hv_desat_flt                  (desat_fault       ),
    .i_hv_scp_flt                    (scp_fault         ),

    .i_vge_vce                       (vge_vce_i         ),
    .i_io_fsiso                      (fsiso_i           ),
    .i_io_pwma                       (1'b0              ),
    .i_io_pwm                        (1'b0              ),
    .i_io_fsstate                    (1'b0              ),
    .i_io_fsenb_n                    (1'b0              ),
    .i_io_intb                       (1'b1              ),
    .i_io_inta                       (1'b1              ),

    .o_bist_hv_ov                    (bisthv_ov         ),
    .o_bist_hv_ot                    (bisthv_ot         ),
    .o_bist_hv_opscod                (bisthv_desat      ),
    .o_bist_hv_oc                    (bisthv_oc         ),
    .o_bist_hv_sc                    (bisthv_sc         ),
    .o_bist_hv_adc                   (bisthv_adc        ),

    .i_cnt_del_read                  (cnt_del_i         ),
    .i_off_vbn_read                  (off_vbn_read_i    ),
    .i_on_vbn_read                   (on_vbn_read_i     ),

    .i_adc_data1                     (adc_data1         ),
    .i_adc_data2                     (adc_data2         ),
    .i_adc_ready1                    (adc_ready1        ),
    .i_adc_ready2                    (adc_ready2        ),

    .i_ang_dgt_pwm_wv                (1'b0              ), //analog pwm ctrl to digtial pwm ctrl pwm wave
    .i_ang_dgt_pwm_fs                (1'b0              ),

    .o_dgt_ang_pwm_en                (                  ),
    .o_dgt_ang_fsc_en                (                  ),

    .o_pwmn_intb                     (pwmn_intb         ),

    .o_reg_iso_bgr_trim              (iso_bgr_trim      ),
    .o_reg_iso_con_ibias_trim        (iso_con_ibias_trim),
    .o_reg_iso_osc48m_trim           (iso_osc48m_trim   ),
    .o_reg_iso_oscb_freq_adj         (iso_oscb_freq_adj ),
    .o_reg_iso_reserved_reg          (iso_reserved_reg  ),
    .o_reg_iso_amp_ibias             (iso_amp_ibias     ),
    .o_reg_iso_demo_trim             (iso_demo_trim     ),
    .o_reg_iso_test_sw               (iso_test_sw       ),
    .o_reg_iso_osc_jit               (iso_osc_jit       ),
    .o_reg_ana_reserved_reg          (ana_reserved_reg  ),
    .o_reg_ana_reserved_reg2         (ana_reserved_reg2 ),
    .o_reg_config1_dr_src_snk_both   (config1           ),
    .o_reg_config2_dr_src_sel        (config2           ),
    .o_reg_config3_dri_snk_sel       (config3           ),
    .o_reg_config4_tltoff_sel1       (config4           ),
    .o_reg_config5_tltoff_sel2       (config5           ),
    .o_reg_config6_desat_sel1        (config6           ),
    .o_reg_config7_desat_sel2        (config7           ),
    .o_reg_config8_oc_sel            (config8           ),
    .o_reg_config9_sc_sel            (config9           ),
    .o_reg_config10_dvdt_ref_src     (config10          ),
    .o_reg_config11_dvdt_ref_sink    (config11          ),
    .o_reg_config12_adc_en           (config12          ),
    .o_reg_bgr_code_drv              (bgr_code_drv      ),
    .o_reg_cap_trim_code             (cap_trim_code     ),     
    .o_reg_csdel_cmp                 (csdel_cmp         ), 
    .o_reg_dvdt_value_adj            (dvdt_value_adj    ), 
    .o_reg_adc_adj1                  (adc_adj1          ), 
    .o_reg_adc_adj2                  (adc_adj2          ), 
    .o_reg_ibias_code_drv            (ibias_code_drv    ),
    .o_reg_dvdt_tm                   (dvdt_tm           ),  
    .o_reg_dvdt_win_value_en         (dvdt_win_value_en ), 
    .o_reg_preset_delay              (preset_delay      ), 
    .o_reg_drive_delay_set           (drive_delay_set   ),
    .o_reg_cmp_del                   (cmp_del           ),
    .o_reg_test_mux                  (test_mux          ), 
    .o_reg_cmp_adj_vreg              (cmp_adj_vreg      ),

    .i_clk                           (clk               ),
    .i_rst_n                         (rst_n             )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    

    
    
    
    
