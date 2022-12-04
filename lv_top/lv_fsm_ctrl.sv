//============================================================
//Module   : lv_fsm_ctrl
//Function :  
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_fsm_ctrl #(
    `include "lv_param.vh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_pwr_on            ,
    input  logic                            i_test_mode         ,
    input  logic                            i_efuse_vld         ,
    input  logic                            i_efuse_done        ,
    input  logic                            i_fsenb_n           ,
    input  logic                            i_owt_com_err       ,
    input  logic                            i_wdg_tmo_err       ,//tmo = timeout
    input  logic                            i_spi_err           ,
    input  logic                            i_scan_crc_err      ,
    input  logic                            i_lv_pwm_dterr      ,
    input  logic                            i_lv_pwm_mmerr      ,
    input  logic                            i_lv_vsup_uverr     ,
    input  logic                            i_lv_vsup_overr     ,
    input  logic                            i_hv_vcc_uverr      ,
    input  logic                            i_hv_vcc_overr      ,
    input  logic                            i_hv_ot_err         ,
    input  logic                            i_hv_oc_err         ,
    input  logic                            i_hv_desat_err      ,
    input  logic                            i_hv_scp_err        ,

    input  logic                            i_reg_nml_en        ,
    input  logic                            i_reg_cfg_en        ,
    input  logic                            i_reg_bist_en       ,
    input  logic                            i_reg_rst_en        ,

    output logic                            o_pwm_en            ,
    output logic                            o_wdg_scan_en       ,
    output logic                            o_wdg_owt_en        ,
    output logic                            o_spi_en            ,
    output logic                            o_fsc_en            ,
    output logic                            o_owt_com_en        ,
    output logic                            o_cfg_crc_reg_en    ,
    output logic                            o_bist_en           ,

    output logic                            o_intb_n            ,

    output logic                            o_efuse_load_req    ,
    input  logic                            i_efuse_load_done   ,
    
    input  logic                            i_clk               ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam PWR_DWN_ST   = CTRL_FSM_ST_W'(0);
localparam WAIT_ST      = CTRL_FSM_ST_W'(1);
localparam TEST_ST      = CTRL_FSM_ST_W'(2);
localparam NML_ST       = CTRL_FSM_ST_W'(3);
localparam FAILSAFE_ST  = CTRL_FSM_ST_W'(4);
localparam FAULT_ST     = CTRL_FSM_ST_W'(5);
localparam CFG_ST       = CTRL_FSM_ST_W'(6);
localparam RST_ST       = CTRL_FSM_ST_W'(7);
localparam BIST_ST      = CTRL_FSM_ST_W'(8);
//==================================
//var delcaration
//==================================
logic                               lvhv_err0           ;
logic                               lvhv_err1           ;
logic                               lvhv_err2           ;
logic [CTRL_FSM_ST_W-1:         0]  lv_ctrl_cur_st      ;
logic [CTRL_FSM_ST_W-1:         0]  lv_ctrl_nxt_st      ;


//==================================
//main code
//==================================
assign lvhv_err0 = i_lv_pwm_dterr | i_lv_pwm_mmerr | i_lv_vsup_uverr | i_lv_vsup_overr | i_hv_vcc_uverr |
                   i_hv_vcc_overr | i_hv_ot_err    | i_hv_oc_err     | i_hv_desat_err  | i_hv_scp_err;
    
assign lvhv_err1 = i_lv_pwm_mmerr | i_lv_vsup_uverr| i_lv_vsup_overr | i_hv_vcc_uverr  | 
                   i_hv_vcc_overr | i_hv_ot_err    | i_hv_desat_err  | i_hv_scp_err;

assign lvhv_err2 = i_lv_pwm_dterr | i_hv_oc_err;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lv_ctrl_cur_st <= PWR_DWN_ST;
    end
    else begin
        lv_ctrl_cur_st <= lv_ctrl_nxt_st;
    end
end

always_comb begin
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
    else if(lv_ctrl_nxt_st==) begin
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
    else if(lv_ctrl_nxt_st==) begin
        o_wdg_scan_en <= 1'b1;
    end
    else begin
        o_wdg_scan_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_owt_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==) begin
        o_wdg_owt_en <= 1'b1;
    end
    else begin
        o_wdg_owt_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_en <= 1'b0;
    end
    else if((lv_ctrl_nxt_st==WAIT_ST)) begin
        o_spi_en <= 1'b1;
    end
    else begin
        o_spi_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_fsc_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==) begin
        o_fsc_en <= 1'b1;
    end
    else begin
        o_fsc_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_com_en <= 1'b0;
    end
    else if((lv_ctrl_nxt_st==WAIT_ST)) begin
        o_owt_com_en <= 1'b1;
    end
    else begin
        o_owt_com_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_cfg_crc_reg_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==) begin
        o_cfg_crc_reg_en <= 1'b1;
    end
    else begin
        o_cfg_crc_reg_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_bist_en <= 1'b0;
    end
    else if(lv_ctrl_nxt_st==) begin
        o_bist_en <= 1'b1;
    end
    else begin
        o_bist_en <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_intb_n <= 1'b1;
    end
    else if((lv_ctrl_nxt_st==PWR_DWN_ST) || (lv_ctrl_nxt_st==WAIT_ST)) begin
        o_intb_n <= 1'b0;
    end
    else begin
        o_intb_n <= 1'b1;
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


