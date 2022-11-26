//============================================================
//Module   : lv_owt_tx_ctrl
//Function : one wire bus req. 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_owt_tx_ctrl #(
    `include "lv_param.vh"
    parameter END_OF_LIST = 1
)(
    input  logic                            i_spi_owt_wen  ,
    input  logic                            i_spi_owt_ren  ,
    input  logic [REG_AW-1:             0]  i_spi_owt_addr ,
    input  logic [REG_DW-1:             0]  i_spi_owt_wdata,
    
    input  logic                            i_wdg_owt_adc_req,
    output logic                            o_owt_wdg_adc_ack,

    output logic                            o_lv_hv_owt_tx , 
    
    input  logic                            i_clk	       ,
    input  logic                            i_rst_n
);
//==================================
//local param delcaration
//==================================
localparam RD_OP    = 1'b0; //OP==OPERATION
localparam WR_OP    = 1'b1; 
//==================================
//var delcaration
//==================================
logic                               spi_owt_wen_lock    ;
logic                               spi_owt_ren_lock    ;
logic [REG_AW-1:                0]  spi_owt_addr_lock   ;
logic [REG_DW-1:                0]  spi_owt_wdata_lock  ;
logic                               spi_owt_rw_flag     ;//0: read; 1: write.
logic                               spi_owt_req         ;
logic                               spi_owt_req_ff      ;
logic                               wdg_owt_adc_req_ff  ;
logic                               owt_spi_grant       ;
logic                               owt_wdg_grant       ;
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
logic [OWT_DATA_BIT_NUM-1:      0]  tx_data_bit         ;
logic [OWT_CRC_BIT_NUM-1:       0]  tx_crc_bit          ;
logic [OWT_TAIL_BIT_NUM-1:      0]  tx_end_tail_bit     ;
logic                               crc8_gen_i_vld      ;
logic                               crc8_gen_i_vld_bit  ;
logic                               crc8_gen_i_start    ;
logic                               owt_tx_start        ;
logic                               owt_tx_start_ff     ;
logic                               owt_tx_abort        ;
logic                               cur_tx_is_wdg_radc  ;
logic                               cur_tx_is_spi_req   ;
logic                               lv_hv_owt_vld_nc    ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_owt_wen_lock <= 1'b0;
        spi_owt_ren_lock <= 1'b0;
    end
    else begin
        spi_owt_wen_lock <= owt_spi_grant ? 1'b0 : (i_spi_owt_wen ? 1'b1 : spi_owt_wen_lock);
        spi_owt_ren_lock <= owt_spi_grant ? 1'b0 : (i_spi_owt_ren ? 1'b1 : spi_owt_ren_lock);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_owt_addr_lock <= REG_AW'(0);
        spi_owt_rw_flag   <= RD_OP;
    end
    else if(i_spi_owt_wen | i_spi_owt_ren) begin
        spi_owt_addr_lock <= i_spi_owt_addr;
        spi_owt_rw_flag   <= i_spi_owt_ren ? RD_OP : WR_OP;   
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_owt_wdata_lock <= REG_DW'(0);
    end
    else if(i_spi_owt_wen) begin
        spi_owt_wdata_lock <= i_spi_owt_wdata;   
    end
    else;
end
             
assign spi_owt_req = (i_spi_owt_wen | spi_owt_wen_lock) | (i_spi_owt_ren | spi_owt_ren_lock);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_owt_req_ff <= 1'b0;
    end
    else begin
        spi_owt_req_ff <= spi_owt_req;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_owt_adc_req_ff <= 1'b0;
    end
    else begin
        wdg_owt_adc_req_ff <= i_wdg_owt_adc_req;
    end
end

assign owt_tx_abort = (cur_tx_is_wdg_radc==1'b1) & spi_owt_req & tx_bit_extend_done;

assign owt_spi_grant = (~cur_tx_is_wdg_radc & ~cur_tx_is_spi_req & spi_owt_req & ~spi_owt_req_ff) | 
                       (cur_tx_is_wdg_radc & spi_owt_req & (owt_tx_nxt_st==OWT_IDLE_ST)) |
                       (cur_tx_is_spi_req & (owt_tx_cur_st!=OWT_IDLE_ST) & (owt_tx_nxt_st==OWT_IDLE_ST) & spi_owt_req);

assign owt_wdg_grant = (~cur_tx_is_wdg_radc & ~cur_tx_is_spi_req & i_wdg_owt_adc_req & ~spi_owt_req) |
                       (cur_tx_is_wdg_radc & i_wdg_owt_adc_req & ~spi_owt_req & (owt_tx_cur_st!=OWT_IDLE_ST) & (owt_tx_nxt_st==OWT_IDLE_ST));

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_tx_start    <= 1'b0;
        owt_tx_start_ff <= 1'b0;
    end
    else begin
        owt_tx_start    <= owt_spi_grant | owt_wdg_grant;
        owt_tx_start_ff <= owt_tx_start;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_owt_wdg_adc_ack <= 1'b0;
    end
    else begin
        o_owt_wdg_adc_ack <= owt_wdg_grant;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        cur_tx_is_wdg_radc <= 1'b0;
        cur_tx_is_spi_req  <= 1'b0;
    end
    else if(owt_wdg_grant) begin
        cur_tx_is_wdg_radc <= 1'b1;
        cur_tx_is_spi_req  <= 1'b0;
    end
    else if(owt_spi_grant) begin
        cur_tx_is_wdg_radc <= 1'b0;
        cur_tx_is_spi_req  <= 1'b1;   
    end
    else if((owt_tx_cur_st!=OWT_IDLE_ST) & (owt_tx_nxt_st==OWT_IDLE_ST)) begin
        cur_tx_is_wdg_radc <= 1'b0;
        cur_tx_is_spi_req  <= 1'b0;     
    end
    else;
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
            else if(tx_bit_done) begin
                owt_tx_nxt_st = OWT_NML_DATA_ST;
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
    endcase
end

assign tx_syn_head_bit  = OWT_SYNC_BIT_NUM'(0)                                                           ;
assign tx_syn_tail_bit  = 4'b1100                                                                        ;
assign tx_cmd_bit       = cur_tx_is_spi_req ? {spi_owt_rw_flag, spi_owt_addr_lock} : {RD_OP,REQ_ADC_ADDR};
assign tx_data_bit      = cur_tx_is_spi_req ? spi_owt_wdata_lock                   : OWT_DATA_BIT_NUM'(0);
assign tx_end_tail_bit  = 4'b1100                                                                        ;
assign tx_vld_bit       = (owt_tx_cur_st==OWT_SYNC_HEAD_ST) ? tx_syn_head_bit[OWT_SYNC_BIT_NUM-1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_SYNC_TAIL_ST) ? tx_syn_tail_bit[OWT_TAIL_BIT_NUM-1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_CMD_ST      ) ? tx_cmd_bit     [OWT_CMD_BIT_NUM -1-tx_cnt_bit] : 
                          (owt_tx_cur_st==OWT_NML_DATA_ST ) ? tx_data_bit    [OWT_DATA_BIT_NUM-1-tx_cnt_bit] : 
                          (owt_tx_cur_st==OWT_CRC_ST      ) ? tx_crc_bit     [OWT_CRC_BIT_NUM -1-tx_cnt_bit] :
                          (owt_tx_cur_st==OWT_END_TAIL_ST ) ? tx_end_tail_bit[OWT_TAIL_BIT_NUM-1-tx_cnt_bit] :
                          1'b0;

assign crc8_gen_i_vld     = ((owt_tx_cur_st==OWT_CMD_ST) | (owt_tx_cur_st==OWT_NML_DATA_ST)) & tx_mcst_vld;
assign crc8_gen_i_vld_bit = tx_vld_bit;
assign crc8_gen_i_start   = (owt_tx_cur_st==OWT_CMD_ST) & (tx_cnt_bit==CNT_MAX_W'(0)) & tx_mcst_vld;
                     
crc8_serial U_CRC8_GEN(
    .i_vld             (crc8_gen_i_vld     ),
    .i_data            (crc8_gen_i_vld_bit ),
    .i_new_calc        (crc8_gen_i_start   ),
    .o_vld_crc         (tx_crc_bit         ),
    .i_clk	           (i_clk              ),
    .i_rst_n           (i_rst_n            )
);

assign tx_extend_bit_in = ((owt_tx_cur_st==OWT_SYNC_HEAD_ST) | (owt_tx_cur_st==OWT_CMD_ST) | (owt_tx_cur_st==OWT_NML_DATA_ST) | (owt_tx_cur_st==OWT_CRC_ST)) 
                            ? (~tx_vld_bit ? tx_gen_mcst_code : ~tx_gen_mcst_code) : tv_vld_bit;

assign tx_vld = (owt_tx_start_ff | tx_bit_extend_done) & (owt_tx_cur_st!=OWT_IDLE_ST);

signal_extend #(
    .EXTEND_CYC_NUM(12)
) U_OWT_TX_SIGNAL_EXTEND(
    .i_vld        (tx_vld               ),
    .i_vld_data   (tx_extend_bit_in     ),
    .o_vld        (lv_hv_owt_vld_nc     ),//no need to connet.
    .o_vld_data   (o_lv_hv_owt_tx       ),
    .o_done       (tx_bit_extend_done   ),
    .i_clk        (i_clk                ),
    .i_rst_n      (i_rst_n              )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        tx_gen_mcst_code <= 1'b0;
    end
    else if((owt_rx_cur_st==OWT_SYNC_HEAD_ST) | (owt_rx_cur_st==OWT_CMD_ST)
            (owt_rx_cur_st==OWT_ADC_DATA_ST) | (owt_rx_cur_st==OWT_NML_DATA_ST) | (owt_rx_cur_st==OWT_CRC_ST)) begin
        tx_gen_mcst_code <= tx_vld ? ~tx_gen_mcst_code : tx_gen_mcst_code;
    end
    else begin
        tx_gen_mcst_code <= 1'b0;
    end
end

assign tx_mcst_vld = tx_vld & tx_gen_mcst_code;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_sync_tail_bit[OWT_TAIL_BIT_NUM-1: 0] <= {OWT_TAIL_BIT_NUM{1'b0}};
    end
    else if(rx_vld & ((owt_rx_cur_st==OWT_SYNC_TAIL_ST) | (owt_rx_cur_st==OWT_END_TAIL_ST))) begin
        rx_sync_tail_bit[OWT_TAIL_BIT_NUM-1: 0] <= {rx_sync_tail_bit[OWT_TAIL_BIT_NUM-2: 0], rx_vld_data}; 
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_cmd_data[OWT_CMD_BIT_NUM-1: 0] <= {OWT_CMD_BIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_CMD_ST)) begin
        rx_cmd_data[OWT_CMD_BIT_NUM-1: 0] <= {rx_cmd_data[OWT_CMD_BIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

assign rx_cmd_rd = ~rx_cmd_data[OWT_CMD_BIT_NUM-1];
assign rx_cmd_wr =  rx_cmd_data[OWT_CMD_BIT_NUM-1];

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_adc_data[OWT_ADC_DBIT_NUM-1: 0] <= {OWT_ADC_DBIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & ((owt_rx_cur_st==OWT_ADC_DATA_ST) | (owt_rx_cur_st==OWT_NML_DATA_ST))) begin
        rx_adc_data[OWT_ADC_DBIT_NUM-1: 0] <= {rx_adc_data[OWT_ADC_DBIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

assign rx_nml_data = rx_adc_data[OWT_DATA_BIT_NUM-1: 0];

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_crc_data[OWT_CRC_BIT_NUM-1: 0] <= {OWT_CRC_BIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==OWT_CRC_ST)) begin
        rx_crc_data[OWT_CRC_BIT_NUM-1: 0] <= {rx_crc_data[OWT_CRC_BIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

always_comb@(*) begin
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
        tx_cnt_bit <= CNT_MAX_W'(0);
    end
    else if(owt_tx_abort) begin
        tx_cnt_bit <= CNT_MAX_W'(0);
    end
    else if(owt_tx_cur_st==OWT_SYNC_HEAD_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_SYNC_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1);
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_SYNC_TAIL_ST) begin
        if(tx_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_TAIL_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1);   
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_CMD_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_CMD_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_NML_DATA_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_DATA_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_CRC_ST) begin
        if(tx_mcst_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_CRC_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_END_TAIL_ST) begin
        if(tx_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_TAIL_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_tx_cur_st==OWT_ABORT_ST) begin
        if(tx_vld) begin
            tx_cnt_bit <= (tx_cnt_bit==(OWT_ABORT_BIT_NUM-1)) ? CNT_MAX_W'(0) : (tx_cnt_bit+1'b1); 
        end
        else;
    end
    else begin
        tx_cnt_bit <= CNT_MAX_W'(0);
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
