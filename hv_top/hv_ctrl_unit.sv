//============================================================
//Module   : hv_ctrl_unit
//Function :  
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_ctrl_unit #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_pwr_on            ,
    input  logic                            i_io_test_mode      ,
    input  logic                            i_reg_efuse_vld     ,
    input  logic                            i_reg_efuse_done    ,//soft lanch, make test_st -> wait_st
    input  logic                            i_io_fsiso          ,
    input  logic                            i_fsiso_en          ,
    input  logic                            i_reg_spi_err       ,
    input  logic                            i_reg_scan_crc_err  ,
    input  logic                            i_reg_owt_com_err   ,
    input  logic                            i_reg_wdg_tmo_err   ,//tmo = timeout
    input  logic                            i_bist_fail_n       ,
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
    output logic                            o_fsiso_en          ,
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

    output logic                            o_intb_n            ,

    output logic                            o_efuse_load_req    ,
    input  logic                            i_efuse_load_done   , //hardware lanch, indicate efuse have load done.
    
    output logic [CTRL_FSM_ST_W-1:      0]  o_hv_ctrl_cur_st    ,
    
    input  logic                            i_clk               ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                               hv_err0             ;
logic                               hv_err1             ;
logic                               hv_err2             ;
logic [CTRL_FSM_ST_W-1:         0]  hv_ctrl_cur_st      ;
logic [CTRL_FSM_ST_W-1:         0]  hv_ctrl_nxt_st      ;
logic                               effect_pwm_err      ;
logic                               fault_st_pwm_en     ;
logic                               cfg_st_intb_n_en    ;
logic                               lv_intb_n           ;
logic                               fsiso_en            ;
//==================================
//main code
//==================================
assign fsifo_en = i_io_fsiso & i_fsiso_en;

assign o_fsiso_en = i_fsiso_en;

assign hv_err0 = i_reg_hv_vcc_uverr | i_reg_hv_vcc_overr | i_reg_hv_ot_err |
                 i_reg_hv_oc_err    | i_reg_hv_desat_err | i_reg_hv_scp_err;
    
assign hv_err1 = i_reg_hv_vcc_uverr | i_reg_hv_vcc_overr | i_reg_hv_ot_err |
                 i_reg_hv_desat_err | i_reg_hv_scp_err;

assign hv_err2 = i_reg_hv_oc_err;

assign effect_pwm_err = hv_err1 | i_reg_owt_com_err | i_reg_wdg_tmo_err;

assign fault_st_pwm_en = (hv_ctrl_nxt_st==FAULT_ST) & ~effect_pwm_err;

assign cfg_st_intb_n_en = (hv_ctrl_nxt_st==CFG_ST) & (i_reg_owt_com_err | i_reg_wdg_tmo_err | 
                           i_reg_spi_err | i_reg_scan_crc_err | hv_err0 | ~i_bist_fail_n);                         

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_efuse_load_req <= 1'b0;
    end
    else if(i_efuse_load_done) begin
        o_efuse_load_req <= 1'b0;
    end
    else if(~i_io_test_mode & ~i_reg_efuse_vld & (hv_ctrl_cur_st==WAIT_ST)) begin
        o_efuse_load_req <= 1'b1;
    end
    else;
end

assign o_hv_ctrl_cur_st = hv_ctrl_cur_st;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        hv_ctrl_cur_st <= PWR_DWN_ST;
    end
    else begin
        hv_ctrl_cur_st <= hv_ctrl_nxt_st;
    end
end

always_comb begin
    hv_ctrl_nxt_st = hv_ctrl_cur_st;
    case(hv_ctrl_cur_st)
        PWR_DWN_ST : begin 
            if(i_pwr_on) begin
                hv_ctrl_nxt_st = WAIT_ST;
            end
            else;
        end
        WAIT_ST : begin 
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;
            end
            else if(i_io_test_mode || (i_efuse_load_done & ~i_reg_efuse_vld)) begin
                hv_ctrl_nxt_st = TEST_ST; 
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err) & i_reg_nml_en & i_reg_efuse_vld) begin
                hv_ctrl_nxt_st = NML_ST;
            end
            else;
        end
        TEST_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;
            end            
            else if(i_reg_efuse_done & i_reg_efuse_vld) begin
                hv_ctrl_nxt_st = WAIT_ST;
            end
            else;        
        end
        NML_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
              else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;
            end 
            else if(i_reg_cfg_en) begin
                hv_ctrl_nxt_st = CFG_ST;
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | hv_err1)) begin
                hv_ctrl_nxt_st = FSISO_ST;    
            end
            else if(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | hv_err0) begin
                hv_ctrl_nxt_st = FAULT_ST;
            end
            else;
        end
        FSISO_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(i_reg_owt_com_err | i_reg_wdg_tmo_err | hv_err1) begin
                hv_ctrl_nxt_st = FAULT_ST;
            end
            else if(~fsifo_en) begin
                hv_ctrl_nxt_st = WAIT_ST;    
            end
            else;        
        end
        FAULT_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;            
            end            
            else if(i_reg_cfg_en) begin
                hv_ctrl_nxt_st = CFG_ST;            
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | hv_err0)) begin
                hv_ctrl_nxt_st = NML_ST;
            end
            else;
        end
        CFG_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;
            end            
            else if(i_reg_rst_en) begin
                hv_ctrl_nxt_st = RST_ST;            
            end
            else if(~effect_pwm_err & ~i_reg_cfg_en) begin
                hv_ctrl_nxt_st = FAULT_ST;            
            end
            else if(~effect_pwm_err & ~i_reg_cfg_en & i_reg_bist_en) begin
                hv_ctrl_nxt_st = BIST_ST;            
            end
            else if(~(i_reg_owt_com_err | i_reg_wdg_tmo_err | i_reg_spi_err | i_reg_scan_crc_err | hv_err0) 
                    & ~i_reg_cfg_en) begin
                hv_ctrl_nxt_st = NML_ST;
            end
            else;
        end
        RST_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;
            end            
            else if(~i_reg_rst_en) begin
                hv_ctrl_nxt_st = WAIT_ST;                
            end
            else;
        end
        BIST_ST : begin
            if(~i_pwr_on) begin
                hv_ctrl_nxt_st = PWR_DWN_ST;
            end
            else if(fsifo_en) begin
                hv_ctrl_nxt_st = FSISO_ST;
            end
            else if(i_reg_cfg_en) begin
                hv_ctrl_nxt_st = CFG_ST;
            end            
            else if(~i_reg_bist_en) begin
                hv_ctrl_nxt_st = CFG_ST;                
            end
            else;
        end
        default : begin
            hv_ctrl_nxt_st = PWR_DWN_ST;    
        end
    endcase
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_pwm_en <= 1'b0;
    end
    else if((hv_ctrl_nxt_st==NML_ST) || fault_st_pwm_en) begin
        o_pwm_en <= 1'b1;
    end
    else begin
        o_pwm_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_scan_en <= 1'b0;
    end
    else if((hv_ctrl_nxt_st==NML_ST) || (hv_ctrl_nxt_st==FAULT_ST)) begin
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
    else if((hv_ctrl_nxt_st==WAIT_ST) || (hv_ctrl_nxt_st==TEST_ST) || (hv_ctrl_nxt_st==NML_ST) ||
            (hv_ctrl_nxt_st==FSISO_ST) || (hv_ctrl_nxt_st==FAULT_ST) || (hv_ctrl_nxt_st==CFG_ST) ||
            (hv_ctrl_nxt_st==RST_ST) || (hv_ctrl_nxt_st==BIST_ST)) begin
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
    else if((hv_ctrl_nxt_st==WAIT_ST) || (hv_ctrl_nxt_st==TEST_ST) || (hv_ctrl_nxt_st==NML_ST) ||
            (hv_ctrl_nxt_st==FSISO_ST) || (hv_ctrl_nxt_st==FAULT_ST) || (hv_ctrl_nxt_st==CFG_ST) ||
            (hv_ctrl_nxt_st==RST_ST) || (hv_ctrl_nxt_st==BIST_ST)) begin
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
    else if(hv_ctrl_nxt_st==CFG_ST) begin
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
    else if(hv_ctrl_nxt_st==TEST_ST) begin
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
    else if((hv_ctrl_nxt_st==WAIT_ST) || (hv_ctrl_nxt_st==TEST_ST)) begin
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
    else if(hv_ctrl_nxt_st==BIST_ST) begin
        o_bist_en <= 1'b1;
    end
    else begin
        o_bist_en <= 1'b0;
    end
end

always_comb begin
    if((hv_ctrl_nxt_st==PWR_DWN_ST) || (hv_ctrl_nxt_st==WAIT_ST)  || (hv_ctrl_nxt_st==FSISO_ST) ||
        (hv_ctrl_nxt_st==FAULT_ST) || cfg_st_intb_n_en || (hv_ctrl_nxt_st==RST_ST)) begin
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
        o_intb_n <= lv_intb_n;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_aout_wait <= 1'b0;
    end
    else if(hv_ctrl_nxt_st==WAIT_ST) begin
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
    else if(hv_ctrl_nxt_st==BIST_ST) begin
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



