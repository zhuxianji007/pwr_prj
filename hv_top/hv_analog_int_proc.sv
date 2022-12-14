//============================================================
//Module   : hv_analog_int_proc
//Function : hv analog int proc
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module hv_analog_int_proc #(
    `include "hv_param.svh"
    parameter END_OF_LIST          = 1
)(
    input  logic           i_hv_vcc_uv          ,
    input  logic           i_hv_vcc_ov          ,
    input  logic           i_hv_ot              ,
    input  logic           i_hv_oc              ,
    input  logic           i_hv_desat_flt       ,
    input  logic           i_hv_scp_flt         ,

    output logic           o_hv_vcc_uverr       ,
    output logic           o_hv_vcc_overr       ,
    output logic           o_hv_ot_err          ,
    output logic           o_hv_oc_err          ,
    output logic           o_hv_desat_err       ,
    output logic           o_hv_scp_err         ,

    input  logic           i_clk                ,
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
gnrl_sync #(
    .DW             (1                  ),
    .DEF_VAL        (1'b0               )
)U_HV_VCC_UVERR_SYNC(
    .i_data         (~i_hv_vcc_uv       ) ,
    .o_data         (o_hv_vcc_uverr     ) ,
    .i_clk	        (i_clk              ) ,
    .i_rst_n        (i_rst_n            )
);

gnrl_sync #(
    .DW             (1                  ),
    .DEF_VAL        (1'b0               )
)U_HV_VCC_OVERR_SYNC(
    .i_data         (i_hv_vcc_ov        ) ,
    .o_data         (o_hv_vcc_overr     ) ,
    .i_clk	        (i_clk              ) ,
    .i_rst_n        (i_rst_n            )
);

gnrl_sync #(
    .DW             (1                  ),
    .DEF_VAL        (1'b0               )
)U_HV_OT_SYNC(
    .i_data         (i_hv_ot            ) ,
    .o_data         (o_hv_ot_err        ) ,
    .i_clk	        (i_clk              ) ,
    .i_rst_n        (i_rst_n            )
);

gnrl_sync #(
    .DW             (1                  ),
    .DEF_VAL        (1'b0               )
)U_HV_OC_SYNC(
    .i_data         (i_hv_oc            ) ,
    .o_data         (o_hv_oc_err        ) ,
    .i_clk	        (i_clk              ) ,
    .i_rst_n        (i_rst_n            )
);

gnrl_sync #(
    .DW             (1                  ),
    .DEF_VAL        (1'b0               )
)U_HV_DESAT_FLT_SYNC(
    .i_data         (i_hv_desat_flt     ) ,
    .o_data         (o_hv_desat_err     ) ,
    .i_clk	        (i_clk              ) ,
    .i_rst_n        (i_rst_n            )
);

gnrl_sync #(
    .DW             (1                  ),
    .DEF_VAL        (1'b0               )
)U_HV_SCP_FLT_SYNC(
    .i_data         (i_hv_scp_flt       ) ,
    .o_data         (o_hv_scp_err       ) ,
    .i_clk	        (i_clk              ) ,
    .i_rst_n        (i_rst_n            )
);

// synopsys translate_off    
//==================================
//assertion
//==================================
//    
// synopsys translate_on    
endmodule
