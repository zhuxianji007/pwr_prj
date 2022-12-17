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
    parameter EFUSE_SPEC        = 0 ,//0: 8x8; 1: 16x8.        
    parameter END_OF_LIST       = 1
)( 
    input  logic                                        i_efuse_wmode       ,//1: io_efuse_setb ctrl efuse rw; 0: inner lgc ctrl efuse rw.
    input  logic                                        i_io_efuse_setb     ,//10us meas write, 500ns means read.
    input  logic                                        i_efuse_wr_p        ,
    input  logic                                        i_efuse_rd_p        ,
    input  logic [EFUSE_AW-1:       0]                  i_efuse_addr        ,
    input  logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]   i_efuse_wdata       ,
    output logic                                        o_efuse_op_finish   ,
    output logic                                        o_efuse_reg_update  ,//efuse update data to reg bank.
    output logic [EFUSE_DATA_NUM-1: 0][EFUSE_DW-1: 0]   o_efuse_reg_data    ,

    input  logic                                        i_efuse_load_req    ,
    output logic                                        o_efuse_load_done   , //hardware lanch, indicate efuse have load done.

    output logic                                        o_efuse_rd          ,
    output logic                                        o_efuse_pg          ,
    output logic                                        o_efuse_setb        ,
    output logic [EFUSE_AW:         1]                  o_efuse_addr        ,
    input  logic [EFUSE_DW-1:       0]                  i_efuse_rdata       ,     

    input  logic                                        i_clk               ,
    input  logic                                        i_rst_n
);
//==================================
//local param delcaration
//==================================
localparam  TPW_CYC_NUM = (10000*CLK_M+999)/1000        ;//one core clk cycle is (1000/48)ns, 10us has (10000)ns/(1000/48)ns.
localparam TPSA_CYC_NUM = (200*CLK_M+999)/1000          ;//+999, for ceil to an integer. 
localparam TPHA_CYC_NUM = (200*CLK_M+999)/1000          ;
localparam TPDS_CYC_NUM = TPHA_CYC_NUM+TPSA_CYC_NUM     ;
localparam TPSP_CYC_NUM = (500*CLK_M+999)/1000          ;
localparam TPHP_CYC_NUM = (200*CLK_M+999)/1000          ;

localparam  TRW_CYC_NUM = (500*CLK_M+999)/1000          ;
localparam TRSA_CYC_NUM = (200*CLK_M+999)/1000          ;
localparam TRHA_CYC_NUM = (200*CLK_M+999)/1000          ;
localparam TRDS_CYC_NUM = TRSA_CYC_NUM+TRHA_CYC_NUM     ;
localparam TRSR_CYC_NUM = (200*CLK_M+999)/1000          ;
localparam TRHR_CYC_NUM = (200*CLK_M+999)/1000          ;
localparam  TDR_CYC_NUM = (200*CLK_M+999)/1000          ; 
//==================================
//var delcaration
//==================================
logic [EFUSE_AW-1:   0] op_addr; //op=operation
//==================================
//main code
//==================================
generate
    if(EFUSE_SPEC==0) begin: 8_8_SPEC
        assign o_efuse_addr[1] = op_addr[0];
        assign o_efuse_addr[2] = op_addr[1];
        assign o_efuse_addr[3] = op_addr[2];
        assign o_efuse_addr[6] = op_addr[3];
        assign o_efuse_addr[5] = op_addr[4];
        assign o_efuse_addr[4] = op_addr[5];   
    end
    else begin: 16_8_SPEC
        assign o_efuse_addr[1] = op_addr[0];
        assign o_efuse_addr[2] = op_addr[1];
        assign o_efuse_addr[3] = op_addr[2];
        assign o_efuse_addr[5] = op_addr[3];
        assign o_efuse_addr[7] = op_addr[4];
        assign o_efuse_addr[6] = op_addr[5];
        assign o_efuse_addr[4] = op_addr[6];
    end
endgenerate


    

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule





