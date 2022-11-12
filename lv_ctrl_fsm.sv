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
    input  logic           i_efuse_vld     ,//load efuse's data to register, come frome register.
    input  logic           i_efuse_done    ,//come from register.	
    input  logic           i_fsenb_n       ,//0: vld; 1: no_vld
    input  logic           i_ow_com_err    ,//one wire bus communicate voilate protocol or crc chk err.
    input  logic           i_ow_wdg_err    ,//one wire bus lost ack.
    input  logic           i_spi_err       ,//spi bus communitcate voilate protocol or crc chk err.
    input  logic           i_crc_wdg_err   ,//watch dog scan cfg register,and chk its crc.if chk result is uncorrect, generate this err.
    input  logic           i_lv_pwm_dt_err ,//lv pwm deadtime err.
    input  logic           i_lv_pwm_mm_err ,//lv pwm mismatch err.
    input  logic           i_lv_vsup_uv_err,//lv voltage supply under voltage err.
    input  logic           i_lv_vsup_ov_err,//lv voltage supply over voltage.
    input  logic           i_hv_vcc_uv_err ,//hv voltage under voltage err.
    input  logic           i_hv_vcc_ov_err ,//hv voltage over voltage err.
    input  logic           i_hv_ot_err     ,//hv over temperature err.
    input  logic           i_hv_oc_err     ,//hv over current err.
    input  logic           i_hv_desat_err  ,
    input  logic           i_hv_scp_err    ,//hv short circuit err.
	
	
    input  logic           i_clk	      ,
    input  logic           i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic lvhv_err0;
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
