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
    input  logic           i_lv_gate_vs_pwm     ,
    input  logic [3:    0] i_vge_mon_dly        ,

    output logic           o_lv_pwm_mmerr       ,
    output logic           o_lv_pwm_dterr       ,

    input  logic           i_clk                ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam  GATE_BACK_100NS_CYC_NUM  = ( 100*CLK_M+999)/1000 ;// +999, for ceil to an integer. 
localparam  GATE_BACK_200NS_CYC_NUM  = ( 200*CLK_M+999)/1000 ;
localparam  GATE_BACK_400NS_CYC_NUM  = ( 400*CLK_M+999)/1000 ;
localparam  GATE_BACK_600NS_CYC_NUM  = ( 600*CLK_M+999)/1000 ;
localparam  GATE_BACK_800NS_CYC_NUM  = ( 800*CLK_M+999)/1000 ;
localparam GATE_BACK_1000NS_CYC_NUM  = (1000*CLK_M+999)/1000 ;
localparam GATE_BACK_1200NS_CYC_NUM  = (1200*CLK_M+999)/1000 ;
localparam GATE_BACK_1400NS_CYC_NUM  = (1400*CLK_M+999)/1000 ;
localparam GATE_BACK_1600NS_CYC_NUM  = (1600*CLK_M+999)/1000 ;
localparam GATE_BACK_1800NS_CYC_NUM  = (1800*CLK_M+999)/1000 ;
localparam GATE_BACK_2000NS_CYC_NUM  = (2000*CLK_M+999)/1000 ;
localparam GATE_BACK_2400NS_CYC_NUM  = (2400*CLK_M+999)/1000 ;
localparam GATE_BACK_2800NS_CYC_NUM  = (2800*CLK_M+999)/1000 ;
localparam GATE_BACK_3200NS_CYC_NUM  = (3200*CLK_M+999)/1000 ;
localparam GATE_BACK_3600NS_CYC_NUM  = (3600*CLK_M+999)/1000 ;
localparam GATE_BACK_4000NS_CYC_NUM  = (4000*CLK_M+999)/1000 ; //one core clk cycle is (1000/48)ns, 4000ns has (4x1000)ns/(1000/48)ns = 4x48 cycle.

localparam integer GATE_BACK_CYC_NUM[15: 0] ={GATE_BACK_4000NS_CYC_NUM, GATE_BACK_3600NS_CYC_NUM, GATE_BACK_3200NS_CYC_NUM, GATE_BACK_2800NS_CYC_NUM,
                                              GATE_BACK_2400NS_CYC_NUM, GATE_BACK_2000NS_CYC_NUM, GATE_BACK_1800NS_CYC_NUM, GATE_BACK_1600NS_CYC_NUM,
                                              GATE_BACK_1400NS_CYC_NUM, GATE_BACK_1200NS_CYC_NUM, GATE_BACK_1000NS_CYC_NUM, GATE_BACK_800NS_CYC_NUM ,
                                              GATE_BACK_600NS_CYC_NUM , GATE_BACK_400NS_CYC_NUM , GATE_BACK_200NS_CYC_NUM , GATE_BACK_100NS_CYC_NUM};


localparam CNT_W     = $clog2(GATE_BACK_4000NS_CYC_NUM);
//==================================
//var delcaration
//==================================
logic                    lv_pwm_dt_sync         ;
logic                    lv_pwm_dt_sync_ff      ;
logic                    lv_gate_vs_pwm_sync    ;
logic [CNT_W-1:       0] cnt                    ;
//==================================
//main code
//==================================
gnrl_sync #(
    .DW             (1                      ),
    .DEF_VAL        (1'b0                   )
)U_LV_PWM_DT_SYNC(
    .i_data         (i_lv_pwm_dt            ) ,
    .o_data         (lv_pwm_dt_sync         ) ,
    .i_clk          (i_clk                  ) ,
    .i_rst_n        (i_rst_n                )
);

gnrl_sync #(
    .DW             (1                      ),
    .DEF_VAL        (1'b0                   )
)U_LV_GATE_VS_PWM_SYNC(
    .i_data         (i_lv_gate_vs_pwm       ) ,
    .o_data         (lv_gate_vs_pwm_sync    ) ,
    .i_clk          (i_clk                  ) ,
    .i_rst_n        (i_rst_n                )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    lv_pwm_dt_sync_ff <= 1'b0;
	end
    else begin
	    lv_pwm_dt_sync_ff <= lv_pwm_dt_sync;    
    end
end

assign o_lv_pwm_dterr = lv_pwm_dt_sync & ~lv_pwm_dt_sync_ff;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    cnt <= CNT_W'(0);
	end
    else if(lv_gate_vs_pwm_sync) begin
        cnt <= (cnt==(GATE_BACK_CYC_NUM[i_vge_mon_dly]-1)) ? cnt : (cnt+1'b1);
    end
    else begin
	    cnt <= CNT_W'(0);
    end
end

assign o_lv_pwm_mmerr = (cnt==(GATE_BACK_CYC_NUM[i_vge_mon_dly]-1)) & lv_gate_vs_pwm_sync;

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule






