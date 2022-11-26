//============================================================
//Module   : crc8_serial
//Function : serial calc x^8+x^5+x^3+x^2+x+1 crc. 
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module crc8_serial #(
    parameter END_OF_LIST          = 1
)( 
    input  logic                i_vld                   ,
    input  logic                i_data                  ,
    input  logic                i_new_calc              ,
    output logic [7:         0] o_vld_crc               ,
    input  logic                i_clk	                ,
    input  logic                i_rst_n
 );
//==================================
//local param delcaration
//==================================

//==================================
//var delcaration
//==================================
logic [7:       0] crc_out ;
logic [7:       0] crc_old ;
//==================================
//main code
//==================================
assign crc_old  = (i_vld & i_new_calc) ? 8'hff : crc_out;

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
	    crc_out <= 8'hff;
    end
    else begin
        crc_out <= i_vld ? crc8_new(crc_old, i_data) : crc_out; 
    end
end

assign o_vld_crc = crc_out;

// LFSR for CRC8
 function [7:0] crc8_new; 
    input [7:0] crc8_old; 
    input       data    ; 
    begin
        crc8_new[0] = crc8_old[7] ^ data                ;
        crc8_new[1] = crc8_old[0] ^ crc8_old[7] ^ data  ;
        crc8_new[2] = crc8_old[1] ^ crc8_old[7] ^ data  ;
        crc8_new[3] = crc8_old[2] ^ crc8_old[7] ^ data  ;
        crc8_new[4] = crc8_old[3]                       ;
        crc8_new[5] = crc8_old[4] ^ crc8_old[7] ^ data  ;
        crc8_new[6] = crc8_old[5]                       ;
        crc8_new[7] = crc8_old[6]                       ;
    end
endfunction

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule
