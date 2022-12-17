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
   input  logic                                        sclk                             ,
   input  logic                                        csb                              ,
   input  logic                                        mosi                             ,
   output logic                                        miso                             , 
   input  logic                                        s32_16                           , //1: sel 32pin logic; 0: sel 16pin logic

   output logic                                        d1d2_data                        , //o_lv_hv_owt_tx
   input  logic                                        d2d1_data                        , //i_hv_lv_owt_rx
   input  logic                                        d21_gate_back                    , //i_hv_pwm_intb_n

   input  logic                                        tm                               , //i_io_test_mode
   output logic                                        vl_pins32                        , //o_fsm_ang_test_en
   input  logic                                        setb                             , 

   input  logic                                        scan_mode                        ,

   output logic                                        intb_o                           , //o_intb_n
   output logic                                        fsc_en                           , //o_dgt_ang_pwm_en
   output logic                                        pwm_en                           , //o_dgt_ang_fsc_en

   input  logic                                        uv_vsup                          , //i_lv_vsup_uv_n
   input  logic                                        dt_flag                          , //i_lv_pwm_dt
   input  logic                                        vsup_ov                          , //i_lv_vsup_ov
   input  logic                                        gate_vs_pwm                      , //i_lv_gate_vs_pwm
   output logic                                        rtmon                            ,

   output logic                                        bistlv_ov                        ,

   output logic [7:    0]                              adc1_o                           ,
   output logic [7:    0]                              adc2_o                           ,
   output logic                                        adc1_en                          ,
   output logic                                        adc2_en                          ,
   output logic                                        aout_wait                        ,
   output logic                                        aout_bist                        ,

   input  logic                                        fsenb_i                          , //i_io_fsenb_n
   input  logic                                        fsstate_i                        , //i_io_fsstate
   input  logic                                        intb_i                           ,
   input  logic                                        inta_i                           ,
   input  logic                                        pwm_i                            ,
   input  logic                                        pwmalt_i                         ,

   input  logic                                        scl                              ,
   input  logic                                        sda_in                           ,
   output logic                                        sda_out                          ,
   output logic                                        se                               , 

   output logic                                        vl_pins16                        , 

   input  logic [1:    0]                              set_jdg                          ,
   input  logic [2:    0]                              adc_dmvt                         ,
   input  logic [2:    0]                              adc_sic                          ,
   input  logic [1:    0]                              adc_vth                          ,
   input  logic [2:    0]                              adc_soc                          , 
   output logic                                        jdg_disable                      ,

   input  logic [2:    0]                              fault_b                          ,
   output logic                                        fault_data_rst                   ,
   output logic                                        rdy_oc_rst                       , 

   output str_reg_iso_bgr_trim                         iso_bgr_trim                     ,
   output str_reg_iso_con_ibias_trim                   iso_con_ibias_trim               ,
   output str_reg_iso_osc48m_trim                      iso_osc48m_trim                  ,
   output str_reg_iso_oscb_freq_adj                    iso_oscb_freq_adj                ,
   output str_reg_iso_reserved_reg                     iso_reserved_reg                 ,
   output str_reg_iso_amp_ibias                        iso_amp_ibias                    ,
   output str_reg_iso_demo_trim                        iso_demo_trim                    ,
   output str_reg_iso_test_sw                          iso_test_sw                      ,
   output str_reg_iso_osc_jit                          iso_osc_jit                      ,
   output logic [7:    0]                              ana_reserved_reg                 ,
   output str_reg_config0_t_deat_time                  config0                          ,

   input  logic                                        clk                              ,
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
lv_core U_LV_CORE(
    .i_spi_sclk                      (sclk                      ),
    .i_spi_csb                       (csb                       ),
    .i_spi_mosi                      (mosi                      ),
    .o_spi_miso                      (miso                      ), 
    .i_s32_sel                       (s32_16                    ),

    .o_lv_hv_owt_tx                  (d1d2_data                 ),
    .i_hv_lv_owt_rx                  (d2d1_data                 ),
    .i_hv_pwm_intb_n                 (d21_gate_back             ),

    .i_io_test_mode                  (tm                        ), 
    .o_fsm_ang_test_en               (vl_pins32                 ), 
    .i_setb                          (setb                      ), 

    .i_scan_mode                     (scan_mode                 ),

    .o_intb_n                        (intb_o                    ),
    .o_dgt_ang_pwm_en                (fsc_en                    ),
    .o_dgt_ang_fsc_en                (pwm_en                    ),

    .i_lv_vsup_uv_n                  (uv_vsup                   ), 
    .i_lv_pwm_dt                     (dt_flag                   ), 
    .i_lv_vsup_ov                    (vsup_ov                   ), 
    .i_lv_gate_vs_pwm                (gate_vs_pwm               ), 
    .o_rtmon                         (rtmon                     ),

    .o_bistlv_ov                     (bistlv_ov                 ),

    .o_adc1_data                     (adc1_o                    ),
    .o_adc2_data                     (adc2_o                    ),
    .o_adc1_en                       (adc1_en                   ),
    .o_adc2_en                       (adc2_en                   ),
    .o_aout_wait                     (aout_wait                 ),
    .o_aout_bist                     (aout_bist                 ),

    .i_io_fsenb_n                    (fsenb_i                   ),
    .i_io_fsstate                    (fsstate_i                 ),
    .i_io_intb                       (intb_i                    ),
    .i_io_inta                       (inta_i                    ),
    .i_io_pwm                        (pwm_i                     ),
    .i_io_pwma                       (pwmalt_i                  ),

    .o_reg_iso_bgr_trim              (iso_bgr_trim              ),
    .o_reg_iso_con_ibias_trim        (iso_con_ibias_trim        ),
    .o_reg_iso_osc48m_trim           (iso_osc48m_trim           ),
    .o_reg_iso_oscb_freq_adj         (iso_oscb_freq_adj         ),
    .o_reg_iso_reserved_reg          (iso_reserved_reg          ),
    .o_reg_iso_amp_ibias             (iso_amp_ibias             ),
    .o_reg_iso_demo_trim             (iso_demo_trim             ),
    .o_reg_iso_test_sw               (iso_test_sw               ),
    .o_reg_iso_osc_jit               (iso_osc_jit               ),
    .o_reg_ana_reserved_reg          (ana_reserved_reg          ),
    .o_reg_config0_t_deat_time       (config0                   ),
 
    .i_clk                           (clk                       ),
    .i_rst_n                         (rst_n                     )
);
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
    
    
    
    
