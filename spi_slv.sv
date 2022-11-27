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
    `include "lv_param.vh"
    parameter END_OF_LIST          = 1
)( 
    input  logic                i_spi_sclk      ,
    input  logic                i_spi_csb       ,//low active, hig==rst
    input  logic                i_spi_mosi      ,
    output logic                o_spi_miso      ,

    output logic                o_spi_reg_wen   ,
    output logic                o_spi_reg_ren   ,
    output logic [REG_AW-1: 0]  o_spi_reg_addr  ,
    output logic [REG_DW-1: 0]  o_spi_reg_wdata ,
    output logic                i_reg_spi_rack  ,
    input  logic [REG_DW-1: 0]  i_reg_spi_rdata ,

    output logic                o_spi_owt_wen   ,
    output logic                o_spi_owt_ren   ,
    output logic [REG_AW-1: 0]  o_spi_owt_addr  ,
    output logic [REG_DW-1: 0]  o_spi_owt_wdata ,

    output logic                o_spi_err       ,

    input  logic                i_clk	        ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam SPI_MIX_ACC_CNT_W    = 16                                                        ;
localparam SPI_MIX_ACC_GAP      = SPI_MIX_ACC_CNT_W'(100)                                   ;
localparam SPI_RX_CMD_BIT_NUM   = 8                                                         ;
localparam SPI_RX_DATA_BIT_NUM  = 8                                                         ;
localparam SPI_RX_CRC_BIT_NUM   = 8                                                         ;
localparam SPI_RX_CRC_START_CNT = SPI_RX_CMD_BIT_NUM+SPI_RX_DATA_BIT_NUM                    ;
localparam SPI_RX_BIT_NUM       = SPI_RX_CMD_BIT_NUM+SPI_RX_DATA_BIT_NUM+SPI_RX_CRC_BIT_NUM ;
localparam SPI_RX_CNT_W         = $clog2(SPI_RX_BIT_NUM)                                    ;
//==================================
//var delcaration
//==================================
logic [SPI_RX_BIT_CNT_W-1:    0] spi_rx_bit_cnt     ;
logic [SPI_MIX_ACC_CNT_W-1:   0] spi_acc_gap_cnt    ;
logic [SPI_RX_CMD_BIT_NUM-1:  0] spi_rx_cmd         ;
logic [SPI_RX_DATA_BIT_NUM-1: 0] spi_rx_data        ;
logic [SPI_RX_CRC_BIT_NUM-1:  0] spi_rx_crc         ;
logic [SPI_RX_CRC_BIT_NUM-1:  0] crc8_gen_o_crc_bit ;
logic                            spi_rx_done        ;
logic                            spi_crc_err        ;
logic                            spi_mismatch_err   ;
//==================================
//main code
//==================================
always_ff@(posedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        spi_rx_bit_cnt <= SPI_RX_BIT_CNT_W'(0);
    end
    else begin
        spi_rx_bit_cnt <= spi_rx_bit_cnt + 1'b1;
    end
end

always_ff@(posedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        spi_rx_done <= 1'b0;
    end
    else if(spi_rx_bit_cnt==(SPI_RX_BIT_NUM-1)) begin
        spi_rx_done <= 1'b1;
    end;
    else;
end

always_ff@(posedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        spi_rx_cmd <= SPI_RX_CMD_BIT_NUM'(0);
    end
    else if(spi_rx_bit_cnt<SPI_RX_CMD_BIT_NUM) begin
        spi_rx_cmd <= {spi_rx_cmd[SPI_RX_CMD_BIT_NUM-2: 0], i_spi_mosi};
    end
    else;
end

always_ff@(posedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        spi_rx_data <= SPI_RX_DATA_BIT_NUM'(0);
    end
    else if((spi_rx_bit_cnt<SPI_RX_CRC_START_CNT) & (spi_rx_bit_cnt>=SPI_RX_CMD_BIT_NUM)) begin
        spi_rx_data <= {spi_rx_data[SPI_RX_DATA_BIT_NUM-2: 0], i_spi_mosi};
    end
    else;
end

always_ff@(posedge i_spi_sclk or posedge i_spi_csb) begin
    if(i_spi_csb) begin
        spi_rx_crc <= SPI_RX_CRC_BIT_NUM'(0);
    end
    else if((spi_rx_bit_cnt<SPI_RX_BIT_NUM) & (spi_rx_bit_cnt>=SPI_RX_CRC_START_CNT)) begin
        spi_rx_crc <= {spi_rx_crc[SPI_RX_CRC_BIT_NUM-2: 0], i_spi_mosi};
    end
    else;
end

assign crc8_gen_i_vld       = (spi_rx_bit_cnt<SPI_RX_CRC_START_CNT) ;
assign crc8_gen_i_vld_bit   = i_spi_mosi                            ;
assign crc8_gen_i_start     = (spi_rx_bit_cnt==SPI_RX_BIT_CNT_W'(0));

crc8_serial U_CRC8_GEN(
    .i_vld             (crc8_gen_i_vld     ),
    .i_data            (crc8_gen_i_vld_bit ),
    .i_new_calc        (crc8_gen_i_start   ),
    .o_vld_crc         (crc8_gen_o_crc_bit ),
    .i_clk	           (i_clk         ),
    .i_rst_n           (i_rst_n        )
);

assign spi_crc_err = (spi_rx_crc!=crc8_gen_o_crc_bit);

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule

