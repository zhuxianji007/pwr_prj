//============================================================
//Module   : lv_ctrl_unit
//Function :  
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_ctrl_unit #(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_pwr_on            ,
    input  logic                            i_io_test_mode      ,
    input  logic                            i_reg_efuse_vld     ,
    input  logic                            i_reg_efuse_done    ,//soft lanch, make test_st -> wait_st
    input  logic                            i_io_fsenb_n        ,
    input  logic                            i_reg_spi_err       ,
    input  logic                            i_reg_scan_crc_err  ,
    input  logic                            i_reg_owt_com_err   ,
    input  logic                            i_reg_wdg_tmo_err   ,//tmo = timeout
    input  logic                            i_reg_lv_pwm_dterr  ,
    input  logic                            i_reg_lv_pwm_mmerr  ,
    input  logic                            i_reg_lv_vsup_uverr ,
    input  logic                            i_reg_lv_vsup_overr ,
    input  logic                            i_reg_hv_vcc_uverr  ,
    input  logic                            i_reg_hv_vcc_overr  ,
    input  logic                            i_reg_hv_ot_err     ,
    input  logic                            i_reg_hv_oc_err     ,
    input  logic                            i_reg_hv_desat_err  ,
    input  logic                            i_reg_hv_scp_err    ,

    input  logic                            i_reg_nml_en        ,
    input  logic                            i_reg_cfg_en        ,
    input  logic                            i_reg_bist_en       ,
    input  logic                            i_reg_rst_en        ,

    output logic                            o_pwm_en            ,
    output logic                            o_fsc_en            ,
    output logic                            o_wdg_scan_en       ,
    output logic                            o_spi_en            ,
    output logic                            o_owt_com_en        ,
    output logic                            o_cfg_st_reg_en     ,//when in cfg_st support reg read & write.
    output logic                            o_test_st_reg_en    ,//when in test_st support reg read & write.
    output logic                            o_spi_ctrl_reg_en   ,//when spi enable support reg read & write.
    output logic                            o_efuse_ctrl_reg_en ,//support load efuse data to reg.
    output logic                            o_bist_en           ,
    output logic                            o_fsm_ang_test_en   ,//ctrl analog mdl into test mode.
    output logic                            o_aout_wait         ,
    output logic                            o_aout_bist         ,

    input  logic                            i_hv_intb_n         ,
    output logic                            o_intb_n            ,

    output logic                            o_efuse_load_req    ,
    input  logic                            i_efuse_load_done   , //hardware lanch, indicate efuse have load done.
    
    output logic                            o_fsm_wdg_owt_tx_req,
    input  logic                            i_owt_rx_ack        ,

    output logic [CTRL_FSM_ST_W-1:      0]  o_lv_ctrl_cur_st    ,
    
    input  logic                            i_clk               ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                               lvhv_err0           ;
logic                               lvhv_err1           ;
logic                               lvhv_err2           ;
logic [CTRL_FSM_ST_W-1:         0]  lv_ctrl_cur_st      ;
logic [CTRL_FSM_ST_W-1:         0]  lv_ctrl_nxt_st      ;
logic                               effect_pwm_err      ;
logic                               fault_st_pwm_en     ;
logic                               cfg_st_intb_n_en    ;
logic                               lv_intb_n           ;
logic                               lv_pwm_mmerr        ;
//==================================
//main code
//==================================
assign lv_pwm_mmerr = i_reg_lv_pwm_mmerr & (lv_ctrl_cur_st!=FAILSAFE_ST);

assign lvhv_err0 = i_reg_lv_pwm_dterr | i_reg_lv_pwm_mmerr | i_reg_lv_vsup_uverr | i_reg_lv_vsup_overr | i_reg_hv_vcc_uverr |
                   i_reg_hv_vcc_overr | i_reg_hv_ot_err    | i_reg_hv_oc_err     | i_reg_hv_desat_err  | i_reg_hv_scp_err;
    
assign lvhv_err1 = lv_pwm_mmerr | i_reg_lv_vsup_uverr| i_reg_lv_vsup_overr | i_reg_hv_vcc_uverr  | 
                   i_reg_hv_vcc_overr | i_reg_hv_ot_err | i_reg_hv_desat_err  | i_reg_hv_scp_err;

assign lvhv_err2 = i_reg_lv_pwm_dterr | i_reg_hv_oc_err;

assign effect_pwm_err = lvhv_err1 | i_reg_owt_com_err | i_reg_wdg_tmo_err;

assign fault_st_pwm_en = (lv_ctrl_nxt_st==FAULT_ST) & ~effect_pwm_err;

assign cfg_st_intb_n_en = (lv_ctrl_nxt_st==CFG_ST) & (i_reg_owt_com_err | i_reg_wdg_tmo_err | 
                           i_reg_spi_err | i_reg_scan_crc_err | lvhv_err0);                         

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_efuse_load_req <= 1'b0;
    end
    else if(i_efuse_load_done) begin
        o_efuse_load_req <= 1'b0;
    end
    else if(~i_io_test_mode & ~i_reg_efuse_vld & (lv_ctrl_cur_st==WAIT_ST)) begin
        o_efuse_load_req <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_fsm_wdg_owt_tx_req <= 1'b0;
    end
    else if(i_owt_rx_ack) begin
        o_fsm_wdg_owt_tx_req <= 1'b0;
    end
    else if(~i_io_test_mode & i_reg_efuse_vld & (lv_ctrl_cur_st==WAIT_ST) & (i_reg_owt_com_err | i_reg_wdg_tmo_err)) begin
        o_fsm_wdg_owt_tx_req <= 1'b1;
    end
    else;
end

assign o_lv_ctrl_cur_st = lv_ctrl_cur_st;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lv_ctrl_cur_st <= PWR_DWN_ST;
    end
    else begin
        lv_ctrl_cur_st <= lv_ctrl_nxt_st;
    end
end

always_comb begin
    lv_ctrl_nxt_st = lv_ctrl_cur_st;
    case(lv_ctrl_cur_st)
        PWR_DWN_ST : begin 
            if(i_pwr_on) begin
                lv_ctrl_nxt_st = WAIT_ST;
            end
            else;
        end
        WAIT_ST : begin 
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_io_test_mode || (i_efuse_load_done & ~i_reg_efuse_vld)) begin
                lv_ctrl_nxt_st = TEST_ST; 
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err) & ~i_io_fsenb_n & i_reg_nml_en & i_reg_efuse_vld) begin
                lv_ctrl_nxt_st = FAILSAFE_ST;
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err) & i_reg_nml_en & i_reg_efuse_vld) begin
                lv_ctrl_nxt_st = NML_ST;
            end
            else;
        end
        TEST_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_reg_efuse_done & i_reg_efuse_vld) begin
                lv_ctrl_nxt_st = WAIT_ST;
            end
            else;        
        end
        NML_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_reg_cfg_en) begin
                lv_ctrl_nxt_st = CFG_ST;
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | lvhv_err1) & ~i_io_fsenb_n) begin
                lv_ctrl_nxt_st = FAILSAFE_ST;    
            end
            else if(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | lvhv_err0) begin
                lv_ctrl_nxt_st = FAULT_ST;
            end
            else;
        end
        FAILSAFE_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_reg_owt_com_err | i_reg_wdg_tmo_err | lvhv_err1) begin
                lv_ctrl_nxt_st = FAULT_ST;
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | lvhv_err1) & i_io_fsenb_n) begin
                lv_ctrl_nxt_st = NML_ST;    
            end
            else;        
        end
        FAULT_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_reg_cfg_en) begin
                lv_ctrl_nxt_st = CFG_ST;            
            end
            else if(~i_reg_owt_com_err & ~i_reg_wdg_tmo_err & ~lvhv_err1 & ~i_io_fsenb_n) begin
                lv_ctrl_nxt_st = FAILSAFE_ST;            
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | lvhv_err0) & i_io_fsenb_n) begin
                lv_ctrl_nxt_st = NML_ST;
            end
            else;
        end
        CFG_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_reg_rst_en) begin
                lv_ctrl_nxt_st = RST_ST;            
            end
            else if(~effect_pwm_err & ~i_reg_cfg_en) begin
                lv_ctrl_nxt_st = FAULT_ST;            
            end
            else if(~effect_pwm_err & ~i_reg_cfg_en & i_io_fsenb_n & i_reg_bist_en) begin
                lv_ctrl_nxt_st = BIST_ST;            
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | lvhv_err0) 
                    & ~i_io_fsenb_n & ~i_reg_cfg_en) begin
                lv_ctrl_nxt_st = FAILSAFE_ST;
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | lvhv_err0) 
                    & i_io_fsenb_n & ~i_reg_cfg_en) begin
                lv_ctrl_nxt_st = NML_ST;
            end
            else;
        end
        RST_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(~i_reg_rst_en) begin
                lv_ctrl_nxt_st = WAIT_ST;                
            end
            else;
        end
        BIST_ST : begin
            if(~i_pwr_on) begin
                lv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(~i_reg_bist_en) begin
                lv_ctrl_nxt_st = CFG_ST;                
            end
            else;
        end
        default : begin
            lv_ctrl_nxt_st = PWR_DWN_ST;    
        end
    endcase
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_pwm_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==NML_ST) begin
        o_pwm_en <= 1'b1;
    end
    else if(fault_st_pwm_en) begin
        o_pwm_en <= o_pwm_en;
    end
    else begin
        o_pwm_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_fsc_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==FAILSAFE_ST) begin
        o_fsc_en <= 1'b1;
    end
    else if(fault_st_pwm_en) begin
        o_fsc_en <= o_fsc_en;
    end
    else begin
        o_fsc_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_scan_en <= 1'b0;
    end
    else if((lv_ctrl_nxt_st==NML_ST) || (lv_ctrl_nxt_st==FAILSAFE_ST)  || (lv_ctrl_nxt_st==FAULT_ST)) begin
        o_wdg_scan_en <= 1'b1;
    end
    else begin
        o_wdg_scan_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_en <= 1'b0;
    end
    else if((lv_ctrl_nxt_st==WAIT_ST) || (lv_ctrl_nxt_st==TEST_ST) || (lv_ctrl_nxt_st==NML_ST) ||
            (lv_ctrl_nxt_st==FAILSAFE_ST) || (lv_ctrl_nxt_st==FAULT_ST) || (lv_ctrl_nxt_st==CFG_ST) ||
            (lv_ctrl_nxt_st==RST_ST) || (lv_ctrl_nxt_st==BIST_ST)) begin
        o_spi_en <= 1'b1;
    end
    else begin
        o_spi_en <= 1'b0;
    end
end

assign o_spi_ctrl_reg_en = o_spi_en;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_com_en <= 1'b0;
    end
    else if((lv_ctrl_nxt_st==WAIT_ST) || (lv_ctrl_nxt_st==TEST_ST) || (lv_ctrl_nxt_st==NML_ST) ||
            (lv_ctrl_nxt_st==FAILSAFE_ST) || (lv_ctrl_nxt_st==FAULT_ST) || (lv_ctrl_nxt_st==CFG_ST) ||
            (lv_ctrl_nxt_st==RST_ST) || (lv_ctrl_nxt_st==BIST_ST)) begin
        o_owt_com_en <= 1'b1;
    end
    else begin
        o_owt_com_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_cfg_st_reg_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==CFG_ST) begin
        o_cfg_st_reg_en <= 1'b1;
    end
    else begin
        o_cfg_st_reg_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_test_st_reg_en  <= 1'b0;
        o_fsm_ang_test_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==TEST_ST) begin
        o_test_st_reg_en  <= 1'b1;
        o_fsm_ang_test_en <= 1'b1;
    end
    else begin
        o_test_st_reg_en  <= 1'b0;
        o_fsm_ang_test_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_efuse_ctrl_reg_en  <= 1'b0;
    end
    else if((lv_ctrl_nxt_st==WAIT_ST) || (lv_ctrl_nxt_st==TEST_ST)) begin
        o_efuse_ctrl_reg_en  <= 1'b1;
    end
    else begin
        o_efuse_ctrl_reg_en  <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_bist_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==BIST_ST) begin
        o_bist_en <= 1'b1;
    end
    else begin
        o_bist_en <= 1'b0;
    end
end

always_comb begin
    if((lv_ctrl_nxt_st==PWR_DWN_ST) || (lv_ctrl_nxt_st==WAIT_ST)  || (lv_ctrl_nxt_st==FAULT_ST) ||
            cfg_st_intb_n_en || (lv_ctrl_nxt_st==RST_ST)) begin
        lv_intb_n = 1'b0;
    end
    else begin
        lv_intb_n = 1'b1;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_intb_n <= 1'b1;
    end
    else begin
        o_intb_n <= lv_intb_n | i_hv_intb_n;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_aout_wait <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==WAIT_ST) begin
        o_aout_wait <= 1'b1;
    end
    else begin
        o_aout_wait <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_aout_bist <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==BIST_ST) begin
        o_aout_bist <= 1'b1;
    end
    else begin
        o_aout_bist <= 1'b0;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule

