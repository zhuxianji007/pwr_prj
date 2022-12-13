//============================================================
//Module   : rw_reg
//Function : control register write & read
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module rw_reg #(
    parameter DW                   = 8          ,
    parameter AW                   = 8          ,
    parameter CRC_W                = 8          ,
    parameter DEFAULT_VAL          = {DW{1'b0}} ,
    parameter REG_ADDR             = {AW{1'b0}} ,
    parameter SUPPORT_TEST_MODE_WR = 1'b1       ,
    parameter SUPPORT_TEST_MODE_RD = 1'b1       ,
    parameter SUPPORT_CFG_MODE_WR  = 1'b1       ,
    parameter SUPPORT_CFG_MODE_RD  = 1'b1       ,
    parameter SUPPORT_SPI_EN_WR    = 1'b1       ,
    parameter SUPPORT_SPI_EN_RD    = 1'b1       ,
    parameter SUPPORT_EFUSE_WR     = 1'b1       , 
    parameter END_OF_LIST          = 1
)( 
    input  logic                i_wen                   ,
    input  logic                i_ren                   ,
    input  logic                i_test_st_reg_en        ,
    input  logic                i_cfg_st_reg_en         ,
    input  logic                i_spi_ctrl_reg_en       ,
    input  logic                i_efuse_ctrl_reg_en     ,	
    input  logic [AW-1:     0]  i_addr                  ,
    input  logic [DW-1:     0]  i_wdata                 ,
    input  logic [CRC_W-1:  0]  i_crc_data              ,
    output logic [DW-1:     0]  o_rdata                 ,
    output logic [DW-1:     0]  o_reg_data              ,
    output logic [CRC_W-1:  0]  o_rcrc                  ,	
    input  logic                i_clk	                ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic 	            wen     ;
logic 	   	        ren     ;
logic 		        hit     ;
logic [CRC_W-1: 0]  crc_data;
//==================================
//main code
//==================================
assign hit = (i_addr==REG_ADDR);
assign wen = i_wen & hit & ((i_test_st_reg_en & SUPPORT_TEST_MODE_WR) | (i_cfg_st_reg_en & SUPPORT_CFG_MODE_WR) | (i_spi_ctrl_reg_en & SUPPORT_SPI_EN_WR) | (i_efuse_ctrl_reg_en & SUPPORT_EFUSE_WR));
assign ren = i_ren & hit & ((i_test_st_reg_en & SUPPORT_TEST_MODE_RD) | (i_cfg_st_reg_en & SUPPORT_CFG_MODE_RD) | (i_spi_ctrl_reg_en & SUPPORT_SPI_EN_RD));
  
always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        o_reg_data <= DEFAULT_VAL;
	    crc_data   <= {CRC_W{1'b0}};
    end
    else begin
        o_reg_data <= wen ? i_wdata : o_reg_data;
	    crc_data   <= wen ? i_crc_data : crc_data;
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

