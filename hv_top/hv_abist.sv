//============================================================
//Module   : hv_abist
//Function : hv analog circuit bist.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_abist #(
    `include "com_param.svh"
    parameter END_OF_LIST          = 1
)( 
    input  logic 		        i_bist_hv_ov             ,
    input  logic                i_hv_vcc_ov              ,

    input  logic 		        i_bist_hv_ot             ,
    input  logic                i_hv_ot                  ,

    input  logic 		        i_bist_hv_opscod         ,
    input  logic                i_hv_desat_flt           ,

    input  logic 		        i_bist_hv_oc             ,
    input  logic                i_hv_oc                  ,

    input  logic 		        i_bist_hv_sc             ,
    input  logic                i_hv_scp_flt             ,

    input  logic 		        i_bist_hv_adc            ,
    input  logic [ADC_DW-1: 0]  i_hv_adc_data1           ,
    input  logic [ADC_DW-1: 0]  i_hv_adc_data2           ,

    output logic                o_bist_hv_ov_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_ot_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_opscod_status  ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_oc_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_sc_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_adc_status     ,//1: bist success; 0: bist failure.

    input  logic                i_clk                    ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam ADC_DATA_DN_TH       = 0x1F8                        ;
localparam ADC_DATA_UP_TH       = 0x207                        ;
localparam BIST_70US_CYC_NUM    = 70*CLK_M                     ;
localparam BIST_1US_CYC_NUM     = 1*CLK_M                      ;
localparam BIST_4US_CYC_NUM     = 4*CLK_M                      ;
localparam BIST_CNT_W           = $clog2(BIST_70US_CYC_NUM+1)  ;
localparam BIST_ITEM_NUM        = 6                            ;

localparam [BIST_ITEM_NUM-1: 0] BIST_CYC_NUM = {BIST_4US_CYC_NUM, BIST_1US_CYC_NUM, BIST_1US_CYC_NUM, BIST_1US_CYC_NUM, BIST_1US_CYC_NUM, BIST_70US_CYC_NUM};
//==================================
//var delcaration
//==================================
logic [BIST_CNT_W-1:    0]  bist_cnt        ;
logic [BIST_ITEM_NUM-1: 0]  bist_detect_sig ;
logic [BIST_ITEM_NUM-1: 0]  bist_status     ;
logic                       hv_adc_data_vld ;
//==================================
//main code
//==================================
assign hv_adc_data_vld = (i_hv_adc_data1>=ADC_DATA_DN_TH) & (i_hv_adc_data1<=ADC_DATA_UP_TH) & (i_hv_adc_data2>=ADC_DATA_DN_TH) & (i_hv_adc_data2<=ADC_DATA_UP_TH);
assign bist_detect_sig = {hv_adc_data_vld, i_hv_scp_flt, i_hv_oc, i_hv_desat_flt, i_hv_ot, i_hv_vcc_ov};

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    bist_cnt <= BIST_CNT_W'(0);
	end
  	else if(i_bist_lv_ov) begin
	    bist_cnt <= (bist_cnt==BIST_70US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else if(i_bist_hv_ot) begin
	    bist_cnt <=  (bist_cnt==BIST_1US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else if(i_bist_hv_opscod) begin
	    bist_cnt <=  (bist_cnt==BIST_1US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else if(i_bist_hv_oc) begin
	    bist_cnt <=  (bist_cnt==BIST_1US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else if(i_bist_hv_sc) begin
	    bist_cnt <=  (bist_cnt==BIST_1US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else if(i_bist_hv_adc) begin
	    bist_cnt <=  (bist_cnt==BIST_4US_CYC_NUM) ? bist_cnt : (bist_cnt+1'b1);
	end
    else begin
	    bist_cnt <= BIST_CNT_W'(0);    
    end
end

generate;
    for(genvar i=0; i<BIST_ITEM_NUM; i=i+1) begin: GEN_BIST_STATUS
        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
                bist_status[i] <= 1'b0;
            end
              else if(bist_detect_sig[i] & (bist_cnt<BIST_CYC_NUM[i])) begin
                bist_status[i] <= 1'b1;
            end
            else;
        end
    end
endgenerate

assign o_bist_hv_ov_status      = bist_status[0] ;
assign o_bist_hv_ot_status      = bist_status[1] ;
assign o_bist_hv_opscod_status  = bist_status[2] ;
assign o_bist_hv_oc_status      = bist_status[3] ;
assign o_bist_hv_sc_status      = bist_status[4] ;
assign o_bist_hv_adc_status     = bist_status[5] ;

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
