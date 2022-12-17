//============================================================
//Module   : hv_reg_access_ctrl
//Function : reg access arbiter, rsp to spi slv.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_reg_access_ctrl #(
    `include "hv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                            i_wdg_scan_rac_rd_req   , //rac = reg_access_ctrl
    input  logic [REG_AW-1:             0]  i_wdg_scan_rac_addr     ,
    output logic                            o_rac_wdg_scan_ack      ,
    output logic [REG_DW-1:             0]  o_rac_wdg_scan_data     ,
    output logic [REG_CRC_W-1:          0]  o_rac_wdg_scan_crc      ,

    input  logic                            i_spi_rac_wr_req        ,
    input  logic                            i_spi_rac_rd_req        ,
    input  logic [REG_AW-1:             0]  i_spi_rac_addr          ,
    input  logic [REG_DW-1:             0]  i_spi_rac_wdata         ,
    input  logic [REG_CRC_W-1:          0]  i_spi_rac_wcrc          ,

    output logic                            o_rac_spi_wack          ,
    output logic                            o_rac_spi_rack          ,
    output logic [REG_DW-1:             0]  o_rac_spi_data          ,
    output logic [REG_AW-1:             0]  o_rac_spi_addr          ,

    input  logic                            i_owt_rx_rac_vld        ,
    input  logic [OWT_CMD_BIT_NUM-1:    0]  i_owt_rx_rac_cmd        ,
    input  logic [OWT_DATA_BIT_NUM-1:   0]  i_owt_rx_rac_data       ,
    input  logic [OWT_CRC_BIT_NUM-1:    0]  i_owt_rx_rac_crc        ,
    input  logic                            i_owt_rx_rac_status     ,

    output logic                            o_rac_owt_tx_wr_cmd_vld ,
    output logic                            o_rac_owt_tx_rd_cmd_vld ,
    output logic [REG_AW-1:             0]  o_rac_owt_tx_addr       ,
    output logic [OWT_ADCD_BIT_NUM-1:   0]  o_rac_owt_tx_data       ,

    input  logic [ADC_DW-1:             0]  i_adc1_data             ,
    input  logic [ADC_DW-1:             0]  i_adc2_data             ,

    output logic                            o_rac_reg_ren           ,
    output logic                            o_rac_reg_wen           ,
    output logic [REG_AW-1:             0]  o_rac_reg_addr          ,
    output logic [REG_DW-1:             0]  o_rac_reg_wdata         ,
    output logic [REG_CRC_W-1:          0]  o_rac_reg_wcrc          ,

    input  logic                            i_reg_rac_wack          ,
    input  logic                            i_reg_rac_rack          ,
    input  logic [REG_DW-1:             0]  i_reg_rac_rdata         ,
    input  logic [REG_CRC_W-1:          0]  i_reg_rac_rcrc          ,

    input  logic                            i_clk                   ,
    input  logic                            i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic                                       owt_rx_reg_wen              ;
logic                                       owt_rx_reg_ren              ;
logic [REG_AW-1:            0]              owt_rx_reg_addr             ;
logic [REG_DW-1:            0]              owt_rx_reg_wdata            ;
logic [REG_CRC_W-1:         0]              owt_rx_reg_wcrc             ; 

logic                                       spi_reg_wen                 ;
logic                                       spi_reg_ren                 ;

logic                                       owt_grant                   ;
logic [2:                   0]              owt_grant_ff                ;
logic                                       wdg_scan_grant              ;
logic [2:                   0]              wdg_scan_grant_ff           ;
logic                                       wdg_scan_grant_mask         ;
logic                                       spi_grant                   ;
logic [2:                   0]              spi_grant_ff                ;
logic                                       spi_grant_mask              ;

logic                                       owt_wr_ack                  ;
logic                                       owt_rd_ack                  ;
logic [REG_DW-1:            0]              rac_spi_data                ;
logic [REG_AW-1:            0]              rac_spi_addr                ;
logic [REG_AW-1:            0]              rac_reg_addr_ff             ;  
logic                                       lanch_last_owt_tx           ;  

logic                                       tx_cmd_lock                 ;
//==================================
//main code
//==================================
assign owt_rx_reg_wen   = i_owt_rx_rac_vld & ~i_owt_rx_rac_status & i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-1] ;
assign owt_rx_reg_ren   = i_owt_rx_rac_vld & ~i_owt_rx_rac_status & i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-1] ;
assign owt_rx_reg_addr  = i_owt_rx_rac_cmd[OWT_CMD_BIT_NUM-2: 0]                                        ;
assign owt_rx_reg_wdata = i_owt_rx_rac_data                                                             ;
assign owt_rx_reg_wcrc  = i_owt_rx_rac_crc                                                              ;

assign owt_grant        = owt_rx_reg_ren    ;
assign owt_grant_ff[0]  = owt_grant         ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_grant_ff[2: 1] <= 2'b0;
    end
    else begin
        owt_grant_ff[2: 1] <= owt_grant_ff[1: 0];
    end
end

assign spi_grant_mask   = ~(|spi_grant_ff[2: 1])                                                                       ;
assign spi_grant        = (i_spi_rac_wr_req | i_spi_rac_rd_req) & ~(owt_rx_reg_wen | owt_rx_reg_ren) & spi_grant_mask  ;
assign spi_reg_wen      = i_spi_rac_wr_req & spi_grant;
assign spi_reg_ren      = i_spi_rac_rd_req & spi_grant;

assign spi_grant_ff[0] = spi_grant;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_grant_ff[2: 1] <= 2'b0;
    end
    else begin
        spi_grant_ff[2: 1] <= spi_grant_ff[1: 0];
    end
end

assign wdg_scan_grant_mask  = ~(|wdg_scan_grant_ff[2: 1])                                                          ;
assign wdg_scan_grant       = i_wdg_scan_rac_rd_req & ~(i_spi_rac_wr_req | i_spi_rac_rd_req) & wdg_scan_grant_mask ;

assign wdg_scan_grant_ff[0] = wdg_scan_grant;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_scan_grant_ff[2: 1] <= 2'b0;
    end
    else begin
        wdg_scan_grant_ff[2: 1] <= wdg_scan_grant_ff[1: 0];
    end
end

assign o_rac_wdg_scan_ack  = i_reg_rac_rack & wdg_scan_grant_ff[2]  ;
assign o_rac_wdg_scan_data = i_reg_rac_rdata                        ;
assign o_rac_wdg_scan_crc  = i_reg_rac_rcrc                         ;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_ren <= 1'b0;
    end
    else begin
        o_rac_reg_ren <= owt_rx_reg_ren | spi_reg_ren | wdg_scan_grant;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_wen <= 1'b0;
    end
    else begin
        o_rac_reg_wen <= owt_rx_reg_wen | spi_reg_wen;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_addr <= REG_AW'(0);
    end
    else if(owt_rx_reg_wen | owt_rx_reg_ren) begin
        o_rac_reg_addr <= owt_rx_reg_addr;    
    end
    else if(spi_reg_wen | spi_reg_ren) begin
        o_rac_reg_addr <= i_spi_rac_addr;
    end
    else if(wdg_scan_grant) begin
        o_rac_reg_addr <= i_wdg_scan_rac_addr;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        rac_reg_addr_ff <= REG_AW'(0);
    end
    else begin
        rac_reg_addr_ff <= o_rac_reg_addr;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_wdata <= REG_DW'(0);
    end
    else if(owt_rx_reg_wen) begin
        o_rac_reg_wdata <= owt_rx_reg_wdata;
    end
    else if(spi_reg_wen) begin
        o_rac_reg_wdata <= i_spi_rac_wdata;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_reg_wcrc <= REG_CRC_W'(0);
    end
    else if(owt_rx_reg_wen) begin
        o_rac_reg_wcrc <= owt_rx_reg_wcrc;
    end
    else if(i_spi_rac_wr_req) begin
        o_rac_reg_wcrc <= i_spi_rac_wcrc;
    end
    else;
end
                       
assign rac_spi_data   = i_reg_rac_wack ? o_rac_reg_wdata : i_reg_rac_rdata;
assign rac_spi_addr   = i_reg_rac_wack ? o_rac_reg_addr  : rac_reg_addr_ff;

assign o_rac_spi_wack = i_reg_rac_wack & spi_grant_ff[1] ; 
assign o_rac_spi_rack = i_reg_rac_rack & spi_grant_ff[2] ;
assign o_rac_spi_data = rac_spi_data                     ;
assign o_rac_spi_addr = rac_spi_addr                     ;


always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_owt_tx_wr_cmd_vld <= 1'b0;
        o_rac_owt_tx_rd_cmd_vld <= 1'b0;        
    end
    else begin
        o_rac_owt_tx_wr_cmd_vld <= (i_reg_rac_wack & owt_grant_ff[1]) | (lanch_last_owt_tx & (tx_cmd_lock==WR_OP)); 
        o_rac_owt_tx_rd_cmd_vld <= (i_reg_rac_rack & owt_grant_ff[2]) | (lanch_last_owt_tx & (tx_cmd_lock==RD_OP));           
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        tx_cmd_lock <= WR_OP;
    end
    else if(i_reg_rac_wack & owt_grant_ff[1]) begin
        tx_cmd_lock <= WR_OP;    
    end
    else if(i_reg_rac_rack & owt_grant_ff[2]) begin
        tx_cmd_lock <= RD_OP;    
    end
    else;
end


always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_owt_tx_addr <= REG_AW'(0);
    end
    else if(i_reg_rac_wack & owt_grant_ff[1]) begin
        o_rac_owt_tx_addr <= o_rac_reg_addr;    
    end
    else if(i_reg_rac_rack & owt_grant_ff[2]) begin
        o_rac_owt_tx_addr <= rac_reg_addr_ff;    
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_rac_owt_tx_data <= REG_DW'(0);
    end
    else if(i_reg_rac_wack & owt_grant_ff[1]) begin
        o_rac_owt_tx_data <= {{(OWT_ADCD_BIT_NUM-REG_DW){1'b0}}, o_rac_reg_wdata};    
    end
    else if(i_reg_rac_rack & owt_grant_ff[2]) begin
        o_rac_owt_tx_data <= (rac_reg_addr_ff==REQ_ADC_ADDR) ? {i_adc2_data, i_adc1_data} : {{(OWT_ADCD_BIT_NUM-REG_DW){1'b0}}, i_reg_rac_rdata};    
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        lanch_last_owt_tx <= 1'b0;
    end
    else begin
        lanch_last_owt_tx <= i_owt_rx_rac_vld & i_owt_rx_rac_status;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule


