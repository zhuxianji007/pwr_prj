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
    parameter END_OF_LIST = 1
)(
    input  logic                i_bist_en                ,

    output logic 		        o_bist_hv_ov             ,
    input  logic                i_hv_vcc_ov              ,

    output logic 		        o_bist_hv_ot             ,
    input  logic                i_hv_ot                  ,

    output logic 		        o_bist_hv_opscod         ,
    input  logic                i_hv_desat_flt           ,

    output logic 		        o_bist_hv_oc             ,
    input  logic                i_hv_oc                  ,

    output logic 		        o_bist_hv_sc             ,
    input  logic                i_hv_scp_flt             ,

    output  logic 		        o_bist_hv_adc            ,
    input  logic [ADC_DW-1: 0]  i_hv_adc_data1           ,
    input  logic [ADC_DW-1: 0]  i_hv_adc_data2           ,

    output logic                o_bist_hv_ov_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_ot_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_opscod_status  ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_oc_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_sc_status      ,//1: bist success; 0: bist failure.
    output logic                o_bist_hv_adc_status     ,//1: bist success; 0: bist failure.

    output logic                o_lbist_en               ,

    input  logic                i_clk                    ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam ADC_DATA_DN_TH       = 10'h1F8                      ;
localparam ADC_DATA_UP_TH       = 10'h207                      ;
localparam BIST_70US_CYC_NUM    = 70*CLK_M                     ;
localparam BIST_1US_CYC_NUM     = 1*CLK_M                      ;
localparam BIST_4US_CYC_NUM     = 4*CLK_M                      ;
localparam BIST_CNT_W           = $clog2(BIST_70US_CYC_NUM+1)  ;
localparam BIST_ITEM_NUM        = 6                            ;
localparam BIST_SEL_W           = $clog2(BIST_ITEM_NUM+1)      ;

localparam integer unsigned BIST_CYC_NUM[BIST_ITEM_NUM-1: 0] = {BIST_4US_CYC_NUM, BIST_1US_CYC_NUM, BIST_1US_CYC_NUM, 
                                                                BIST_1US_CYC_NUM, BIST_1US_CYC_NUM, BIST_70US_CYC_NUM};
//==================================
//var delcaration
//==================================
logic [BIST_CNT_W-1:     0]  bist_sel_cyc_num ;                                                       
logic [BIST_SEL_W-1:     0]  bist_sel         ;
logic [BIST_CNT_W-1:     0]  bist_cnt         ;
logic [BIST_ITEM_NUM-1:  0]  bist_detect_sig  ;
logic [BIST_ITEM_NUM-1:  0]  start_nxt_detect ;
logic [BIST_ITEM_NUM-1:  0]  bist_status      ;
logic                        hv_adc_data_vld  ;
logic [BIST_ITEM_NUM-1:  0]  bist_dgt_ang     ;//bist sig dgt to analog
//==================================
//main code
//==================================
assign hv_adc_data_vld  = (i_hv_adc_data1>=ADC_DATA_DN_TH) & (i_hv_adc_data1<=ADC_DATA_UP_TH) & (i_hv_adc_data2>=ADC_DATA_DN_TH) & (i_hv_adc_data2<=ADC_DATA_UP_TH);
assign bist_detect_sig  = {hv_adc_data_vld, i_hv_scp_flt, i_hv_oc, i_hv_desat_flt, i_hv_ot, i_hv_vcc_ov};
assign start_nxt_detect = {1'b1, ~i_hv_scp_flt, ~i_hv_oc, ~i_hv_desat_flt, ~i_hv_ot, ~i_hv_vcc_ov};

always_comb begin: BIST_SEL_CYC_BLK
    bist_sel_cyc_num = BIST_CNT_W'(0);
    for(integer i=0; i<BIST_ITEM_NUM; i=i+1) begin: GEN_BIST_SEL_CYC
        if(bist_sel==i[BIST_SEL_W-1: 0]) begin
            bist_sel_cyc_num = BIST_CYC_NUM[i];
        end
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        bist_sel <= BIST_SEL_W'(0);
    end
    else if(i_bist_en) begin
        if((bist_cnt>=bist_sel_cyc_num) & start_nxt_detect[bist_sel]) begin
            bist_sel <= bist_sel+1'b1; 
        end 
        else;
    end
    else begin
        bist_sel <= BIST_SEL_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    bist_cnt <= BIST_CNT_W'(0);
	end
  	else if(i_bist_en & (bist_sel<BIST_ITEM_NUM)) begin
        if(bist_cnt>=bist_sel_cyc_num) begin
            bist_cnt <= (start_nxt_detect[bist_sel]) ? BIST_CNT_W'(0) : bist_cnt;
        end
        else begin
            bist_cnt <= (bist_cnt+1'b1);        
        end
	end
    else begin
	    bist_cnt <= BIST_CNT_W'(0);    
    end
end

generate;
    for(genvar i=0; i<BIST_ITEM_NUM; i=i+1) begin: GEN_BIST_SIG
        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
                bist_status[i] <= 1'b0;
            end
              else if(bist_detect_sig[i] & (bist_cnt<BIST_CYC_NUM[i]) & (bist_sel==i[BIST_SEL_W-1: 0])) begin
                bist_status[i] <= 1'b1;
            end
            else;
        end

        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
                bist_dgt_ang[i] <= 1'b0;
            end
            else if(i_bist_en & (bist_sel==i[BIST_SEL_W-1: 0])) begin
                bist_dgt_ang[i] <= (bist_cnt<BIST_CYC_NUM[i]) ? 1'b1 : 1'b0;
            end
            else begin
                bist_dgt_ang[i] <= 1'b0;  
            end
        end
    end
endgenerate

assign o_bist_hv_ov_status      = bist_status[0] ;
assign o_bist_hv_ot_status      = bist_status[1] ;
assign o_bist_hv_opscod_status  = bist_status[2] ;
assign o_bist_hv_oc_status      = bist_status[3] ;
assign o_bist_hv_sc_status      = bist_status[4] ;
assign o_bist_hv_adc_status     = bist_status[5] ;

assign o_bist_hv_ov             = bist_dgt_ang[0];
assign o_bist_hv_ot             = bist_dgt_ang[1];
assign o_bist_hv_opscod         = bist_dgt_ang[2];
assign o_bist_hv_oc             = bist_dgt_ang[3];
assign o_bist_hv_sc             = bist_dgt_ang[4];
assign o_bist_hv_adc            = bist_dgt_ang[5]; 

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_lbist_en <= 1'b0;
    end
    else if(i_bist_en) begin
        if(bist_sel==BIST_ITEM_NUM) begin
            o_lbist_en <= 1'b1; 
        end 
        else;
    end
    else begin
        o_lbist_en <= 1'b0;
    end
end
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
