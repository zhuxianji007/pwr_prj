//============================================================
//Module   : lv_ctrl_fsm
//Function : low voltage die, ctrl fsm
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module lv_ctrl_fsm #(
    `include "lv_param.vh"
    parameter END_OF_LIST          = 1
)( 
    input  logic           i_pwr_on        ,
    input  logic           i_test_mode     ,
    input  logic           i_reg_efuse_vld ,//load efuse's data to register, come frome register.
    input  logic           i_reg_efuse_done,//come from register.	
    input  logic           i_fsenb_n       ,//0: vld; 1: no_vld
    input  logic           i_ow_com_err    ,//one wire bus communicate voilate protocol or crc chk err.
    input  logic           i_ow_wdg_err    ,//one wire bus lost ack.
    input  logic           i_spi_err       ,//
	
    input  logic           i_clk	      ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================

//==================================
//main code
//==================================
assign hit = (i_addr==REG_ADDR);
assign wen = i_wen & hit & ((i_test_mode_status & SUPPORT_TEST_MODE_WR) | (i_cfg_mode_status & SUPPORT_CFG_MODE_WR));
assign ren = i_ren & hit & ((i_test_mode_status & SUPPORT_TEST_MODE_RD) | (i_cfg_mode_status & SUPPORT_CFG_MODE_RD));
  
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
         o_reg_data <= DEFAULT_VAL;
	   crc_data <= {CRC_W{1'b0}};
    end
    else begin
         o_reg_data <= wen ? i_wdata : o_reg_odata;
	   crc_data <= wen ? i_crc_data : crc_data;
    end
end
	
    
assign o_rdata = ren ? o_reg_data : {DW{1'b0}};
assign o_rcrc  = ren ? crc_data   : {CRC_W{1'b0}};

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON
singal_wr_rd_chk : assert property(wr_rd_chk);
property wr_rd_chk;
	@(posedge i_clk) (wen ^ ren);
endproperty
`endif
// synopsys translate_on    
endmodule
