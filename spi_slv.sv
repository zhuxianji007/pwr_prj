//============================================================
//Module   : spi slv
//Function : spi slave
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module spi_slv #(
    `include "com_param.vh"
    parameter END_OF_LIST = 1
)( 
    input  logic                    i_spi_sclk          ,
    input  logic                    i_spi_csb           ,//low active
    input  logic                    i_spi_mosi          ,
    output logic                    o_spi_miso          ,

    input  logic                    i_spi_slv_en        ,

    output logic                    o_spi_reg_wr_req    ,
    output logic                    o_spi_reg_rd_req    ,
    output logic [REG_AW-1:     0]  o_spi_reg_addr      ,
    output logic [REG_DW-1:     0]  o_spi_reg_wdata     ,
    output logic [REG_CRC_W-1:  0]  o_spi_reg_wcrc      ,

    input  logic                    i_reg_spi_wack      ,
    input  logic                    i_reg_spi_rack      ,
    input  logic [REG_DW-1:     0]  i_reg_spi_data      ,
    input  logic [REG_AW-1:     0]  i_reg_spi_addr      ,

    output logic                    o_spi_err           ,

    input  logic                    i_clk	            ,
    input  logic                    i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam SPI_RX_CMD_BIT_NUM    = 8                                                         ;
localparam SPI_RX_DATA_BIT_NUM   = 8                                                         ;
localparam SPI_RX_CRC_BIT_NUM    = 8                                                         ;
localparam SPI_RX_BIT_NUM        = SPI_RX_CMD_BIT_NUM+SPI_RX_DATA_BIT_NUM+SPI_RX_CRC_BIT_NUM ;
localparam MISO_RPTR_W           = $clog2(2*SPI_RX_BIT_NUM)                                  ;
localparam SPI_MIN_ACC_CNT_W     = 16                                                        ;
localparam SPI_MIN_ACC_GAP       = SPI_MIN_ACC_CNT_W'(1000)                                  ;
//==================================
//var delcaration
//==================================
logic [SPI_RX_BIT_NUM-1:      0] spi_rx_bit         ;
logic [SPI_RX_BIT_NUM-1:      0] slv_rsp_bit        ;
logic [2*SPI_RX_BIT_NUM-1:    0] miso_cache         ;
logic [MISO_RPTR_W-1:         0] miso_rptr          ;
logic                            spi_csb_sync       ;
logic                            spi_csb_sync_ff    ;
logic                            lanch_spi_access   ;
logic [SPI_RX_CMD_BIT_NUM-1:  0] spi_rx_cmd         ;
logic [SPI_RX_DATA_BIT_NUM-1: 0] spi_rx_data        ;
logic [SPI_RX_CRC_BIT_NUM-1:  0] spi_rx_crc         ;
logic [2*SPI_RX_BIT_NUM-1:    0] reg_rsp_data       ;
logic [2*SPI_RX_BIT_NUM-1:    0] crc16to8_data_in   ;
logic [SPI_RX_CRC_BIT_NUM-1:  0] crc16to8_out       ;
logic                            spi_crc_err        ;
logic                            spi_access_flag    ;
logic [SPI_MIN_ACC_CNT_W-1:   0] spi_acc_gap_cnt    ;
logic                            lt_acc_gap_err     ;//lt == less than.
logic                            spi_err            ;
logic                            spi_reg_wen        ;
logic                            spi_reg_ren        ;
logic                            reg_spi_ack        ;
logic [2:                     0] reg_spi_ack_ff     ;
//==================================
//main code
//==================================
always_ff@(posedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        spi_rx_bit <= SPI_RX_BIT_NUM'(0);
    end
    else begin
        spi_rx_bit <= {spi_rx_bit[SPI_RX_BIT_NUM-2: 0], i_spi_mosi};
    end
end

assign miso_cache = {slv_rsp_bit,spi_rx_bit};

always_ff@(negedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        miso_rptr <= (2*SPI_RX_BIT_NUM-1);
    end
    else begin
        miso_rptr <= (miso_rptr==0) ? (2*SPI_RX_BIT_NUM-1) : (miso_rptr-1'b1);
    end
end

always_ff@(negedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        o_spi_miso <= 1'b0;
    end
    else begin
        o_spi_miso <= miso_cache[miso_rptr];
    end
end

gnrl_sync #(
    .DW(1)
)U_SPI_CSB_SYNC(
    .i_data (i_spi_csb        ),
    .o_data (spi_csb_sync     ),
    .i_clk  (i_clk            ),
    .i_rst_n(i_rst_n          )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_csb_sync_ff <= 1'b1;
    end
    else begin
        spi_csb_sync_ff <= spi_csb_sync;
    end
end

assign lanch_spi_access = spi_csb_sync & ~spi_csb_sync_ff & i_spi_slv_en;

assign spi_rx_cmd  = spi_rx_bit[SPI_RX_BIT_NUM-1   -: SPI_RX_CMD_BIT_NUM ];
assign spi_rx_data = spi_rx_bit[SPI_RX_CRC_BIT_NUM +: SPI_RX_DATA_BIT_NUM];
assign spi_rx_crc  = spi_rx_bit[SPI_RX_CRC_BIT_NUM-1:                   0];

assign reg_rsp_data      = {~i_reg_spi_rack|i_reg_spi_wack, i_reg_spi_addr, i_reg_spi_data};
assign crc16to8_data_in  = reg_spi_ack ? reg_rsp_data : {spi_rx_cmd, spi_rx_data}          ;

crc16to8_parallel U_CRC16to8(
    .data_in(crc16to8_data_in    ),
    .crc_out(crc16to8_out        )
);

//if spi sclk not match 24 cycle multiple or data be corrupted, it will cause crc err.
assign spi_crc_err = (crc16to8_out != spi_rx_crc) & lanch_spi_access;

assign reg_spi_ack = i_reg_spi_wack | i_reg_spi_rack;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        reg_spi_ack_ff[2:0] <= 3'b0;
    end
    else begin
        reg_spi_ack_ff[2:0] <= {reg_spi_ack_ff[1:0], reg_spi_ack};
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_access_flag <= 1'b0;
    end
    else if(reg_spi_ack_ff[2]) begin //use reg_spi_ack_ff[2] for make sure spi_sclk steadily sample slv_rsp_bit.
        spi_access_flag <= 1'b0;
    end
    else if(lanch_spi_access) begin
        spi_access_flag <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_acc_gap_cnt <= SPI_MIN_ACC_CNT_W'(0);
    end
    else if(lanch_spi_access | reg_spi_ack_ff[2]) begin
        spi_acc_gap_cnt <= SPI_MIN_ACC_CNT_W'(0);    
    end
    else if(spi_access_flag) begin
        spi_acc_gap_cnt <= spi_acc_gap_cnt+1'b1;
    end
    else begin
        spi_acc_gap_cnt <= SPI_MIN_ACC_CNT_W'(0);
    end
end

assign lt_acc_gap_err = (spi_acc_gap_cnt < SPI_MIN_ACC_GAP) & lanch_spi_access;

assign spi_err = spi_crc_err | lt_acc_gap_err;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_err <= 1'b0;
    end
    else begin
        o_spi_err <= spi_err;
    end
end

assign spi_reg_wen = lanch_spi_access &  spi_rx_cmd[SPI_RX_CMD_BIT_NUM-1] & ~spi_err;
assign spi_reg_ren = lanch_spi_access & ~spi_rx_cmd[SPI_RX_CMD_BIT_NUM-1] & ~spi_err;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_reg_wr_req <= 1'b0;
        o_spi_reg_rd_req <= 1'b0;
    end
    else begin
        o_spi_reg_wr_req <= i_reg_spi_wack ? 1'b0 : (spi_reg_wen ? 1'b1 : o_spi_reg_wr_req);
        o_spi_reg_rd_req <= i_reg_spi_rack ? 1'b0 : (spi_reg_ren ? 1'b1 : o_spi_reg_rd_req);
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_reg_addr <= REG_AW'(0);   
    end
    else if(spi_reg_wen | spi_reg_ren) begin
        o_spi_reg_addr <= spi_rx_cmd[SPI_RX_CMD_BIT_NUM-2: 0];
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_reg_wdata <=    REG_DW'(0);
        o_spi_reg_wcrc  <= REG_CRC_W'(0);
    end
    else if(spi_reg_wen) begin
        o_spi_reg_wdata <= spi_rx_data ;
        o_spi_reg_wcrc  <= spi_rx_crc  ;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        slv_rsp_bit <= SPI_RX_BIT_NUM'(0);
    end
    else if(reg_spi_ack) begin
        slv_rsp_bit <= {reg_rsp_data, crc16to8_out};
    end
    else;
end
// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule
