parameter FSM_ST_NUM        = 11                                                ,
parameter FSM_ST_W          = FSM_ST_NUM ? 1 : $clog2(FSM_ST_NUM)               ,
parameter REG_DW            = 8                                                 ,
parameter REG_AW            = 8                                                 ,
parameter REG_CRC_W         = 8                                                 ,
parameter FSM_ST_NUM        = 11                                                ,
parameter FSM_ST_W          = FSM_ST_NUM ? 1 : $clog2(FSM_ST_NUM)               ,
parameter FSM_REQ_ADC_NUM   = 4                                                 ,
parameter FSM_REQ_ADC_CNT_W = (FSM_REQ_ADC_NUM==1) ? 1 : $clog2(FSM_REQ_ADC_NUM),
