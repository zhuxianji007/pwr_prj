//============================================================
//Module   : rstn_merge
//Function : hardware rst & software rst merge.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module rstn_merge #(
    parameter END_OF_LIST = 1
)( 
    input  logic           i_hrst_n ,
    input  logic           i_srst_n ,
    output logic           o_rst_n
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
assign o_rst_n = i_hrst_n & i_srst_n;   

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
