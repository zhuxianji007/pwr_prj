//============================================================
//Module   : lv_dgt_pwm_ctrl
//Function : lv digital pwm ctrl
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_dgt_pwm_ctrl #(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic           i_ang_dgt_pwm_wv     , //analog pwm ctrl to digtial pwm ctrl pwm wave
    input  logic           i_ang_dgt_pwm_fs     ,
    input  logic           i_fsm_dgt_pwm_en     ,
    input  logic           i_fsm_dgt_fsc_en     ,
    output logic           o_dgt_ang_pwm_en     ,
    output logic           o_dgt_ang_fsc_en     ,
    output logic           o_io_pwm_l2h         ,
   
    input  logic           i_clk                ,
    input  logic           i_rst_n
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
assign o_dgt_ang_pwm_en = i_fsm_dgt_pwm_en;
assign o_dgt_ang_fsc_en = i_fsm_dgt_fsc_en;

assign o_io_pwm_l2h = i_fsm_dgt_fsc_en ? i_ang_dgt_pwm_fs : i_ang_dgt_pwm_wv;

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

