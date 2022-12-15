//============================================================
//Module   : lv_wrap
//Function : 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_wrap  import com_pkg::*; import lv_pkg::*;
( 
   input  logic                                        i_sclk                          ,
   input  logic                                        i_csb                           ,
   input  logic                                        i_mosi                          ,
   output logic                                        o_miso                          , 
   input  logic                                        i_s32_16                        , //1: sel 32pin logic; 0: sel 16pin logic

   output logic                                        o_d1d2_data                     , //o_lv_hv_owt_tx
   input  logic                                        i_d2d1_data                     , //i_hv_lv_owt_rx
   input  logic                                        i_d21_gate_back                 , //i_hv_pwm_intb_n

   input  logic                                        i_tm                            , //i_io_test_mode
   output logic                                        o_vl_pins32                     , //o_fsm_ang_test_en
   input  logic                                        i_setb                          , 

   input  logic                                        i_scan_mode                     ,

   output logic                                        o_intb                          , //o_intb_n
   output logic                                        o_fsc_en                        , //o_dgt_ang_pwm_en
   output logic                                        o_pwm_en                        , //o_dgt_ang_fsc_en

   input  logic                                        i_uv_vsup                       , //i_lv_vsup_uv_n
   input  logic                                        i_dt_flag                       , //i_lv_pwm_dt
   input  logic                                        i_vsup_ov                       , //i_lv_vsup_ov
   input  logic                                        i_gate_vs_pwm                   , //i_lv_gate_vs_pwm
   output logic                                        o_rtmon                         ,

   output logic                                        o_bistlv_ov                     ,

   output logic [7:    0]                              o_adc1_data                     ,
   output logic [7:    0]                              o_adc2_data                     ,
   output logic                                        o_adc1_en                       ,
   output logic                                        o_adc2_en                       ,
   output logic                                        o_aout_wait                     ,
   output logic                                        o_aout_bist                     ,

   input  logic                                        i_fsenb                         , //i_io_fsenb_n
   input  logic                                        i_fsstate                       , //i_io_fsstate
   input  logic                                        i_intb                          ,
   input  logic                                        i_inta                          ,
   input  logic                                        i_pwm                           ,
   input  logic                                        i_pwmalt                        ,

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

   input  logic                                        i_clk                           ,
   input  logic                                        i_rst_n
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
lv_core U_LV_CORE(
    .i_spi_sclk                      (i_sclk                    ),
    .i_spi_csb                       (i_csb                     ),
    .i_spi_mosi                      (i_mosi                    ),
    .o_spi_miso                      (o_miso                    ), 
    .i_s32_sel                       (i_s32_16                  ),

    .o_lv_hv_owt_tx                  (o_d1d2_data               ),
    .i_hv_lv_owt_rx                  (i_d2d1_data               ),
    .i_hv_pwm_intb_n                 (i_d21_gate_back           ),

    .i_io_test_mode                  (i_tm                      ), 
    .o_fsm_ang_test_en               (o_vl_pins32               ), 
    .i_setb                          (i_setb                    ), 

    .i_scan_mode                     (i_scan_mode               ),

    .o_intb_n                        (o_intb                    ),
    .o_dgt_ang_pwm_en                (o_fsc_en                  ),
    .o_dgt_ang_fsc_en                (o_pwm_en                  ),

    .i_lv_vsup_uv_n                  (i_uv_vsup                 ), 
    .i_lv_pwm_dt                     (i_dt_flag                 ), 
    .i_lv_vsup_ov                    (i_vsup_ov                 ), 
    .i_lv_gate_vs_pwm                (i_gate_vs_pwm             ), 
    .o_rtmon                         (o_rtmon                   ),

    .o_bistlv_ov                     (o_bistlv_ov               ),

    .o_adc1_data                     (o_adc1_data               ),
    .o_adc2_data                     (o_adc2_data               ),
    .o_adc1_en                       (o_adc1_en                 ),
    .o_adc2_en                       (o_adc2_en                 ),
    .o_aout_wait                     (o_aout_wait               ),
    .o_aout_bist                     (o_aout_bist               ),

    .i_io_fsenb_n                    (i_fsenb                   ),
    .i_io_fsstate                    (i_fsstate                 ),
    .i_io_intb                       (i_intb                    ),
    .i_io_inta                       (i_inta                    ),
    .i_io_pwm                        (i_pwm                     ),
    .i_io_pwma                       (i_pwmalt                  ),

    .o_reg_iso_bgr_trim              (o_reg_iso_bgr_trim        ),
    .o_reg_iso_con_ibias_trim        (o_reg_iso_con_ibias_trim  ),
    .o_reg_iso_osc48m_trim           (o_reg_iso_osc48m_trim     ),
    .o_reg_iso_oscb_freq_adj         (o_reg_iso_oscb_freq_adj   ),
    .o_reg_iso_reserved_reg          (o_reg_iso_reserved_reg    ),
    .o_reg_iso_amp_ibias             (o_reg_iso_amp_ibias       ),
    .o_reg_iso_demo_trim             (o_reg_iso_demo_trim       ),
    .o_reg_iso_test_sw               (o_reg_iso_test_sw         ),
    .o_reg_iso_osc_jit               (o_reg_iso_osc_jit         ),
    .o_reg_ana_reserved_reg          (o_reg_ana_reserved_reg    ),
    .o_reg_config0_t_deat_time       (o_reg_config0_t_deat_time ),
 
    .i_clk                           (i_clk                     ),
    .i_rst_n                         (i_rst_n                   )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    
