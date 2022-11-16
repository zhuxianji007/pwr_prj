//============================================================
//Module   : lv_reg_slv
//Function : regsiter instance & access ctrl.
//File Tree: lv_reg_slv
//            |--ro_reg
//            |--rw_reg
//            |--rwc_reg
//            |--wo_reg
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_reg_slv #(
    `include "lv_param.vh"
    parameter END_OF_LIST          = 1
)(
    //spi reg access interface 
    input  logic 		            i_spi_reg_ren        ,
    input  logic                    i_spi_reg_wen        ,
    input  logic [REG_AW-1:   0]    i_spi_reg_addr       ,
    input  logic [REG_DW-1:   0]    i_spi_reg_wdata      ,
    output logic                    o_reg_spi_rack       ,
    output logic                    o_reg_spi_rstatus    ,
    output logic [REG_DW-1:   0]    o_reg_spi_rdata      ,
    
    //inner flop-flip data
    input  logic [FSM_ST_W-1: 0]    i_lv_fsm_status      ,
    input  logic [FSM_ST_W-1: 0]    i_hv_fsm_status      ,

    //output to inner logic
    output logic                    o_mode1_reset_en     ,
    output logic

    input  logic                    i_test_mode_status   ,
    input  logic                    i_cfg_mode_status    ,
    input  logic                    i_clk                ,
    input  logic                    i_rst_n
 );
//==================================
//local param delcaration
//==================================
logic                  spi_reg_wen         ;
logic                  spi_reg_ren         ;
logic [REG_AW-1:    0] spi_reg_addr        ;
logic [REG_DW-1:    0] spi_reg_wdata       ;
logic [REG_DW-1:    0] reg_spi_rdata       ;
logic [REG_CRC_W-1: 0] crc_data            ;

logic [REG_DW-1:    0] rdata_lv_fsm_status ;
logic [REG_DW-1:    0] rdata_hv_fsm_status ;
logic [REG_DW-1:    0] rdata_mode1         ;

logic [REG_DW-1:    0] reg_data_mode1      ;
//==================================
//var delcaration
//==================================

//==================================
//main code
//==================================

//instance regsister
 ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (REG_AW'(0) ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_LV_FSM_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({{(REG_DW-FSM_ST_W){1'b0}},i_lv_fsm_status}  ),
    .o_rdata              (rdata_lv_fsm_status                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
 );

  ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (REG_AW'(1) ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_HV_FSM_STATUS(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            ({{(REG_DW-FSM_ST_W){1'b0}},i_hv_fsm_status}  ),
    .o_rdata              (rdata_hv_fsm_status                          ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
 );

 rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            ({DW{1'b0}} ),
    .REG_ADDR               (REG_AW'(2) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_MODE1(
    .i_ren                (spi_reg_ren                                  ),
    .i_ren                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mode1                                  ),
    .o_reg_data           (reg_data_mode1                               ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (i_rst_n                                      )
 );

reg_crc U_REG_CRC(
    .data_in    (i_spi_reg_wdata    ),
    .crc_en     (i_spi_reg_wen      ),
    .crc_out    (crc_data           ),
    .rst        (i_rst_n            ),
    .clk        (i_clk              )
);

//spi reg in
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_reg_ren <= 1'b0;
        spi_reg_wen <= 1'b0;
    end
    else begin
        spi_reg_ren <= i_spi_reg_ren;
        spi_reg_wen <= i_spi_reg_wen;
    end
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        spi_reg_addr  <= REG_AW'(0);
        spi_reg_wdata <= REG_DW'(0);
    end
    else begin
        spi_reg_addr  <= (i_spi_reg_ren | i_spi_reg_wen) ? i_spi_reg_addr  : spi_reg_addr ;
        spi_reg_wdata <= (i_spi_reg_wen                ) ? i_spi_reg_wdata : spi_reg_wdata;
    end
end

//rdata proc zone
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_reg_spi_rack <= 1'b0;
    end
    else begin
        o_reg_spi_rack <= spi_reg_ren;
    end
end

assign reg_spi_rdata = rdata_lv_fsm_status | rdata_hv_fsm_status | rdata_mode1;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_reg_spi_rdata <= {REG_DW{1'b0}};
    end
    else begin
        o_reg_spi_rdata <= reg_spi_rdata;
    end
end

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule