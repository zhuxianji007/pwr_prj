`include "comm_param.vh"

parameter CTRL_FSM_ST_NUM       = 9                                                         ,
parameter CTRL_FSM_ST_W         = CTRL_FSM_ST_NUM ? 1 : $clog2(CTRL_FSM_ST_NUM)             ,
parameter LV_SCAN_REG_NUM       = 8                                                         ,

