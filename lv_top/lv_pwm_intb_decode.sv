//============================================================
//Module   : lv_pwm_intb_decode
//Function : decode pwm intb, gen hv_intb
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_pwm_intb_decode #(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic           i_hv_pwm_intb_n                  ,

    output logic           o_lv_pwm_gwave                   ,
    output logic           o_hv_intb_n                      ,

    input  logic           i_clk                            ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam PWM_DETECT_CNT_W         = $clog2(PWM_INTB_EXT_CYC_NUM+1);
localparam CNT_DN_TH                = PWM_DETECT_CNT_W'(4)          ;
localparam CNT_UP_TH                = PWM_DETECT_CNT_W'(8)          ;

localparam PWM_INTB_FSM_ST_NUM      = 5                             ;
localparam PWM_INTB_FSM_ST_W        = $clog2(PWM_INTB_FSM_ST_NUM)   ;
localparam PWM_INTB_FSM_IDLE_ST     = PWM_INTB_FSM_ST_W'(0)         ;
localparam PWM_INTB_FSM_DETECT_0_ST = PWM_INTB_FSM_ST_W'(1)         ;
localparam PWM_INTB_FSM_DETECT_1_ST = PWM_INTB_FSM_ST_W'(2)         ;
localparam PWM_INTB_FSM_DETECT_2_ST = PWM_INTB_FSM_ST_W'(3)         ;
localparam PWM_INTB_FSM_DETECT_3_ST = PWM_INTB_FSM_ST_W'(4)         ;
//==================================
//var delcaration
//==================================
logic                           bit_detect_out_vld      ;
logic                           bit_detect_out          ;
logic [PWM_DETECT_CNT_W-1:  0]  lv_pwm_new_detect_cnt   ;
logic                           lv_pwm_detect_end       ;
logic [PWM_INTB_FSM_ST_W-1: 0]  lv_pwm_intb_cur_st      ;
logic [PWM_INTB_FSM_ST_W-1: 0]  lv_pwm_intb_nxt_st      ;
logic                           hv_intb0_pulse          ;
logic                           hv_intb1_pulse          ;
//==================================
//main code
//==================================
assign o_lv_pwm_gwave = i_hv_pwm_intb_n;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lv_pwm_new_detect_cnt <= PWM_DETECT_CNT_W'(0); 
    end
    else if(bit_detect_out_vld) begin
        lv_pwm_new_detect_cnt <= PWM_DETECT_CNT_W'(1); 
    end
    else begin
        lv_pwm_new_detect_cnt <= (lv_pwm_new_detect_cnt==(CNT_UP_TH+1)) ? lv_pwm_new_detect_cnt : (lv_pwm_new_detect_cnt+1'b1); 
    end
end

assign lv_pwm_detect_end = (lv_pwm_new_detect_cnt>CNT_UP_TH);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lv_pwm_intb_cur_st <= PWM_INTB_FSM_IDLE_ST; 
    end
    else begin
        lv_pwm_intb_cur_st <= lv_pwm_intb_nxt_st;
    end
end

always_comb begin
    lv_pwm_intb_nxt_st = lv_pwm_intb_cur_st;
    case(lv_pwm_intb_cur_st)
        PWM_INTB_FSM_IDLE_ST : begin
            if(bit_detect_out_vld) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_DETECT_0_ST;
            end
            else;
        end
        PWM_INTB_FSM_DETECT_0_ST : begin
            if(bit_detect_out_vld) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_DETECT_1_ST;
            end
            else if(lv_pwm_detect_end) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;            
            end
            else;
        end
        PWM_INTB_FSM_DETECT_1_ST : begin
            if(bit_detect_out_vld) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_DETECT_2_ST;
            end
            else if(lv_pwm_detect_end) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;            
            end
            else;
        end
        PWM_INTB_FSM_DETECT_2_ST : begin
            if(bit_detect_out_vld) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_DETECT_3_ST;
            end
            else if(lv_pwm_detect_end) begin
                lv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;            
            end
            else;
        end
        PWM_INTB_FSM_DETECT_3_ST : begin
            lv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;            
        end       
        default : begin
            lv_pwm_intb_nxt_st = PWM_INTB_FSM_IDLE_ST;
        end
    endcase
end

assign hv_intb0_pulse  = (lv_pwm_intb_cur_st==PWM_INTB_FSM_DETECT_0_ST) & (lv_pwm_intb_nxt_st==PWM_INTB_FSM_IDLE_ST) ;
assign hv_intb1_pulse  = (lv_pwm_intb_cur_st==PWM_INTB_FSM_DETECT_3_ST) & (lv_pwm_intb_nxt_st==PWM_INTB_FSM_IDLE_ST) ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_hv_intb_n <= 1'b1; 
    end
    else if(hv_intb0_pulse) begin
        o_hv_intb_n <= 1'b0;
    end
    else if(hv_intb1_pulse) begin
        o_hv_intb_n <= 1'b1;    
    end
    else;
end

signal_detect #(
    .CNT_W (4       ) ,
    .DN_TH (4'(4)   ) ,
    .UP_TH (4'(8)   ) ,
    .MODE  (0       ) 
) U_BIT_DETECT ( 
    .i_vld        (i_hv_pwm_intb_n      ),
    .i_vld_data   (i_hv_pwm_intb_n      ),
    .o_vld        (bit_detect_out_vld   ),
    .o_vld_data   (bit_detect_out       ),
    .i_clk        (i_clk                ),
    .i_rst_n      (i_rst_n              )
);

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

