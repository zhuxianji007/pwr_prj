//============================================================
//Module   : lv_com_rd_reg_proc
//Function : com rd reg data proc, int mask. 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_com_rd_reg_proc #(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic [REG_DW-1:   0]    i_lv_reg_status1                ,
    input  logic [REG_DW-1:   0]    i_lv_reg_mask1                  ,
    input  logic [REG_DW-1:   0]    i_lv_reg_status2                ,
    input  logic [REG_DW-1:   0]    i_lv_reg_mask2                  ,
    input  logic [REG_DW-1:   0]    i_lv_reg_status3                ,
    input  logic [REG_DW-1:   0]    i_lv_reg_status4                ,
    input  logic [REG_DW-1:   0]    i_lv_reg_bist1                  ,
    input  logic [REG_DW-1:   0]    i_lv_reg_bist2                  ,

    input  logic [REG_DW-1:   0]    i_hv_reg_status1               ,
    input  logic [REG_DW-1:   0]    i_hv_reg_status2               ,
    input  logic [REG_DW-1:   0]    i_hv_reg_status3               ,
    input  logic [REG_DW-1:   0]    i_hv_reg_status4               ,
    input  logic [REG_DW-1:   0]    i_hv_reg_bist1                 ,
    input  logic [REG_DW-1:   0]    i_hv_reg_bist2                 ,

    output logic [REG_DW-1:     0]  o_lvhv_reg_status1              ,
    output logic [REG_DW-1:     0]  o_lvhv_reg_status2              ,
    output logic [REG_DW-1:     0]  o_lvhv_reg_status3              ,
    output logic [REG_DW-1:     0]  o_lvhv_reg_status4              ,
    output logic [REG_DW-1:     0]  o_lvhv_reg_bist1                ,
    output logic [REG_DW-1:     0]  o_lvhv_reg_bist2                ,

    output logic                    o_status1_bist_fail             ,
    output logic                    o_status1_pwm_mmerr             ,
    output logic                    o_status1_pwm_dterr             ,
    output logic                    o_status1_wdg_err               ,
    output logic                    o_status1_com_err               ,
    output logic                    o_status1_crc_err               ,
    output logic                    o_status1_spi_err               ,

    output logic                    o_status2_hv_scp_flt            ,
    output logic                    o_status2_hv_desat_flt          ,
    output logic                    o_status2_hv_oc                 ,
    output logic                    o_status2_hv_ot                 ,
    output logic                    o_status2_hv_vcc_ov             ,
    output logic                    o_status2_hv_vcc_uv             ,
    output logic                    o_status2_lv_vsup_ov            ,
    output logic                    o_status2_lv_vsup_uv            ,
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
assign o_lvhv_reg_status1 = i_lv_reg_status1 | i_hv_reg_status1 ;
assign o_lvhv_reg_status2 = i_lv_reg_status2 | i_hv_reg_status2 ;
assign o_lvhv_reg_status3 = i_lv_reg_status3 | i_hv_reg_status3 ;
assign o_lvhv_reg_status4 = i_lv_reg_status4 | i_hv_reg_status4 ;
assign o_lvhv_reg_bist1   = i_lv_reg_bist1   | i_hv_reg_bist1   ;
assign o_lvhv_reg_bist2   = i_lv_reg_bist2   | i_hv_reg_bist2   ;


 assign o_status1_bist_fail = o_lvhv_reg_status1[7:7] & ~i_lv_reg_mask1[7:7];
 assign o_status1_pwm_mmerr = o_lvhv_reg_status1[5:5] & ~i_lv_reg_mask1[5:5];
 assign o_status1_pwm_dterr = o_lvhv_reg_status1[4:4] & ~i_lv_reg_mask1[4:4];
 assign o_status1_wdg_err   = o_lvhv_reg_status1[3:3] & ~i_lv_reg_mask1[3:3];
 assign o_status1_com_err   = o_lvhv_reg_status1[2:2] & ~i_lv_reg_mask1[2:2];
 assign o_status1_crc_err   = o_lvhv_reg_status1[1:1] & ~i_lv_reg_mask1[1:1];
 assign o_status1_spi_err   = o_lvhv_reg_status1[0:0] & ~i_lv_reg_mask1[0:0];

 
assign o_status2_hv_scp_flt    = o_lvhv_reg_status2[7:7] & ~i_lv_reg_mask2[7:7];
assign o_status2_hv_desat_flt  = o_lvhv_reg_status2[6:6] & ~i_lv_reg_mask2[6:6];
assign o_status2_hv_oc         = o_lvhv_reg_status2[5:5] & ~i_lv_reg_mask2[5:5];
assign o_status2_hv_ot         = o_lvhv_reg_status2[4:4] & ~i_lv_reg_mask2[4:4];
assign o_status2_hv_vcc_ov     = o_lvhv_reg_status2[3:3] & ~i_lv_reg_mask2[3:3];
assign o_status2_hv_vcc_uv     = o_lvhv_reg_status2[2:2] & ~i_lv_reg_mask2[2:2];
assign o_status2_lv_vsup_ov    = o_lvhv_reg_status2[1:1] & ~i_lv_reg_mask2[1:1];
assign o_status2_lv_vsup_uv    = o_lvhv_reg_status2[0:0] & ~i_lv_reg_mask2[0:0];


// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule
