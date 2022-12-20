//============================================================
//Module   : hv_owt_tx_ctrl
//Function : one wire bus req. 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_owt_tx_ctrl #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)(
    input  logic                            i_rac_owt_tx_wr_cmd_vld ,
    input  logic                            i_rac_owt_tx_rd_cmd_vld ,
    input  logic [REG_AW-1:             0]  i_rac_owt_tx_addr       ,
    input  logic [OWT_ADCD_BIT_NUM-1:   0]  i_rac_owt_tx_data       ,

    output logic                            o_hv_lv_owt_tx          ,
    
    input  logic                            i_clk                   ,
    input  logic                            i_rst_n
);
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                               cmd_flag            ;//0: read; 1: write.
logic [OWT_FSM_ST_W-1:          0]  owt_tx_cur_st       ;
logic [OWT_FSM_ST_W-1:          0]  owt_tx_nxt_st       ;
logic                               tx_vld              ;
logic                               tx_bit_extend_done  ;
logic                               tx_vld_bit          ;
logic                               tx_extend_bit_in    ;
logic                               tx_gen_mcst_code    ;
logic                               tx_mcst_vld         ;
logic [CNT_OWT_MAX_W-1:         0]  tx_cnt_bit          ;
logic                               tx_bit_done         ;
logic [OWT_SYNC_BIT_NUM-1:      0]  tx_syn_head_bit     ;
logic [OWT_TAIL_BIT_NUM-1:      0]  tx_syn_tail_bit     ;
logic [OWT_CMD_BIT_NUM-1:       0]  tx_cmd_bit          ;
logic [OWT_ADCD_BIT_NUM-1:      0]  tx_data_bit         ;
logic [OWT_CRC_BIT_NUM-1:       0]  tx_crc_bit          ;
logic [OWT_TAIL_BIT_NUM-1:      0]  tx_end_tail_bit     ;
logic                               crc8_gen_i_vld      ;
logic                               crc8_gen_i_vld_bit  ;
logic                               crc8_gen_i_start    ;
logic                               owt_tx_start        ;
logic                               owt_tx_start_ff     ;
logic                               owt_tx_abort        ;
logic                               lv_hv_owt_vld_nc    ;
logic                               cur_is_ack_adc      ;
//==================================
//main code
//==================================
assign cmd_flag  = i_rac_owt_tx_rd_cmd_vld ? RD_OP : WR_OP  ; 
         
assign owt_tx_abort = 1'b0;

assign cur_is_ack_adc = (i_rac_owt_tx_addr==REQ_ADC_ADDR);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_tx_start    <= 1'b0;
        owt_tx_start_ff <= 1'b0;
    end
    else begin
        owt_tx_start    <= i_rac_owt_tx_wr_cmd_vld | i_rac_owt_tx_rd_cmd_vld;
        owt_tx_start_ff <= owt_tx_start;
    end
end

 always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_tx_cur_st <= OWT_FSM_ST_W'(0);
    end
    else begin
        owt_tx_cur_st <= owt_tx_nxt_st;
    end
end

always_comb begin
    owt_tx_nxt_st = owt_tx_cur_st;
    case(owt_tx_cur_st)
        OWT_IDLE_ST : begin 
            if(owt_tx_start) begin
                owt_tx_nxt_st = OWT_SYNC_HEAD_ST;
            end
            else;
        end
        OWT_SYNC_HEAD_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_SYNC_TAIL_ST;    
            end
            else;
        end
        OWT_SYNC_TAIL_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_CMD_ST;
            end
            else;
        end
        OWT_CMD_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done & ~cur_is_ack_adc) begin
                owt_tx_nxt_st = OWT_NML_DATA_ST;
            end
            else if(tx_bit_done & cur_is_ack_adc) begin
                owt_tx_nxt_st = OWT_ADC_DATA_ST;
            end
            else;
        end
        OWT_NML_DATA_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_CRC_ST;
            end
            else;       
        end
        OWT_ADC_DATA_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_CRC_ST;
            end
            else;       
        end
        OWT_CRC_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_END_TAIL_ST;
            end
            else;       
        end
        OWT_END_TAIL_ST : begin
            if(owt_tx_abort) begin
                owt_tx_nxt_st = OWT_ABORT_ST;
            end
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_IDLE_ST;
            end
            else;
        end
        OWT_ABORT_ST : begin
            if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_IDLE_ST;
            end
            else;
        end
        default : begin
            owt_tx_nxt_st = OWT_IDLE_ST;
        end
    endcase
end

assign tx_syn_head_bit  = OWT_SYNC_BIT_NUM'(0)          ;
assign tx_syn_tail_bit  = 4'b1100                       ;
assign tx_cmd_bit       = {cmd_flag,i_rac_owt_tx_addr}  ;
assign tx_data_bit      = i_rac_owt_tx_data             ;
assign tx_end_tail_bit  = 4'b1100                       ;
assign tx_vld_bit       = (owt_tx_cur_st==OWT_SYNC_HEAD_ST) ? tx_syn_head_bit[OWT_SYNC_BIT_NUM-1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_SYNC_TAIL_ST) ? tx_syn_tail_bit[OWT_TAIL_BIT_NUM-1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_CMD_ST      ) ? tx_cmd_bit     [OWT_CMD_BIT_NUM -1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_ADC_DATA_ST ) ? tx_data_bit    [OWT_ADCD_BIT_NUM-1-tx_cnt_bit] : 
                          (owt_tx_cur_st==OWT_NML_DATA_ST ) ? tx_data_bit    [OWT_DATA_BIT_NUM-1-tx_cnt_bit] : 
                          (owt_tx_cur_st==OWT_CRC_ST      ) ? tx_crc_bit     [OWT_CRC_BIT_NUM -1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_END_TAIL_ST ) ? tx_end_tail_bit[OWT_TAIL_BIT_NUM-1-tx_cnt_bit] :
                          1'b0;

assign crc8_gen_i_vld     = ((owt_tx_cur_st==OWT_CMD_ST) | (owt_tx_cur_st==OWT_ADC_DATA_ST) | (owt_tx_cur_st==OWT_NML_DATA_ST)) & tx_mcst_vld;
assign crc8_gen_i_vld_bit = tx_vld_bit;
assign crc8_gen_i_start   = (owt_tx_cur_st==OWT_CMD_ST) & (tx_cnt_bit==CNT_OWT_MAX_W'(0)) & tx_mcst_vld;
                     
crc8_serial U_CRC8_GEN(
    .i_vld             (crc8_gen_i_vld     ),
    .i_data            (crc8_gen_i_vld_bit ),
    .i_new_calc        (crc8_gen_i_start   ),
    .o_vld_crc         (tx_crc_bit         ),
    .i_clk	           (i_clk              ),
    .i_rst_n           (i_rst_n            )
);

assign tx_extend_bit_in = ((owt_tx_cur_st==OWT_SYNC_HEAD_ST) | (owt_tx_cur_st==OWT_CMD_ST) | (owt_tx_cur_st==OWT_NML_DATA_ST) | 
                           (owt_tx_cur_st==OWT_ADC_DATA_ST) |  (owt_tx_cur_st==OWT_CRC_ST)) 
                            ? (~tx_vld_bit ? tx_gen_mcst_code : ~tx_gen_mcst_code) : tx_vld_bit;

assign tx_vld = (owt_tx_start_ff | tx_bit_extend_done) & (owt_tx_cur_st!=OWT_IDLE_ST);

signal_extend #(
    .EXTEND_CYC_NUM(12)
) U_OWT_TX_SIGNAL_EXTEND(
    .i_vld        (tx_vld               ),
    .i_vld_data   (tx_extend_bit_in     ),
    .o_vld        (lv_hv_owt_vld_nc     ),//no need to connet.
    .o_vld_data   (o_hv_lv_owt_tx       ),
    .o_done       (tx_bit_extend_done   ),
    .i_clk        (i_clk                ),
    .i_rst_n      (i_rst_n              )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        tx_gen_mcst_code <= 1'b0;
    end
    else if((owt_tx_cur_st==OWT_SYNC_HEAD_ST) | (owt_tx_cur_st==OWT_CMD_ST) |
            (owt_tx_cur_st==OWT_ADC_DATA_ST) | (owt_tx_cur_st==OWT_NML_DATA_ST) | (owt_tx_cur_st==OWT_CRC_ST)) begin
        tx_gen_mcst_code <= tx_vld ? ~tx_gen_mcst_code : tx_gen_mcst_code;
    end
    else begin
        tx_gen_mcst_code <= 1'b0;
    end
end

assign tx_mcst_vld = tx_vld & tx_gen_mcst_code;

always_comb begin
    if(tx_mcst_vld & (owt_tx_cur_st==OWT_SYNC_HEAD_ST) & (tx_cnt_bit==(OWT_SYNC_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_vld & (owt_tx_cur_st==OWT_SYNC_TAIL_ST) & (tx_cnt_bit==(OWT_TAIL_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_mcst_vld & (owt_tx_cur_st==OWT_CMD_ST) & (tx_cnt_bit==(OWT_CMD_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_mcst_vld & (owt_tx_cur_st==OWT_NML_DATA_ST) & (tx_cnt_bit==(OWT_DATA_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_mcst_vld & (owt_tx_cur_st==OWT_ADC_DATA_ST) & (tx_cnt_bit==(OWT_ADCD_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_mcst_vld & (owt_tx_cur_st==OWT_CRC_ST) & (tx_cnt_bit==(OWT_CRC_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_vld & (owt_tx_cur_st==OWT_END_TAIL_ST) & (tx_cnt_bit==(OWT_TAIL_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else if(tx_vld & (owt_tx_cur_st==OWT_ABORT_ST) & (tx_cnt_bit==(OWT_ABORT_BIT_NUM-1))) begin
        tx_bit_done = 1'b1;
    end
    else begin
        tx_bit_done = 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        tx_cnt_bit <= CNT_OWT_MAX_W'(0);
    end
    else if(owt_tx_abort) begin
        tx_cnt_bit <= CNT_OWT_MAX_W'(0);
    end
    else if(owt_tx_cur_st==OWT_SYNC_HEAD_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_SYNC_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1);
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_SYNC_TAIL_ST) begin
        if(tx_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_TAIL_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1);   
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_CMD_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_CMD_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_NML_DATA_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_DATA_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_ADC_DATA_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_ADCD_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_CRC_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_CRC_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_END_TAIL_ST) begin
        if(tx_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_TAIL_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_ABORT_ST) begin
        if(tx_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_ABORT_BIT_NUM-1)) ? CNT_OWT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else begin
        tx_cnt_bit <= CNT_OWT_MAX_W'(0);
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
















