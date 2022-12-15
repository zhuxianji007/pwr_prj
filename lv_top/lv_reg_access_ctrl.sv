//============================================================
//Module   : lv_reg_access_ctrl
//Function : reg access arbiter, trigger owt access, rsp to spi slv.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_reg_access_ctrl #(
    `include "lv_param.svh"
    parameter END_OF_LIST = 1
)( 
    input  logic                    i_wdg_scan_rac_rd_req   , //rac = reg_access_ctrl
    input  logic [REG_AW-1:     0]  i_wdg_scan_rac_addr     ,
    output logic                    o_rac_wdg_scan_ack      ,
    output logic [REG_DW-1:     0]  o_rac_wdg_scan_data     ,
    output logic [REG_CRC_W-1:  0]  o_rac_wdg_scan_crc      ,

    input  logic                    i_spi_rac_wr_req        ,
    input  logic                    i_spi_rac_rd_req        ,
    input  logic [REG_AW-1:     0]  i_spi_rac_addr          ,
    input  logic [REG_DW-1:     0]  i_spi_rac_wdata         ,
    input  logic [REG_CRC_W-1:  0]  i_spi_rac_wcrc          ,

    output logic                    o_rac_spi_wack          ,
    output logic                    o_rac_spi_rack          ,
    output logic [REG_DW-1:     0]  o_rac_spi_data          ,
    output logic [REG_AW-1:     0]  o_rac_spi_addr          ,

    output logic                    o_spi_owt_wr_req        ,
    output logic                    o_spi_owt_rd_req        ,
    output logic [REG_AW-1:     0]  o_spi_owt_addr          ,
    output logic [REG_DW-1:     0]  o_spi_owt_data          ,
    input  logic                    i_owt_tx_spi_ack        ,
    output logic                    o_spi_rst_wdg           ,

    input  logic                    i_owt_rx_spi_rsp        ,

    output logic                    o_rac_reg_ren           ,
    output logic                    o_rac_reg_wen           ,
    output logic [REG_AW-1:     0]  o_rac_reg_addr          ,
    output logic [REG_DW-1:     0]  o_rac_reg_wdata         ,
    output logic [REG_CRC_W-1:  0]  o_rac_reg_wcrc          ,

    input  logic                    i_reg_rac_wack          ,
    input  logic                    i_reg_rac_rack          ,
    input  logic [REG_DW-1:     0]  i_reg_rac_rdata         ,
    input  logic [REG_CRC_W-1:  0]  i_reg_rac_rcrc          ,

    input  logic                    i_hv_reg_vld            ,
    input  logic [REG_DW-1:     0]  i_hv_ang_reg_data       ,

    input  logic                    i_clk                   ,
    input  logic                    i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam COM_WR_REG_NUM                                = 9                                                        ;
localparam COM_RD_REG_NUM                                = 9                                                        ;
localparam integer COM_WR_REG_ADDR[COM_WR_REG_NUM-1: 0]  = {7'h0B,7'h0A,7'h09,7'h08,7'h07,7'h06,7'h03,7'h02,7'h01}  ;
localparam integer COM_RD_REG_ADDR[COM_RD_REG_NUM-1: 0]  = {7'h1F,7'h15,7'h14,7'h0D,7'h0C,7'h0A,7'h08,7'h07,7'h06}  ;
//==================================
//var delcaration
//==================================
logic                                       wdg_scan_grant          ;
logic [1:                   0]              wdg_scan_grant_ff       ;
logic                                       wdg_scan_grant_mask     ;
logic                                       trig_owt_wr_dgt_reg     ;
logic                                       trig_owt_rd_dgt_reg     ;//digital
logic                                       trig_owt_acc_ang_reg    ;//analog
logic                                       owt_wr_ack              ;
logic                                       owt_rd_ack              ;
logic [REG_DW-1:            0]              rac_spi_data            ;
logic                                       spi_owt_wr_req_ff       ;
logic                                       spi_owt_rd_req_ff       ;                 
//==================================
//main code
//==================================
assign wdg_scan_grant_mask  = ~(|wdg_scan_grant_ff[1: 1])                                                          ;
assign wdg_scan_grant       = i_wdg_scan_rac_rd_req & ~(i_spi_rac_wr_req | i_spi_rac_rd_req) & wdg_scan_grant_mask ;

assign wdg_scan_grant_ff[0] = wdg_scan_grant;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_scan_grant_ff[1: 1] <= 1'b0;
    end
    else begin
        wdg_scan_grant_ff[1: 1] <= wdg_scan_grant_ff[0: 0];
    end
end

assign o_rac_wdg_scan_ack  = i_reg_rac_rack & wdg_scan_grant_ff[1]  ;
assign o_rac_wdg_scan_data = i_reg_rac_rdata                        ;
assign o_rac_wdg_scan_crc  = i_reg_rac_rcrc                         ;

assign trig_owt_acc_ang_reg = (i_spi_rac_addr>=HV_ANALOG_REG_START_ADDR) & (i_spi_rac_addr<=HV_ANALOG_REG_END_ADDR);

always_comb begin: TRIG_OWT_WR_DGT_REG_BLK
    trig_owt_wr_dgt_reg = 1'b0;
    for(integer i=0; i<COM_WR_REG_NUM; i=i+1) begin: GEN_TRIG_OWT_WR_DGT_REG
        trig_owt_wr_dgt_reg = trig_owt_wr_dgt_reg | (i_spi_rac_addr==COM_WR_REG_ADDR[i]);
    end
end

always_comb begin: TRIG_OWT_RD_DGT_REG_BLK
    trig_owt_rd_dgt_reg = 1'b0;
    for(integer i=0; i<COM_RD_REG_NUM; i=i+1) begin: GEN_TRIG_OWT_RD_DGT_REG
        trig_owt_rd_dgt_reg = trig_owt_rd_dgt_reg | (i_spi_rac_addr==COM_RD_REG_ADDR[i]);
    end
end

assign o_spi_owt_wr_req = (trig_owt_wr_dgt_reg | trig_owt_acc_ang_reg) & i_spi_rac_wr_req;

assign o_spi_owt_rd_req = (trig_owt_rd_dgt_reg | trig_owt_acc_ang_reg) & i_spi_rac_rd_req;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_owt_wr_req_ff <= 1'b0;
    end
    else begin
        spi_owt_wr_req_ff <= o_spi_owt_wr_req;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_owt_rd_req_ff <= 1'b0;
    end
    else begin
        spi_owt_rd_req_ff <= o_spi_owt_rd_req;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_spi_rst_wdg <= 1'b0;
    end
    else if((o_spi_owt_wr_req & ~spi_owt_wr_req_ff) || (o_spi_owt_rd_req & ~spi_owt_rd_req_ff)) begin
        o_spi_rst_wdg <= 1'b1;
    end
    else begin
        o_spi_rst_wdg <= 1'b0;
    end
end

assign o_spi_owt_addr = i_spi_rac_addr;

assign o_spi_owt_data = i_spi_rac_wdata;

assign o_rac_reg_ren  = i_spi_rac_rd_req | wdg_scan_grant;

assign o_rac_reg_wen  = i_spi_rac_wr_req;

assign o_rac_reg_addr = (i_spi_rac_wr_req | i_spi_rac_rd_req) ? i_spi_rac_addr : i_wdg_scan_rac_addr;

assign o_rac_reg_wdata= i_spi_rac_wdata; 

assign o_rac_reg_wcrc = i_spi_rac_wcrc;
                       
assign rac_spi_data    = i_spi_rac_wr_req ? o_rac_reg_wdata : 
                         (trig_owt_acc_ang_reg ? i_hv_ang_reg_data : i_reg_rac_rdata);

assign o_rac_spi_wack = i_owt_tx_spi_ack  | (~trig_owt_wr_dgt_reg & ~trig_owt_acc_ang_reg & i_reg_rac_wack)                         ; 
assign o_rac_spi_rack = i_hv_reg_vld      | (~trig_owt_rd_dgt_reg & ~trig_owt_acc_ang_reg & i_reg_rac_rack & ~wdg_scan_grant_ff[1]) ;
assign o_rac_spi_data = rac_spi_data                                                                                                ;
assign o_rac_spi_addr = o_rac_reg_addr                                                                                              ;
// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule





