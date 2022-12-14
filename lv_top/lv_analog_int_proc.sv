//============================================================
//Module   : lv_analog_int_proc
//Function : lv analog int proc
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_analog_int_proc #(
    `include "lv_param.svh"
    parameter END_OF_LIST          = 1
)(
    input  logic           i_lv_pwm_dt          ,
    input  logic           i_lv_pwm_cmp_wave    ,
    input  logic           i_lv_pwm_gate_wave   ,

    output logic           o_lv_pwm_mmerr       ,
    output logic           o_lv_pwm_dterr       ,

    input  logic           i_clk                ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
parameter XOR_CYC_NUM   = 4*CLK_M                ;
parameter XOR_CNT_W     = $clog2(XOR_CYC_NUM)    ;
//==================================
//var delcaration
//==================================
logic                    lv_pwm_dt_sync         ;
logic                    lv_pwm_dt_sync_ff      ;
logic                    lv_pwm_cmp_wave_sync   ;
logic                    lv_pwm_gate_wave_sync  ;
logic                    lv_pwm_xor             ;
logic [XOR_CNT_W-1:   0] xor_cnt                ;
//==================================
//main code
//==================================
gnrl_sync #(
    .DW             (1                      ),
    .DEF_VAL        (1'b0                   )
)U_LV_PWM_DT_SYNC(
    .i_data         (i_lv_pwm_dt            ) ,
    .o_data         (lv_pwm_dt_sync         ) ,
    .i_clk	        (i_clk                  ) ,
    .i_rst_n        (i_rst_n                )
);

gnrl_sync #(
    .DW             (1                      ),
    .DEF_VAL        (1'b0                   )
)U_LV_PWM_CMP_WAVE_SYNC(
    .i_data         (i_lv_pwm_cmp_wave      ) ,
    .o_data         (lv_pwm_cmp_wave_sync   ) ,
    .i_clk	        (i_clk                  ) ,
    .i_rst_n        (i_rst_n                )
);

gnrl_sync #(
    .DW             (1                      ),
    .DEF_VAL        (1'b0                   )
)U_LV_PWM_GATE_WAVE_SYNC(
    .i_data         (i_lv_pwm_gate_wave     ) ,
    .o_data         (lv_pwm_gate_wave_sync  ) ,
    .i_clk	        (i_clk                  ) ,
    .i_rst_n        (i_rst_n                )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    lv_pwm_dt_ff <= 1'b0;
	end
    else begin
	    lv_pwm_dt_sync_ff <= lv_pwm_dt_sync;    
    end
end

assign o_lv_pwm_dterr = lv_pwm_dt_sync & ~lv_pwm_dt_sync_ff;

assign lv_pwm_xor = lv_pwm_cmp_wave_sync ^ lv_pwm_gate_wave_sync;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    xor_cnt <= XOR_CNT_W'(0);
	end
    else if(lv_pwm_xor) begin
        xor_cnt <= (xor_cnt==(XOR_CYC_NUM-1)) ? xor_cnt : (xor_cnt+1'b1);
    end
    else begin
	    xor_cnt <= XOR_CNT_W'(0);
    end
end

assign o_lv_pwm_mmerr = (xor_cnt==(XOR_CYC_NUM-1)) & lv_pwm_xor;

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

