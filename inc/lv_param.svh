`include "com_param.svh"

parameter CTRL_FSM_ST_NUM           = 9                                                         ,
parameter CTRL_FSM_ST_W             = CTRL_FSM_ST_NUM ? 1 : $clog2(CTRL_FSM_ST_NUM)             ,
parameter LV_SCAN_REG_NUM           = 6                                                         ,

parameter PWR_DWN_ST                = CTRL_FSM_ST_W'(0)                                         ,
parameter WAIT_ST                   = CTRL_FSM_ST_W'(1)                                         ,
parameter TEST_ST                   = CTRL_FSM_ST_W'(2)                                         ,
parameter NML_ST                    = CTRL_FSM_ST_W'(3)                                         ,
parameter FAILSAFE_ST               = CTRL_FSM_ST_W'(4)                                         ,
parameter FAULT_ST                  = CTRL_FSM_ST_W'(5)                                         ,
parameter CFG_ST                    = CTRL_FSM_ST_W'(6)                                         ,
parameter RST_ST                    = CTRL_FSM_ST_W'(7)                                         ,
parameter BIST_ST                   = CTRL_FSM_ST_W'(8)                                         ,

parameter EFUSE_DATA_NUM            = 8                                                         ,
parameter EFUSE_DW                  = REG_DW                                                    ,

parameter HV_ANALOG_REG_START_ADDR  = 7'h40                                                     ,
parameter HV_ANALOG_REG_END_ADDR    = 7'h6E                                                     ,
