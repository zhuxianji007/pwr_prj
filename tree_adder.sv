//============================================================
//Module   : tree_adder
//Function : tree structure addr.
//File Tree: 
//-------------------------------------------------------------
//Update History
//-------------------------------------------------------------
//Rev.level     Date          Code_by         Contents
//1.0           2022/11/6     xxxx            Create
//=============================================================
module tree_adder #(
    parameter   IDW                 = 10                ,
    parameter   DATA_NUM            = 8                 ,
    parameter   INSERT_REG          = 0                 ,
    parameter   GATE_NUM            = 5                 ,
    localparam  EXT_DW              = $clog2(DATA_NUM)  ,
    localparam  ODW                 = EXT_DW+IDW        ,
    parameter   END_OF_LIST         = 1
)(
    input  logic                           i_vld        ,
    input  logic [DATA_NUM-1: 0][IDW-1: 0] i_data       ,
    output logic                           o_vld        ,
    output logic [ODW-1:      0]           o_add_reslt  ,
    input  logic                           i_clk        ,
    input  logic                           i_rst_n
 );
//==================================
//local param delcaration
//==================================
 localparam  DATA_NUM_ALIGN2N = 2**EXT_DW                ;
 localparam  LGC_GATE_LVL     = $clog2(DATA_NUM_ALIGN2N) ;
//==================================
//var delcaration
//==================================
logic [DATA_NUM_ALIGN2N-1: 0][IDW-1: 0] tmp_data  ;
logic [ODW-1:              0]           add_reslt ;
//==================================
//main code
//==================================  
generate
for(genvar i=0; i<DATA_NUM_ALIGN2N; i=i+1) begin: REFILL_DATA_BLK
    if(i<DATA_NUM) begin: CPY_DATA_BLK
        assign tmp_data[i] = i_data[i];
    end
    else begin: FILL_ZERO_BLK
        assign tmp_data[i] = IDW'(0);
    end
end

if(DATA_NUM_ALIGN2N==2) begin: DATA_NUM_EQ_2
    assign o_vld       = i_vld                    ;
    assign o_add_reslt = tmp_data[1] + tmp_data[0];
end
else begin: DATA_NUM_GT_2
    localparam TMP_IDW      = IDW                   ;
    localparam TMP_DATA_NUM = DATA_NUM_ALIGN2N/2    ;
    localparam TMP_EXT_DW   = $clog2(TMP_DATA_NUM)  ;
    localparam TMP_ODW      = TMP_EXT_DW+TMP_IDW    ;

    logic [TMP_DATA_NUM-1: 0][TMP_IDW-1: 0] tmp_i_data_h        ;
    logic [TMP_DATA_NUM-1: 0][TMP_IDW-1: 0] tmp_i_data_l        ;
    logic [TMP_ODW-1:      0]               tmp_o_add_reslt_h   ;
    logic [TMP_ODW-1:      0]               tmp_o_add_reslt_l   ;
    logic                                   tmp_i_vld_h         ;
    logic                                   tmp_o_vld_h         ;
    logic                                   tmp_i_vld_l         ;
    logic                                   tmp_o_vld_l         ;                                  

    for(genvar j=0; j<TMP_DATA_NUM; j=j+1) begin: SPLIT_DATA_BLK
        assign tmp_i_data_h[j] = tmp_data[j+TMP_DATA_NUM];
        assign tmp_i_data_l[j] = tmp_data[j];
    end

    assign tmp_i_vld_h = i_vld;
    assign tmp_i_vld_l = i_vld;

    tree_adder #(
        .IDW        (TMP_IDW        ),
        .DATA_NUM   (TMP_DATA_NUM   ),
        .INSERT_REG (INSERT_REG     ),
        .GATE_NUM   (GATE_NUM       )
    ) U_TREE_ADDR_H(
        .i_vld          (tmp_i_vld_h        ),
        .i_data         (tmp_i_data_h       ),
        .o_vld          (tmp_o_vld_h        ),
        .o_add_reslt    (tmp_o_add_reslt_h  ),
        .i_clk          (i_clk              ),
        .i_rst_n        (i_rst_n            )
    );

    tree_adder #(
        .IDW        (TMP_IDW        ),
        .DATA_NUM   (TMP_DATA_NUM   ),
        .INSERT_REG (INSERT_REG     ),
        .GATE_NUM   (GATE_NUM       )
    ) U_TREE_ADDR_L(
        .i_vld          (tmp_i_vld_l        ),
        .i_data         (tmp_i_data_l       ),
        .o_vld          (tmp_o_vld_l        ),
        .o_add_reslt    (tmp_o_add_reslt_l  ),
        .i_clk          (i_clk              ),
        .i_rst_n        (i_rst_n            )
    );

    if((INSERT_REG==1)&((LGC_GATE_LVL%GATE_NUM)==0)&((DATA_NUM_ALIGN2N%(1<<GATE_NUM))==0)) begin: INSERT_REG_BLK
        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
                o_vld <= 1'b0;
            end
            else begin
                o_vld <= (tmp_o_vld_h|tmp_o_vld_l);
            end
        end
        always_ff@(posedge i_clk or negedge i_rst_n) begin
            if(~i_rst_n) begin
                o_add_reslt <= ODW'(0);
            end
            else begin
                o_add_reslt <= (tmp_o_vld_h|tmp_o_vld_l) ? (tmp_o_add_reslt_h + tmp_o_add_reslt_l) : o_add_reslt;
            end
        end
    end
    else begin: NO_INSERT_REG_BLK
        assign o_vld        = tmp_o_vld_h | tmp_o_vld_l             ;
        assign o_add_reslt  = tmp_o_add_reslt_h + tmp_o_add_reslt_l ;
    end
end
endgenerate   

// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON
param_data_num_chk: assert property(data_num_chk);
property data_num_chk;
    @(posedge i_clk) (DATA_NUM>1);
endproperty
`endif   
// synopsys translate_on    
endmodule
