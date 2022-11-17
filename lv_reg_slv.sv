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
    input  logic 		            i_spi_reg_ren                   ,
    input  logic                    i_spi_reg_wen                   ,
    input  logic [REG_AW-1:   0]    i_spi_reg_addr                  ,
    input  logic [REG_DW-1:   0]    i_spi_reg_wdata                 ,
    output logic                    o_reg_spi_rack                  ,
    output logic                    o_reg_spi_rstatus               ,
    output logic [REG_DW-1:   0]    o_reg_spi_rdata                 ,
    
    //inner flop-flip data
    input  logic [REG_DW-1:   0]    i_lvhv_device_id                ,
    input  logic                    i_int_bist_fail                 ,
    input  logic                    i_int_pwm_mmerr                 ,
    input  logic                    i_int_pwm_dterr                 ,
    input  logic                    i_int_wdg_err                   ,
    input  logic                    i_int_com_err                   ,
    input  logic                    i_int_crc_err                   ,
    input  logic                    i_int_spi_err                   ,
    input  logic [FSM_ST_W-1: 0]    i_lv_fsm_status                 ,
    input  logic [FSM_ST_W-1: 0]    i_hv_fsm_status                 ,

    //output to inner logic
    output logic                    o_mode_efuse_done               ,
    output logic                    o_mode_adc2_en                  ,
    output logic                    o_mode_adc1_en                  ,
    output logic                    o_mode_fsiso_en                 ,
    output logic                    o_mode_bist_en                  ,
    output logic                    o_mode_cfg_en                   ,
    output logic                    o_mode_normal_en                ,
    output logic                    o_mode_reset_en                 ,

    output logic                    o_com_config0_rtmon             ,
    output logic                    o_com_config0_comerr_mode       ,
    output logic [3:          0]    o_com_config0_comerr_config     ,

    output logic [1:          0]    o_com_config1_wdgintb_config    ,
    output logic [1:          0]    o_com_config1_wdgtmo_config     ,
    output logic [1:          0]    o_com_config1_wdgrefresh_config ,
    output logic [1:          0]    o_com_config1_wdgcrc_config     ,

    output logic                    o_status1_bist_fail             ,
    output logic                    o_status1_pwm_mmerr             ,
    output logic                    o_status1_pwm_dterr             ,
    output logic                    o_status1_wdg_err               ,
    output logic                    o_status1_com_err               ,
    output logic                    o_status1_crc_err               ,
    output logic                    o_status1_spi_err               ,

    //to mcu interrput
    output logic                    o_int_n              ,
    input  logic                    i_test_mode_status   ,
    input  logic                    i_cfg_mode_status    ,
    input  logic                    i_clk                ,
    input  logic                    i_rst_n                 //hardware rst.
 );
//==================================
//local param delcaration
//==================================
logic                  hrst_n               ;
logic                  srst_n               ;
logic                  rst_n                ;

logic                  spi_reg_wen          ;
logic                  spi_reg_ren          ;
logic [REG_AW-1:    0] spi_reg_addr         ;
logic [REG_DW-1:    0] spi_reg_wdata        ;
logic [REG_DW-1:    0] reg_spi_rdata        ;
logic [REG_CRC_W-1: 0] crc_data             ;

logic                  status1_lgc_wen      ;
logic                  lv_interrupt         ;

logic [REG_DW-1:    0] rdata_lvhv_device_id ;
logic [REG_DW-1:    0] rdata_mode           ;
logic [REG_DW-1:    0] rdata_com_config0    ;
logic [REG_DW-1:    0] rdata_com_config1    ;
logic [REG_DW-1:    0] rdata_status1        ;
logic [REG_DW-1:    0] rdata_mask1          ;

logic [REG_DW-1:    0] rdata_lv_fsm_status  ;
logic [REG_DW-1:    0] rdata_hv_fsm_status  ;

logic [REG_DW-1:    0] reg_mode             ;
logic [REG_DW-1:    0] reg_com_config0      ;
logic [REG_DW-1:    0] reg_com_config1      ;
logic [REG_DW-1:    0] reg_status1          ;
logic [REG_DW-1:    0] reg_mask1            ;
//==================================
//var delcaration
//==================================

//==================================
//main code
//==================================
assign hrst_n = i_rst_n        ;
assign srst_n = ~reg_mode[0:0] ;

rstn_merge U_RSTN_MERGE(
    .i_hrst_n   (hrst_n),
    .i_srst_n   (srst_n),
    .o_rst_n    (rst_n )
)

//instance regsister
//LVHV_DEVICE_ID REGISTER
ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (REG_AW'(0) ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_LVHV_DEVICE_ID(
    .i_ren                (spi_reg_ren                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_ff_data            (i_lvhv_device_id                             ),
    .o_rdata              (rdata_lvhv_device_id                         ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
 );

 //MODE REGISTER
 rw_reg #(
    .DW                     (7          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (7'h00      ),
    .REG_ADDR               (REG_AW'(1) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_MODE_H(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[7:1]                           ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mode[7:1]                              ),
    .o_reg_data           (reg_mode[7:1]                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
 );

 rw_reg #(
    .DW                     (1          ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (1'h0       ),
    .REG_ADDR               (REG_AW'(1) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_MODE_L(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata[0:0]                           ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mode[0:0]                              ),
    .o_reg_data           (reg_mode[0:0]                                ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (hrst_n                                       )
 );

 assign o_mode_efuse_done = reg_mode[7:7];
 assign o_mode_adc2_en    = reg_mode[6:6];
 assign o_mode_adc1_en    = reg_mode[5:5];
 assign o_mode_fsiso_en   = reg_mode[4:4];
 assign o_mode_bist_en    = reg_mode[3:3];
 assign o_mode_cfg_en     = reg_mode[2:2];
 assign o_mode_normal_en  = reg_mode[1:1];
 assign o_mode_reset_en   = reg_mode[0:0];

 //COM_CONFIG0 REGISTER
 rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h0A      ),
    .REG_ADDR               (REG_AW'(2) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_COM_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_com_config0                            ),
    .o_reg_data           (reg_com_config0                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
 );
 assign o_com_config_rtmon          = reg_com_config0[7:7];
 assign o_com_config_comerr_mode    = reg_com_config0[6:6];
 assign o_com_config_comerr_config  = reg_com_config0[3:0];

 //COM_CONFIG1 REGISTER
 rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'hFF      ),
    .REG_ADDR               (REG_AW'(3) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_COM_CONFIG(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_com_config1                            ),
    .o_reg_data           (reg_com_config1                              ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
 );

 assign o_com_config1_wdgintb_config    = reg_com_config1[7:6];
 assign o_com_config1_wdgtmo_config     = reg_com_config1[5:4];
 assign o_com_config1_wdgrefresh_config = reg_com_config1[3:2];
 assign o_com_config1_wdgcrc_config     = reg_com_config1[1:0];

//STATUS1 REGISTER
 assign status1_lgc_wen = {i_int_bist_fail, 1'b0, i_int_pwm_mmerr, i_int_pwm_dterr, 
                           i_int_wdg_err, i_int_com_err, i_int_crc_err, i_int_spi_err};
 rwc_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (REG_AW'(8) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_STATUS1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .o_rdata              (rdata_status1                                ),
    .o_reg_data           (reg_status1                                  ),
    .i_lgc_wen            (status1_lgc_wen                              ),
    .i_lgc_wdata          (8'hFF                                        ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
 );

 assign o_status1_bist_fail = reg_status1[7:7];
 assign o_status1_pwm_mmerr = reg_status1[5:5];
 assign o_status1_pwm_dterr = reg_status1[4:4];
 assign o_status1_wdg_err   = reg_status1[3:3];
 assign o_status1_com_err   = reg_status1[2:2];
 assign o_status1_crc_err   = reg_status1[1:1];
 assign o_status1_spi_err   = reg_status1[0:0];

//MASK1 REGISTER
 rw_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .CRC_W                  (REG_CRC_W  ),
    .DEFAULT_VAL            (8'h00      ),
    .REG_ADDR               (REG_AW'(9) ),
    .SUPPORT_TEST_MODE_WR   (1'b1       ),
    .SUPPORT_TEST_MODE_RD   (1'b1       ),
    .SUPPORT_CFG_MODE_WR    (1'b1       ),
    .SUPPORT_CFG_MODE_RD    (1'b1       )
 )U_MASK1(
    .i_ren                (spi_reg_ren                                  ),
    .i_wen                (spi_reg_wen                                  ),
    .i_test_mode_status   (i_test_mode_status                           ),
    .i_cfg_mode_status    (i_cfg_mode_status                            ),
    .i_addr               (spi_reg_addr                                 ),
    .i_wdata              (spi_reg_wdata                                ),
    .i_crc_data           ({REG_CRC_W{1'b0}}                            ),
    .o_rdata              (rdata_mask1                                  ),
    .o_reg_data           (reg_mask1                                    ),
    .o_rcrc               (                                             ),
    .i_clk                (i_clk                                        ),
    .i_rst_n              (rst_n                                        )
 );



 ro_reg #(
    .DW                     (REG_DW     ),
    .AW                     (REG_AW     ),
    .REG_ADDR               (REG_AW'(1) ),
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
    .i_rst_n              (rst_n                                        )
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
    .i_rst_n              (rst_n                                        )
 );

 

gen_reg_crc U_GEN_REG_CRC(
    .data_in    (i_spi_reg_wdata    ),
    .crc_en     (i_spi_reg_wen      ),
    .crc_out    (crc_data           ),
    .rst        (rst_n              ),
    .clk        (i_clk              )
);

//spi reg in
always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        spi_reg_ren <= 1'b0;
        spi_reg_wen <= 1'b0;
    end
    else begin
        spi_reg_ren <= i_spi_reg_ren;
        spi_reg_wen <= i_spi_reg_wen;
    end
end

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        spi_reg_addr  <= REG_AW'(0);
        spi_reg_wdata <= REG_DW'(0);
    end
    else begin
        spi_reg_addr  <= (i_spi_reg_ren | i_spi_reg_wen) ? i_spi_reg_addr  : spi_reg_addr ;
        spi_reg_wdata <= (i_spi_reg_wen                ) ? i_spi_reg_wdata : spi_reg_wdata;
    end
end

//rdata proc zone
always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rack <= 1'b0;
    end
    else begin
        o_reg_spi_rack <= spi_reg_ren;
    end
end

assign reg_spi_rdata = rdata_lvhv_device_id | rdata_mode | rdata_com_config0 | rdata_com_config1 | rdata_status1 | rdata_mask1;

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_reg_spi_rdata <= {REG_DW{1'b0}};
    end
    else begin
        o_reg_spi_rdata <= reg_spi_rdata;
    end
end

//interrupt proc
assign lv_interrupt = (reg_status1 & reg_mask1);

always_ff@(posedge i_clk or negedge rst_n) begin
    if(~rst_n) begin
        o_int_n <= 1'b1;
    end
    else begin
        o_int_n <= ~(|lv_interrupt);
    end
end



// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
