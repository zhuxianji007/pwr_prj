`include "comm_param.vh"

parameter CTRL_FSM_ST_NUM       = 9                                                         ,
parameter CTRL_FSM_ST_W         = CTRL_FSM_ST_NUM ? 1 : $clog2(CTRL_FSM_ST_NUM)             ,

parameter FSM_REQ_ADC_NUM       = 4                                                         ,
parameter FSM_REQ_ADC_CNT_W     = (FSM_REQ_ADC_NUM==1) ? 1 : $clog2(FSM_REQ_ADC_NUM)        ,