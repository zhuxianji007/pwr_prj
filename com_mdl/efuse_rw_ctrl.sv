//============================================================
//Module   : efuse_rw_ctrl
//Function : transform 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module efuse_rw_ctrl #(
    parameter EFUSE_AW          = 7 ,
    parameter EFUSE_DATA_NUM    = 8 ,
    parameter EFUSE_DW          = 8 ,
    parameter END_OF_LIST       = 1
)( 
    input  logic                                        i_efuse_wmode       ,//1: io_efuse_setb ctrl efuse rw; 0: inner lgc ctrl efuse rw.
    input  logic                                        i_io_efuse_setb     ,//10us meas write, 500ns means read.
    input  logic                                        i_efuse_wr_req      ,
    input  logic                                        i_efuse_rd_req      ,
    input  logic [EFUSE_AW-1:       0]                  i_efuse_addr        ,
    input  logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]   i_efuse_wdata       ,
    output logic                                        o_efuse_done        ,
    output logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]   o_efuse_rdata       ,

    output logic                                        o_efuse_xxx         ,
    output logic                                        o_efuse_xxx         ,

    input  logic                                        i_clk               ,
    input  logic                                        i_rst_n
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

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule

