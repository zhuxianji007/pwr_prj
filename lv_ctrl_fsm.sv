//============================================================
//Module   : lv_ctrl_fsm
//Function : low voltage die, ctrl fsm
//File Tree: lv_core
//            |--lv_ctrl_fsm
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
    input  logic           i_power_on      ,
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
    input  logic           i_normal_en     ,
    input  logic           i_cfg_en        ,
    input  logic           i_bist_en       ,
    input  logic           i_sft_rst       ,//software reset
	
    output logic           o_pwm_ctrl      ,//1: enable; 0: disable
    output logic           o_crc_wdg_ctrl  ,//1: enable; 0: disable
    output logic           o_ow_wdg_ctrl   ,//1: enable; 0: disable
    output logic           o_spi_ctrl      ,//1: enable; 0: disable
    output logic           o_bist_ctrl     ,//1: enable; 0: disable
    output logic           o_cfg_ctrl      ,//1: enable; 0: disable
    output logic           o_ow_comm_ctrl  ,//1: enable; 0: disable
    output logic           o_fsafe_ctrl    ,//failsafe ctrl enb
    output logic           o_int_n         ,//interupte
	
    output logic           o_fsm_efuse_load_en  ,
    input  logic           i_efuse_fsm_load_done,

    output logic           o_fsm_ow_ctrl_req_adc,
    input  logic           i_ow_ctrl_fsm_ack_adc,
    input  logic           i_ow_ctrl_fsm_ack_adc_status, //0: ow comm ok; 1: ow comm err.
		
    input  logic           i_clk	   ,
    input  logic           i_rst_n          //hardware reset
 );
//==================================
//local param delcaration
//==================================
localparam FSM_ST_NUM      = 11;
localparam FSM_ST_W        = FSM_ST_NUM ? 1 : $clog2(FSM_ST_NUM);
	
localparam POWER_DOWN_ST   = FSM_ST_W'(0 );
localparam WAIT_ST         = FSM_ST_W'(1 ); 
localparam TEST_ST         = FSM_ST_W'(2 );
localparam NORMAL_ST       = FSM_ST_W'(3 );
localparam FAILSAFE_ST     = FSM_ST_W'(4 );
localparam OW_COMM_ERR_ST  = FSM_ST_W'(5 );
localparam OW_WDG_FAULT_ST = FSM_ST_W'(6 );
localparam FAULT_ST        = FSM_ST_W'(7 );
localparam CFG_ST          = FSM_ST_W'(8 );
localparam RST_ST          = FSM_ST_W'(9 );
localparam BIST_ST         = FSM_ST_W'(10);
//==================================
//var delcaration
//==================================
logic 			               lvhv_err0	            ;
logic 			               lvhv_err1	            ;
logic 			               lvhv_err2	            ;
logic [FSM_ST_W-1:          0] cur_st	 	            ;
logic [FSM_ST_W-1:          0] nxt_st	 	            ;
logic                          fsm_efuse_load_en        ;
logic                          efuse_fsm_load_done_lock ;
logic [FSM_REQ_ADC_CNT_W-1: 0] wait_st_req_adc_cnt      ;
//==================================
//main code
//==================================
always_ff@(posedge i_clk or negedge i_rst_n) begin
    	if(~i_rst_n) begin
        	cur_st <= POWER_DOWN_ST;
    	end
    	else begin
        	cur_st <= nxt_st;
    	end
end

always_comb begin
    	case(cur_st)
	    POWER_DOWN_ST  :  begin 
            if(~i_power_on) begin
                nxt_st = POWER_DOWN_ST;
            end
            else begin
                nxt_st = WAIT_ST ; 
            end
        end
	    WAIT_ST        :  begin 
            if(~i_power_on) begin
                nxt_st = POWER_DOWN_ST;
            end
            else if(efuse_fsm_load_done_lock & ~i_efuse_vld) begin
                nxt_st = TEST_ST;
            end
            else if()
        end
	    TEST_ST        :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    NORMAL_ST      :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    FAILSAFE_ST    :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    OW_COMM_ERR_ST :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    OW_WDG_FAULT_ST:  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    FAULT_ST       :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    CFG_ST         :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    RST_ST         :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
	    BIST_ST        :  begin nxt_st = ~i_power_on ? POWER_DOWN_ST : ;end
    	endcase
end

assign fsm_efuse_load_en = (cur_st==POWER_DOWN_ST) && (nxt_st==WAIT_ST) && ~i_efuse_vld;
	
always_ff@(posedge i_clk or negedge i_rst_n) begin
    	if(~i_rst_n) begin
        	o_fsm_efuse_load_en <= 1'b0;
    	end
    	else begin
		    o_fsm_efuse_load_en <= fsm_efuse_load_en;
    	end
end	

always_ff@(posedge i_clk or negedge i_rst_n) begin
        if(~i_rst_n) begin
            efuse_fsm_load_done_lock <= 1'b0;
        end    
        else if(fsm_efuse_load_en) begin
            efuse_fsm_load_done_lock <= 1'b0;
        end
        else if(i_efuse_fsm_load_done) begin
            efuse_fsm_load_done_lock <= 1'b1;
        end
        else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        wait_st_req_adc_cnt <= FSM_REQ_ADC_CNT_W'(0);
    end    
    else if((cur_st==WAIT_ST) && i_efuse_vld && i_ow_ctrl_fsm_ack_adc && ~i_ow_ctrl_fsm_ack_adc_status) begin
        wait_st_req_adc_cnt <= (wait_st_req_adc_cnt==(FSM_REQ_ADC_NUM-1)) ? FSM_REQ_ADC_CNT_W'(0) : (wait_st_req_adc_cnt+1'b1);
    end
    else;
end

always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_pwm_ctrl <= 1'b0;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==WAIT_ST)) begin
        	o_pwm_ctrl <= 1'b0;
    	end
	else if(cur_st==NORMAL_ST) begin
		o_pwm_ctrl <= 1'b1;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_crc_wdg_ctrl <= 1'b0;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==WAIT_ST)) begin
        	o_crc_wdg_ctrl <= 1'b0;
    	end
	else if(cur_st==NORMAL_ST) begin
		o_crc_wdg_ctrl <= 1'b1;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_ow_wdg_ctrl <= 1'b0;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==WAIT_ST)) begin
        	o_ow_wdg_ctrl <= 1'b0;
    	end
	else if(cur_st==NORMAL_ST) begin
		o_ow_wdg_ctrl <= 1'b1;
	end
end	
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_spi_ctrl <= 1'b0;
	end
    	else if(cur_st==POWER_DOWN_ST) begin
        	o_spi_ctrl <= 1'b0;
    	end
	else if(cur_st==WAIT_ST) begin
		o_spi_ctrl <= 1'b1;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_bist_ctrl <= 1'b0;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==WAIT_ST)) begin
        	o_bist_ctrl <= 1'b0;
    	end
	else if(cur_st==NORMAL_ST) begin
		o_bist_ctrl <= 1'b0;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_cfg_ctrl <= 1'b0;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==WAIT_ST) || (cur_st==NORMAL_ST)) begin
        	o_cfg_ctrl <= 1'b0;
    	end
	else if() begin
		o_cfg_ctrl <= 1'b0;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_ow_comm_ctrl <= 1'b0;
	end
    	else if(cur_st==POWER_DOWN_ST) begin
        	o_ow_comm_ctrl <= 1'b0;
    	end
	else if((cur_st==NORMAL_ST) || (cur_st==WAIT_ST)) begin
		o_ow_comm_ctrl <= 1'b1;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_fsafe_ctrl <= 1'b0;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==WAIT_ST)) begin
        	o_fsafe_ctrl <= 1'b0;
    	end
	else if() begin
		o_fsafe_ctrl <= 1'b0;
	end
end
		    
always_ff@(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		o_int_n <= 1'b1;
	end
	else if((cur_st==POWER_DOWN_ST) || (cur_st==NORMAL_ST)) begin
        	o_int_n <= 1'b1;
    	end
	else if((cur_st==WAIT_ST)) begin
		o_int_n <= 1'b0;
	end
end		    
// synopsys translate_off    
//==================================
//assertion
//==================================
`ifdef ASSERT_ON

`endif
// synopsys translate_on    
endmodule
