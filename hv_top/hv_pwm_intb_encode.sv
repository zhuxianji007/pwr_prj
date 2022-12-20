//============================================================
//Module   : hv_pwm_intb_encode
//Function : reuse pwm channel to send intb
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_pwm_intb_encode #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic           i_hv_intb_n                      ,
    input  logic           i_hv_pwm_gwave                   ,
    input  logic           i_wdgintb_en                     ,
    input  logic [1: 0]    i_wdgintb_config                 ,
    output logic           o_hv_pwm_intb_n                  ,

    input  logic           i_clk                            ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam PWM_INTB_FSM_ST_NUM      = 5                             ;
localparam PWM_INTB_FSM_ST_W        = $clog2(PWM_INTB_FSM_ST_NUM)   ;
localparam PWM_INTB_FSM_IDLE_ST     = PWM_INTB_FSM_ST_W'(0)         ;
localparam PWM_INTB_FSM_INTB1_0_ST  = PWM_INTB_FSM_ST_W'(1)         ;
localparam PWM_INTB_FSM_INTB1_1_ST  = PWM_INTB_FSM_ST_W'(2)         ;
localparam PWM_INTB_FSM_INTB1_2_ST  = PWM_INTB_FSM_ST_W'(3)         ;
localparam PWM_INTB_FSM_INTB0_ST    = PWM_INTB_FSM_ST_W'(4)         ; 
//==================================
//var delcaration
//==================================
logic [PWM_INTB_FSM_ST_W-1: 0]  hv_pwm_intb_cur_st   ;
logic [PWM_INTB_FSM_ST_W-1: 0]  hv_pwm_intb_nxt_st   ; 
logic                           hv_intb_n_ff         ;
logic                           hv_intb_pulse        ;
logic                           hv_intb0_pulse       ;
logic                           hv_intb1_pulse       ;
logic [WDG_CNT_W-1:         0]  wdg_intb_cnt         ;
logic                           wdg_intb_update      ;
logic                           wdg_intb0_update     ;
logic                           wdg_intb1_update     ;
logic                           hv_pwm_gwave_lock    ;
logic                           intb_extend_start    ;
logic                           bit_extend_in_vld    ;
logic                           bit_extend_in        ;
logic                           bit_extend_out_vld   ;
logic                           bit_extend_out       ;
logic                           bit_extend_done      ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        hv_pwm_intb_cur_st <= PWM_INTB_FSM_IDLE_ST; 
    end
    else begin
        hv_pwm_intb_cur_st <= hv_pwm_intb_nxt_st;
    end
end

always_comb begin
    hv_pwm_intb_nxt_st = hv_pwm_intb_cur_st;
    case(hv_pwm_intb_cur_st)
        PWM_INTB_FSM_IDLE_ST : begin
            if(hv_intb1_pulse | wdg_intb1_update) begin
                hv_pwm_intb_nxt_st = PWM_INTB_FSM_INTB1_0_ST;
            end
            else if(hv_intb0_pulse | wdg_intb0_update) begin
                hv_pwm_intb_nxt_st = PWM_INTB_FSM_INTB0_ST;            
            end
            else;
        end
        PWM_INTB_FSM_INTB1_0_ST : begin
            if(bit_extend_done) begin
                hv_pwm_intb_nxt_st = PWM_INTB_FSM_INTB1_1_ST;
            end
            else;
        end
        PWM_INTB_FSM_INTB1_1_ST : begin
            if(bit_extend_done) begin
                hv_pwm_intb_nxt_st = PWM_INTB_FSM_INTB1_2_ST;
            end
            else;
        end
        PWM_INTB_FSM_INTB1_2_ST : begin
            if(bit_extend_done) begin
                hv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;
            end
            else;
        end
        PWM_INTB_FSM_INTB0_ST : begin
            if(bit_extend_done) begin
                hv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;
            end
            else;
        end        
        default : begin
            hv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;
        end
    endcase
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        hv_intb_n_ff <= 1'b1; 
    end
    else begin
        hv_intb_n_ff <= i_hv_intb_n;
    end
end

assign hv_intb_pulse   =  i_hv_intb_n ^  hv_intb_n_ff ;
assign hv_intb0_pulse  = ~i_hv_intb_n &  hv_intb_n_ff ;
assign hv_intb1_pulse  =  i_hv_intb_n & ~hv_intb_n_ff ;
 
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_intb_cnt <= WDG_CNT_W'(0);
    end
    else if(i_wdgintb_en) begin
        if(hv_intb_pulse) begin
            wdg_intb_cnt <= WDG_CNT_W'(0);        
        end
        else if(wdg_intb_cnt==(WDG_INTB_TH[i_wdgintb_config]-1)) begin
            wdg_intb_cnt <= WDG_CNT_W'(0);
        end
        else begin
            wdg_intb_cnt <= wdg_intb_cnt+1'b1;
        end
    end
    else begin
        wdg_intb_cnt <= WDG_CNT_W'(0);    
    end
end

assign wdg_intb_update  = (wdg_intb_cnt==(WDG_INTB_TH[i_wdgintb_config]-1));
assign wdg_intb0_update = wdg_intb_update & ~i_hv_intb_n;
assign wdg_intb1_update = wdg_intb_update &  i_hv_intb_n;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        hv_pwm_gwave_lock <= 1'b0; 
    end
    else begin
        hv_pwm_gwave_lock <= (wdg_intb_update | hv_intb_pulse) ? i_hv_pwm_gwave : hv_pwm_gwave_lock;
    end
end

assign intb_extend_start = (hv_intb1_pulse | wdg_intb1_update | hv_intb0_pulse | wdg_intb0_update);
assign bit_extend_in_vld = (hv_pwm_intb_nxt_st!=PWM_INTB_FSM_IDLE_ST) & (intb_extend_start | bit_extend_done);
assign bit_extend_in     = (hv_pwm_intb_nxt_st==PWM_INTB_FSM_INTB1_0_ST) ? ~i_hv_pwm_gwave    :
                           (hv_pwm_intb_nxt_st==PWM_INTB_FSM_INTB1_1_ST) ?  hv_pwm_gwave_lock :
                           (hv_pwm_intb_nxt_st==PWM_INTB_FSM_INTB1_2_ST) ? ~hv_pwm_gwave_lock : ~i_hv_pwm_gwave;

signal_extend #(
    .EXTEND_CYC_NUM (PWM_INTB_EXT_CYC_NUM)
) U_BIT_EXTEND ( 
    .i_vld        (bit_extend_in_vld    ),
    .i_vld_data   (bit_extend_in        ),
    .o_vld        (bit_extend_out_vld   ),
    .o_vld_data   (bit_extend_out       ),
    .o_done       (bit_extend_done      ),
    .i_clk        (i_clk                ),
    .i_rst_n      (i_rst_n              )
);   

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_pwm_intb_n <= 1'b0; 
    end
    else begin
        o_hv_pwm_intb_n <= bit_extend_out_vld ? bit_extend_out : i_hv_pwm_gwave;
    end
end
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

