//============================================================
//Module   : hv_adc_sample
//Function : hv adc data sample and store.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_adc_sample #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic 		       i_ang_dgt_adc1_rdy   , //analog to digtial
    input  logic [ADC_DW-1: 0] i_ang_dgt_adc1_data  ,
    output logic [ADC_DW-1: 0] o_adc1_equ_data      ,

    input  logic 		       i_ang_dgt_adc2_rdy   , 
    input  logic [ADC_DW-1: 0] i_ang_dgt_adc2_data  ,
    output logic [ADC_DW-1: 0] o_adc2_equ_data      ,

    input  logic               i_clk                ,
    input  logic               i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam CACHE_NUM = 4                 ;
localparam EXT_DW    = $clog2(CACHE_NUM) ;
localparam TMP_DW    = EXT_DW+ADC_DW     ;         
//==================================
//var delcaration
//==================================
logic [CACHE_NUM: 0][ADC_DW-1: 0] adc1_data_ff         ;
logic [CACHE_NUM: 0][ADC_DW-1: 0] adc2_data_ff         ;
logic                             sync_adc1_rdy        ;
logic                             sync_adc2_rdy        ;
logic                             sync_adc1_rdy_ff     ;
logic                             sync_adc2_rdy_ff     ;
logic [CACHE_NUM: 0]              lock_adc1_data_ff    ;
logic [CACHE_NUM: 0]              lock_adc2_data_ff    ;
logic                             adc1_equ_data_vld    ;
logic                             adc2_equ_data_vld    ;
logic [TMP_DW-1:  0]              adc1_equ_data        ;
logic [TMP_DW-1:  0]              adc2_equ_data        ;
//==================================
//main code
//==================================
gnrl_sync #(
    .DW(1)
)U_ADC1_RDY_SYNC(
    .i_data (i_ang_dgt_adc1_rdy ),
    .o_data (sync_adc1_rdy      ),
    .i_clk  (i_clk              ),
    .i_rst_n(i_rst_n            )
);

gnrl_sync #(
    .DW(1)
)U_ADC2_RDY_SYNC(
    .i_data (i_ang_dgt_adc2_rdy ),
    .o_data (sync_adc2_rdy      ),
    .i_clk  (i_clk              ),
    .i_rst_n(i_rst_n            )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        sync_adc1_rdy_ff <= 1'b0;
        sync_adc2_rdy_ff <= 1'b0;
    end
    else begin
        sync_adc1_rdy_ff <= sync_adc1_rdy;
        sync_adc2_rdy_ff <= sync_adc2_rdy;
    end
end

assign lock_adc1_data_ff[0] = sync_adc1_rdy & ~sync_adc1_rdy_ff;
assign lock_adc2_data_ff[0] = sync_adc2_rdy & ~sync_adc2_rdy_ff;

assign adc1_data_ff[0] = i_ang_dgt_adc1_data;
assign adc2_data_ff[0] = i_ang_dgt_adc2_data;

generate;
for(genvar i=0; i<CACHE_NUM; i=i+1) begin: STORE_SAMPLE_DATA_BLK
    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            lock_adc1_data_ff[i+1] <= 1'b0;
            lock_adc2_data_ff[i+1] <= 1'b0;
        end
        else begin
            lock_adc1_data_ff[i+1] <= lock_adc1_data_ff[i];
            lock_adc2_data_ff[i+1] <= lock_adc2_data_ff[i];
        end
    end

    always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            adc1_data_ff[i+1] <= ADC_DW'(0);
            adc2_data_ff[i+1] <= ADC_DW'(0);
        end
        else begin
            adc1_data_ff[i+1] <= lock_adc1_data_ff[i] ? adc1_data_ff[i] : adc1_data_ff[i+1];
            adc2_data_ff[i+1] <= lock_adc2_data_ff[i] ? adc2_data_ff[i] : adc2_data_ff[i+1];
        end
    end
end 
endgenerate

tree_adder #(
    .IDW        (ADC_DW         ),
    .DATA_NUM   (CACHE_NUM      ),
    .INSERT_REG (0              ),
    .GATE_NUM   (5              )
) U_ADC1_ADDR(
    .i_vld          (sync_adc1_rdy_ff               ),
    .i_data         (adc1_data_ff[CACHE_NUM: 1]     ),
    .o_vld          (adc1_equ_data_vld              ),
    .o_add_reslt    (adc1_equ_data                  ),
    .i_clk          (i_clk                          ),
    .i_rst_n        (i_rst_n                        )
);

tree_adder #(
    .IDW        (ADC_DW         ),
    .DATA_NUM   (CACHE_NUM      ),
    .INSERT_REG (0              ),
    .GATE_NUM   (5              )
) U_ADC2_ADDR(
    .i_vld          (sync_adc2_rdy_ff               ),
    .i_data         (adc2_data_ff[CACHE_NUM: 1]     ),
    .o_vld          (adc2_equ_data_vld              ),
    .o_add_reslt    (adc2_equ_data                  ),
    .i_clk          (i_clk                          ),
    .i_rst_n        (i_rst_n                        )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_adc1_equ_data <= ADC_DW'(0);
        o_adc2_equ_data <= ADC_DW'(0);
    end
    else begin
        o_adc1_equ_data <= adc1_equ_data_vld ? adc1_equ_data[TMP_DW-1 -: ADC_DW] : o_adc1_equ_data;
        o_adc1_equ_data <= adc2_equ_data_vld ? adc2_equ_data[TMP_DW-1 -: ADC_DW] : o_adc2_equ_data;
    end
end
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule

