//============================================================
//Module   : lv_wdg_ctrl
//Function : lv wdg scan cfg reg, wdg owt communicate.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_wdg_ctrl #(
    `include "lv_param.vh"
    parameter END_OF_LIST          = 1
)( 
    input  logic 		            i_wdg_scan_reg_en               ,
    output logic                    o_wdg_scan_reg_rd_req           ,
    output logic [REG_AW-1:     0]  o_wdg_scan_reg_addr             ,
    input  logic                    i_reg_wdg_scan_ack              ,
    input  logic [REG_DW-1:     0]  i_reg_wdg_scan_data             ,
    input  logic [REG_CRC_W-1:  0]  i_reg_wdg_scan_crc              ,
    output logic                    o_wdg_scan_crc_err              ,

    input  logic                    i_wdg_owt_en                    ,
    output logic                    o_wdg_owt_tx_adc_req            ,
    input  logic                    i_owt_tx_wdg_adc_ack            ,
    input  logic                    i_spi_rst_wdg                   ,

    input  logic                    i_fsm_wdg_owt_tx_req            ,

    input  logic                    i_owt_rx_wdg_rsp                ,
    output logic                    o_wdg_timeout_err               ,

    input  logic [1:            0]  i_com_config1_wdgtmo_config     ,
    input  logic [1:            0]  i_com_config1_wdgrefresh_config ,
    input  logic [1:            0]  i_com_config1_wdgcrc_config     ,

    input  logic                    i_clk                           ,
    input  logic                    i_rst_n
 );
//==================================
//local param delcaration
//==================================
localparam  WDG_250US_CYC_NUM                   =  250*CLK_M ; //one core clk cycle is (1000/48)ns, 250us has (250x1000)ns/(1000/48)ns = 250x48 cycle.
localparam  WDG_500US_CYC_NUM                   =  500*CLK_M ;
localparam WDG_1000US_CYC_NUM                   = 1000*CLK_M ;
localparam WDG_2000US_CYC_NUM                   = 2000*CLK_M ;
localparam [3: 0] WDG_SCANREG_TH                = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM}; //TH = threshold
localparam [3: 0] WDG_REFRESH_TH                = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM};
localparam [3: 0] WDG_TIMEOUT_TH                = {WDG_2000US_CYC_NUM, WDG_1000US_CYC_NUM, WDG_500US_CYC_NUM, WDG_250US_CYC_NUM};
localparam WDG_CNT_W                            = $clog2(WDG_2000US_CYC_NUM) ;
localparam SCAN_REG_NUM                         = 8;
localparam [SCAN_REG_NUM-1: 0] SCAN_REG_ADDR    = {7'h30, 7'h0B, 7'h0A, 7'h09, 7'h08, 7'h03, 7'h02, 7'h01} ;
localparam SCAN_PTR_W                           = $clog2(SCAN_REG_NUM) ;
//==================================
//var delcaration
//==================================
logic [WDG_CNT_W-1:     0]  wdg_scanreg_cnt         ;
logic [SCAN_PTR_W-1:    0]  wdg_scan_ptr            ;
logic [2*REG_DW-1:      0]  crc16to8_data_in        ;
logic [REG_CRC_W-1:     0]  crc16to8_out            ;
logic [WDG_CNT_W-1:     0]  wdg_refresh_cnt         ;
logic [WDG_CNT_W-1:     0]  wdg_timeout_cnt         ;
logic                       owt_in_tx_flag          ;
logic                       wdg_timeout_err         ;
logic                       fsm_wdg_owt_tx_req_ff   ;
logic                       lanch_wdg_owt_tx        ;
//==================================
//main code
//==================================

//wdg scan reg
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_scanreg_cnt <= WDG_CNT_W'(0);
    end
    else if(i_wdg_scan_reg_en) begin
        if(o_wdg_scan_reg_rd_req | i_reg_wdg_scan_ack) begin
            wdg_scanreg_cnt <= WDG_CNT_W'(0);        
        end
        else if(wdg_scanreg_cnt==(WDG_SCANREG_TH[i_com_config1_wdgcrc_config]-1)) begin
            wdg_scanreg_cnt <= WDG_CNT_W'(0);
        end
        else begin
            wdg_scanreg_cnt <= wdg_scanreg_cnt+1'b1;
        end
    end
    else begin
        wdg_scanreg_cnt <= WDG_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_scan_ptr <= SCAN_PTR_W'(0);
    end
    else if(wdg_scanreg_cnt==(WDG_SCANREG_TH[i_com_config1_wdgcrc_config]-1)) begin
        wdg_scan_ptr <= (wdg_scan_ptr==(SCAN_REG_NUM-1)) ? SCAN_PTR_W'(0) : (wdg_scan_ptr+1'b1);
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_scan_reg_rd_req <= 1'b0;
    end
    else if(~i_wdg_scan_reg_en) begin
        o_wdg_scan_reg_rd_req <= 1'b0;    
    end
    else if(i_reg_wdg_scan_ack) begin
        o_wdg_scan_reg_rd_req <= 1'b0;    
    end
    else if(wdg_scanreg_cnt==(WDG_SCANREG_TH[i_com_config1_wdgcrc_config]-1)) begin
        o_wdg_scan_reg_rd_req <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_scan_reg_addr <= REG_AW'(0);
    end
    else if(wdg_scanreg_cnt==(WDG_SCANREG_TH[i_com_config1_wdgcrc_config]-1)) begin
        o_wdg_scan_reg_addr <= SCAN_REG_ADDR[wdg_scan_ptr];
    end
    else;
end

assign crc16to8_data_in = {1'b1, o_wdg_scan_reg_addr, i_reg_wdg_scan_data};

crc16to8_parallel U_CRC16to8(
    .data_in(crc16to8_data_in    ),
    .crc_out(crc16to8_out        )
);

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_scan_crc_err <= 1'b0;
    end
    else begin
        o_wdg_scan_crc_err <= i_reg_wdg_scan_ack & (i_reg_wdg_scan_crc!=crc16to8_out);
    end
end

//wdg owt communication.
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_refresh_cnt <= WDG_CNT_W'(0);
    end
    else if(i_wdg_owt_en) begin
        if(o_wdg_owt_tx_adc_req | i_owt_tx_wdg_adc_ack | i_spi_rst_wdg) begin
            wdg_refresh_cnt <= WDG_CNT_W'(0);        
        end
        else if(wdg_refresh_cnt==(WDG_REFRESH_TH[i_com_config1_wdgrefresh_config]-1)) begin
            wdg_refresh_cnt <= WDG_CNT_W'(0);
        end
        else begin
            wdg_refresh_cnt <= wdg_refresh_cnt+1'b1;
        end
    end
    else begin
        wdg_refresh_cnt <= WDG_CNT_W'(0);    
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        fsm_wdg_owt_tx_req_ff <= 1'b0;
    end
    else begin
        fsm_wdg_owt_tx_req_ff <= i_fsm_wdg_owt_tx_req;
    end
end

assign lanch_wdg_owt_tx = i_fsm_wdg_owt_tx_req & ~fsm_wdg_owt_tx_req_ff;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_owt_tx_adc_req <= 1'b0;
    end
    else if(~i_wdg_owt_en) begin
        o_wdg_owt_tx_adc_req <= 1'b0;    
    end
    else if(i_owt_tx_wdg_adc_ack) begin
        o_wdg_owt_tx_adc_req <= 1'b0;    
    end
    else if((wdg_refresh_cnt==(WDG_REFRESH_TH[i_com_config1_wdgrefresh_config]-1)) || lanch_wdg_owt_tx) begin
        o_wdg_owt_tx_adc_req <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        owt_in_tx_flag <= 1'b0;
    end
    else if(~i_wdg_owt_en) begin
        owt_in_tx_flag <= 1'b0;    
    end
    else if(wdg_timeout_err) begin
        owt_in_tx_flag <= 1'b0;    
    end
    else if(o_wdg_owt_tx_adc_req | i_spi_rst_wdg) begin
        owt_in_tx_flag <= 1'b1;
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wdg_timeout_cnt <= WDG_CNT_W'(0);
    end
    else if(owt_in_tx_flag) begin
        if(i_owt_rx_wdg_rsp) begin
            wdg_timeout_cnt <= WDG_CNT_W'(0);        
        end
        else if(wdg_timeout_cnt==(WDG_TIMEOUT_TH[i_com_config1_wdgtmo_config]-1)) begin
            wdg_timeout_cnt <= WDG_CNT_W'(0);
        end
        else begin
            wdg_timeout_cnt <= wdg_timeout_cnt+1'b1;
        end
    end
    else begin
        wdg_timeout_cnt <= WDG_CNT_W'(0);    
    end
end

assign wdg_timeout_err = (wdg_timeout_cnt==(WDG_TIMEOUT_TH[i_com_config1_wdgtmo_config]-1));

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_wdg_timeout_err <= 1'b0;
    end
    else if(i_owt_rx_wdg_rsp) begin
        o_wdg_timeout_err <= 1'b0;    
    end
    else if(wdg_timeout_err) begin
        o_wdg_timeout_err <= 1'b1;
    end
    else;
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
