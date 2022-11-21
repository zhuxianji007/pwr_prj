//============================================================
//Module   : lv_owt_rx_ctrl
//Function : one wire bus req & ack. 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_owt_rx_ctrl #(
    `include "lv_param.vh"
    parameter END_OF_LIST = 1
)( 
    input  logic                i_spi_owt_wen           ,
    input  logic                i_spi_owt_ren           ,
    input  logic [REG_DW-1:  0] i_spi_owt_wdata         ,
    input  logic [REG_AW-1:  0] i_spi_owt_addr          ,

    input  logic                i_wdg_owt_req           ,
    output logic                o_owt_wdg_ack           ,

    output logic                o_lv_hv_owt_tx          ,
    input  logic                i_hv_lv_owt_rx          ,
    
    input  logic                i_clk	                ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam OWT_FSM_ST_NUM   = 7                        ;
localparam EXT_CYC_NUM      = 12                       ;
localparam CRC_BIT_NUM      = 8                        ;
localparam CMD_BIT_NUM      = 8                        ;
localparam OWT_DBIT_NUM     = 8                        ;//data bit
localparam ADC_DBIT_NUM     = 20                       ;
localparam SYNC_BIT_NUM     = 12                       ;
localparam TAIL_BIT_NUM     = 4                        ;
localparam OWT_FSM_ST_W     = $clog2(OWT_FSM_ST_NUM)   ;
localparam CNT_EXT_CYC_W    = $clog2(EXT_CYC_NUM+1)    ;
localparam CNT_MAX_W        = $clog2(ADC_DBIT_NUM)     ;
localparam IDLE_ST          = OWT_FSM_ST_W'(0)         ;
localparam SYNC_TAIL_ST     = OWT_FSM_ST_W'(1)         ; 
localparam CMD_ST           = OWT_FSM_ST_W'(2)         ;
localparam NML_DATA_ST      = OWT_FSM_ST_W'(3)         ;//normal data
localparam ADC_DATA_ST      = OWT_FSM_ST_W'(4)         ;
localparam CRC_ST           = OWT_FSM_ST_W'(5)         ;
localparam VLD_DATA_TAIL_ST = OWT_FSM_ST_W'(6)         ;   
//==================================
//var delcaration
//==================================
logic [OWT_FSM_ST_W-1:  0]  owt_tx_cur_st    ;
logic [OWT_FSM_ST_W-1:  0]  owt_tx_nxt_st    ;
logic [OWT_FSM_ST_W-1:  0]  owt_rx_cur_st    ;
logic [OWT_FSM_ST_W-1:  0]  owt_rx_nxt_st    ;
logic                       rx_vld           ;
logic                       rx_vld_data      ;
logic                       rx_vld_lock      ;
logic                       rx_vld_data_lock ;
logic                       rx_gen_mcst_code ;
logic                       rx_mcst_vld_zero ;//Manchester code
logic                       rx_mcst_vld_one  ;
logic [CNT_MAX_W-1:     0]  rx_cnt_bit       ;
logic                       rx_bit_done      ;
logic [TAIL_BIT_NUM-1:  0]  rx_sync_tail_bit ;
logic [CMD_BIT_NUM-1:   0]  rx_cmd_data      ;
logic [OWT_DBIT_NUM-1:  0]  rx_nml_data      ;
logic [ADC_DBIT_NUM-1:  0]  rx_adc_data      ;
logic [CRC_BIT_NUM-1:   0]  rx_crc_data      ;
logic                       rx_cmd_rd        ;
logic                       rx_cmd_wr        ;
//==================================
//main code
//==================================
 always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_rx_cur_st <= OWT_FSM_ST_W'(0);
    end
    else begin
        owt_rx_cur_st <= owt_rx_nxt_st;
    end
end

always_comb begin
    case(owt_rx_cur_st)
        IDLE_ST : begin 
            if(rx_mcst_vld_zero & (rx_cnt_bit==(SYNC_BIT_NUM-1))) begin
                owt_rx_nxt_st = SYNC_TAIL_ST;
            end
            else;
        end
        SYNC_TAIL_ST : begin
            if(rx_bit_done) begin
                if(rx_sync_tail_bit[3] & rx_sync_tail_bit[2] & ~rx_sync_tail_bit[1] & ~rx_sync_tail_bit[0]) begin
                    owt_rx_nxt_st = CMD_ST;
                end
                else begin
                    owt_rx_nxt_st = IDLE_ST;
                end
            end
            else;
        end
        CMD_ST : begin
            if(rx_bit_done & rx_cmd_rd & (rx_cmd_data[CMD_BIT_NUM-2: 0]==7'h1f)) begin
                owt_rx_nxt_st = ADC_DATA_ST;
            end
            else if(rx_bit_done & rx_cmd_rd) begin
                owt_rx_cur_st = NML_DATA_ST;
            end
            else;
        end
    endcase
end

signal_detect #(
    .CNT_W(CNT_EXT_CYC_W),
    .DN_TH(EXT_CYC_NUM-1),
    .UP_TH(EXT_CYC_NUM  ),
    .MODE (1            )
) U_OWT_RX_SIGNAL_DETECT(
    .i_vld        (i_hv_lv_owt_rx),
    .i_vld_data   (i_hv_lv_owt_rx),
    .o_vld        (rx_vld        ),
    .o_vld_data   (rx_vld_data   ),
    .i_clk        (i_clk         ),
    .i_rst_n      (i_rst_n       )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_vld_lock       <= 1'b0;
        rx_vld_data_lock  <= 1'b0;
    end
    else begin
        rx_vld_lcok       <= rx_vld ? 1'b1        : rx_vld_lock     ;
        rx_vld_data_lock  <= rx_vld ? rx_vld_data : rx_vld_data_lock;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_gen_mcst_code <= 1'b0;
    end
    else if(owt_rx_cur_st==IDLE_ST) begin
        rx_gen_mcst_code <= rx_vld ? ~rx_gen_mcst_code : rx_gen_mcst_code;
    end
    else begin
        rx_gen_mcst_code <= 1'b0;
    end
end

assign rx_mcst_vld_one  = rx_vld & rx_vld_lock &  rx_vld_data & ~rx_vld_data_lock & rx_gen_mcst_code; //posedge 0->1
assign rx_mcst_vld_zero = rx_vld & rx_vld_lock & ~rx_vld_data &  rx_vld_data_lock & rx_gen_mcst_code; //negedge 1->0

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_sync_tail_bit[TAIL_BIT_NUM-1: 0] <= {TAIL_BIT_NUM{1'b0}};
    end
    else if(rx_vld & (owt_rx_cur_st==SYNC_TAIL_ST)) begin
        rx_sync_tail_bit[TAIL_BIT_NUM-1: 0] <= {rx_sync_tail_bit[TAIL_BIT_NUM-2: 0], rx_vld_data}; 
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_cmd_data[CMD_BIT_NUM-1: 0] <= {CMD_BIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==CMD_ST)) begin
        rx_cmd_data[CMD_BIT_NUM-1: 0] <= {rx_cmd_data[CMD_BIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

assign rx_cmd_rd = ~rx_cmd_data[CMD_BIT_NUM-1];
assign rx_cmd_wr =  rx_cmd_data[CMD_BIT_NUM-1];

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_adc_data[ADC_DBIT_NUM-1: 0] <= {ADC_DBIT_NUM{1'b0}};
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & ((owt_rx_cur_st==ADC_DATA_ST) | (owt_rx_cur_st==NML_DATA_ST))) begin
        rx_adc_data[ADC_DBIT_NUM-1: 0] <= {rx_adc_data[ADC_DBIT_NUM-2: 0], (~rx_mcst_vld_zero | rx_mcst_vld_one)}; 
    end
    else;
end

assign rx_nml_data = rx_adc_data[OWT_DBIT_NUM-1: 0];

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_bit_done <= 1'b0;
    end
    else if(rx_vld & (owt_rx_cur_st==SYNC_TAIL_ST) & (rx_cnt_bit==(TAIL_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==CMD_ST) & (rx_cnt_bit==(CMD_BIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==ADC_DATA_ST) & (rx_cnt_bit==(ADC_DBIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else if((rx_mcst_vld_one | rx_mcst_vld_zero) & (owt_rx_cur_st==NML_DATA_ST) & (rx_cnt_bit==(OWT_DBIT_NUM-1))) begin
        rx_bit_done <= 1'b1;
    end
    else begin
        rx_bit_done <= 1'b0;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rx_cnt_bit <= CNT_MAX_W'(0);
    end
    else if(owt_rx_cur_st==IDLE_ST) begin
        if(rx_mcst_vld_zero) begin
            rx_cnt_bit <= (cnt_bit==(SYNC_BIT_NUM-1)) ? CNT_MAX_W'(0) : (rx_cnt_bit+1'b1);
        end
        else if(rx_mcst_vld_one) begin
            rx_cnt_bit <= CNT_MAX_W'(0);
        end
        else;
    end
    else if(owt_rx_cur_st==SYNC_TAIL_ST) begin
        if(rx_vld) begin
            rx_cnt_bit <= (rx_cnt_bit==(TAIL_BIT_NUM-1)) ? CNT_MAX_W'(0) : (rx_cnt_bit+1'b1);   
        end
        else;
    end
    else if(owt_rx_cur_st==CMD_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(CMD_BIT_NUM-1)) ? CNT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_rx_cur_st==ADC_DATA_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(ADC_DBIT_NUM-1)) ? CNT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else if(owt_rx_cur_st==NML_DATA_ST) begin
        if(rx_mcst_vld_one | rx_mcst_vld_zero) begin
            rx_cnt_bit <= (rx_cnt_bit==(OWT_DBIT_NUM-1)) ? CNT_MAX_W'(0) : (rx_cnt_bit+1'b1); 
        end
        else;
    end
    else begin
        rx_cnt_bit <= CNT_MAX_W'(0);
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
