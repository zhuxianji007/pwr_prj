`include "comm_param.svh"

parameter CTRL_FSM_ST_NUM       = 9                                                         ,
parameter CTRL_FSM_ST_W         = CTRL_FSM_ST_NUM ? 1 : $clog2(CTRL_FSM_ST_NUM)             ,
parameter LV_SCAN_REG_NUM       = 8                                                         ,

parameter EFUSE_DATA_NUM        = 8                                                         ,
parameter EFUSE_DW              = REG_DW                                                    ,
